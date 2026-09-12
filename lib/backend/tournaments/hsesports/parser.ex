defmodule Backend.Tournaments.HSEsports.Parser do
  @moduledoc """
  Parser for HSEsports CSV tournament files (4 GSL groups into Top 8 single-elim playoffs).
  """

  alias Backend.Tournaments.MatchStats
  alias Backend.Tournaments.MatchStats.Result
  alias Backend.Hearthstone.Deck

  @default_seedings %{
    "g1_opening_1" => {"McBanterFace", "Soyorin"},
    "g1_opening_2" => {"hyosung", "mlYanming"},
    "g2_opening_1" => {"maxiebon1234", "WinBrownie"},
    "g2_opening_2" => {"XiaoT", "Fatty"},
    "g3_opening_1" => {"Gaby59", "Xiaobai"},
    "g3_opening_2" => {"Curfew", "Kwanuu"},
    "g4_opening_1" => {"SAVOR", "Mesmile"},
    "g4_opening_2" => {"OTGxhh", "Che0nsu"}
  }

  @doc """
  Parses raw CSV content into a list of matches and corresponding MatchStats.
  `lineups` is an optional list of `Backend.Hearthstone.Lineup` structs used to map classes to archetypes.
  """
  @spec parse(String.t(), [Backend.Hearthstone.Lineup.t()] | nil) ::
          {:ok,
           %{
             matches: [map()],
             groups: [%{id: String.t(), name: String.t(), matches: [map()]}],
             playoffs: [map()],
             match_stats: [MatchStats.t()]
           }}
          | {:error, any()}
  def parse(csv_content, lineups \\ []) do
    rows = decode_csv(csv_content)
    matches_by_id = parse_matches(rows)
    matches = sort_matches(Map.values(matches_by_id))
    matches = propagate_bracket_sources(matches)

    lineup_map = build_lineup_map(lineups || [])
    matches = enrich_matches_with_decks(matches, lineup_map)
    match_stats = build_match_stats(matches, lineup_map)

    groups = [
      %{id: "A", name: "Group A", matches: Enum.filter(matches, &(&1.group_name == "Group A"))},
      %{id: "B", name: "Group B", matches: Enum.filter(matches, &(&1.group_name == "Group B"))},
      %{id: "C", name: "Group C", matches: Enum.filter(matches, &(&1.group_name == "Group C"))},
      %{id: "D", name: "Group D", matches: Enum.filter(matches, &(&1.group_name == "Group D"))}
    ]

    playoffs = Enum.filter(matches, &(&1.group_name == "Playoffs"))

    {:ok,
     %{
       matches: matches,
       groups: groups,
       playoffs: playoffs,
       match_stats: match_stats
     }}
  rescue
    e ->
      {:error, e}
  end

  defp decode_csv(csv_content) do
    csv_content
    |> String.split(["\r\n", "\n", "\r"], trim: true)
    |> Enum.map(fn line ->
      # Split by comma but respect basic quoted values if any
      line
      |> :binary.split(",", [:global])
      |> Enum.map(&String.trim/1)
    end)
    |> drop_header()
    |> forward_fill_stages()
  end

  defp drop_header([]), do: []

  defp drop_header([first | rest]) do
    first_col = first |> List.first() |> to_string() |> String.downcase()

    if String.contains?(first_col, "stage") do
      rest
    else
      [first | rest]
    end
  end

  defp forward_fill_stages(rows) do
    {_, _, filled_rows} =
      Enum.reduce(rows, {"", "", []}, fn row, {curr_stage, curr_match, acc} ->
        stage_val = Enum.at(row, 0, "")
        match_val = Enum.at(row, 1, "")

        stage = if stage_val != "", do: stage_val, else: curr_stage
        match = if match_val != "", do: match_val, else: curr_match

        new_row =
          row
          |> List.replace_at(0, stage)
          |> List.replace_at(1, match)

        {stage, match, [new_row | acc]}
      end)

    Enum.reverse(filled_rows)
  end

  defp parse_matches(rows) do
    rows
    |> Enum.group_by(fn row ->
      stage = Enum.at(row, 0, "")
      match = Enum.at(row, 1, "")
      {stage, match}
    end)
    |> Enum.reduce(%{}, fn {{stage_name, match_name}, match_rows}, acc ->
      if stage_name != "" and match_name != "" do
        parsed = parse_single_match(stage_name, match_name, match_rows)
        Map.put(acc, parsed.match_identifier, parsed)
      else
        acc
      end
    end)
  end

  defp parse_single_match(stage_name, match_name, rows) do
    match_id = normalize_match_identifier(stage_name, match_name)
    group_name = resolve_group_name(stage_name)
    round_name = resolve_round_name(stage_name, match_name)

    # Resolve player names from first row having names
    raw_p1 = Enum.find_value(rows, fn r -> (p = Enum.at(r, 3, "")) != "" && p end)
    raw_p2 = Enum.find_value(rows, fn r -> (p = Enum.at(r, 5, "")) != "" && p end)

    {default_p1, default_p2} = Map.get(@default_seedings, match_id, {nil, nil})
    top_name = raw_p1 || default_p1
    bottom_name = raw_p2 || default_p2

    # Parse bans:
    # "The last column will contain the bans. The class Below p1 is the class p1 decided to ban,
    # ie it's the class of player 2's deck that got banned."
    {p1_banned_class, p2_banned_class} = extract_bans(rows)

    # Games processing: Bo5, first to 3 wins
    games_data =
      Enum.map(rows, fn row ->
        game_num = Util.to_int(Enum.at(row, 2, "0"), 0)
        p1_deck = Enum.at(row, 4, "")
        p2_deck = Enum.at(row, 6, "")
        winner = Enum.at(row, 7, "")

        %{
          game_number: game_num,
          p1_deck: p1_deck,
          p2_deck: p2_deck,
          winner: winner
        }
      end)
      |> Enum.sort_by(& &1.game_number)

    {completed_games, top_score, bottom_score, winner_name, is_complete} =
      compute_bo5_result(games_data, top_name, bottom_name)

    is_ongoing =
      not is_complete and
        (Enum.any?(completed_games) or top_score > 0 or bottom_score > 0 or
           (p1_banned_class != nil and p1_banned_class != "") or
           (p2_banned_class != nil and p2_banned_class != ""))

    %{
      match_identifier: match_id,
      stage_name: stage_name,
      group_name: group_name,
      round_name: round_name,
      match_order: match_order(match_id),
      top_name: top_name,
      bottom_name: bottom_name,
      top_score: top_score,
      bottom_score: bottom_score,
      actual_winner_name: winner_name,
      is_complete: is_complete,
      is_ongoing: is_ongoing,
      p1_banned_class: p1_banned_class,
      p2_banned_class: p2_banned_class,
      top_won_decks: [],
      top_lost_decks: [],
      bottom_won_decks: [],
      bottom_lost_decks: [],
      top_game_decks: [],
      bottom_game_decks: [],
      top_banned_deck: nil,
      bottom_banned_deck: nil,
      top_deck_statuses: [],
      bottom_deck_statuses: [],
      completed_games: completed_games,
      all_games: games_data,
      # Default bracket source types
      top_source_type: source_type(match_id, :top),
      top_source_identifier: source_id(match_id, :top),
      bottom_source_type: source_type(match_id, :bottom),
      bottom_source_identifier: source_id(match_id, :bottom)
    }
  end

  defp extract_bans(rows) do
    bans_list = Enum.map(rows, &Enum.at(&1, 8, ""))

    p1_ban = find_class_below(bans_list, "p1")
    p2_ban = find_class_below(bans_list, "p2")

    {p1_ban, p2_ban}
  end

  defp find_class_below(bans_list, prefix) do
    idx =
      Enum.find_index(bans_list, fn b ->
        b_clean = b |> to_string() |> String.trim() |> String.downcase()
        String.starts_with?(b_clean, prefix)
      end)

    if idx && idx + 1 < length(bans_list) do
      val = bans_list |> Enum.at(idx + 1) |> to_string() |> String.trim()
      if val != "" and not String.contains?(String.downcase(val), "ban"), do: val, else: nil
    else
      nil
    end
  end

  defp compute_bo5_result(games, top_name, bottom_name) do
    Enum.reduce_while(games, {[], 0, 0, nil, false}, fn game, {acc_games, p1_wins, p2_wins, _, _} ->
      winner = String.trim(game.winner || "")

      if winner != "" do
        {new_p1_wins, new_p2_wins} =
          cond do
            names_match?(winner, top_name) ->
              {p1_wins + 1, p2_wins}

            names_match?(winner, bottom_name) ->
              {p1_wins, p2_wins + 1}

            true ->
              {p1_wins, p2_wins}
          end

        new_acc = acc_games ++ [game]

        cond do
          new_p1_wins == 3 ->
            {:halt, {new_acc, new_p1_wins, new_p2_wins, top_name, true}}

          new_p2_wins == 3 ->
            {:halt, {new_acc, new_p1_wins, new_p2_wins, bottom_name, true}}

          true ->
            {:cont, {new_acc, new_p1_wins, new_p2_wins, nil, false}}
        end
      else
        {:cont, {acc_games, p1_wins, p2_wins, nil, false}}
      end
    end)
  end

  defp names_match?(_name1, nil), do: false
  defp names_match?(nil, _name2), do: false

  defp names_match?(name1, name2) do
    c1 = clean_player_name(name1)
    c2 = clean_player_name(name2)
    c1 == c2 or String.starts_with?(c1, c2) or String.starts_with?(c2, c1)
  end

  def clean_player_name(nil), do: ""

  def clean_player_name(name) do
    name
    |> to_string()
    |> String.split("#")
    |> List.first()
    |> String.trim()
    |> String.downcase()
  end

  def normalize_match_identifier(stage_str, match_str) do
    s_clean = stage_str |> to_string() |> String.trim() |> String.downcase()
    m_clean = match_str |> to_string() |> String.trim() |> String.downcase()

    cond do
      String.contains?(s_clean, "group a") ->
        "g1_" <> group_match_suffix(m_clean)

      String.contains?(s_clean, "group b") ->
        "g2_" <> group_match_suffix(m_clean)

      String.contains?(s_clean, "group c") ->
        "g3_" <> group_match_suffix(m_clean)

      String.contains?(s_clean, "group d") ->
        "g4_" <> group_match_suffix(m_clean)

      String.contains?(s_clean, "final") or String.contains?(s_clean, "playoff") ->
        playoff_match_id(m_clean)

      true ->
        "m_#{s_clean}_#{m_clean}" |> String.replace(" ", "_")
    end
  end

  defp group_match_suffix(m_clean) do
    cond do
      String.contains?(m_clean, "initial match 1") or String.contains?(m_clean, "opening 1") ->
        "opening_1"

      String.contains?(m_clean, "initial match 2") or String.contains?(m_clean, "opening 2") ->
        "opening_2"

      String.contains?(m_clean, "winner") ->
        "winners"

      String.contains?(m_clean, "elim") ->
        "elim"

      String.contains?(m_clean, "decider") ->
        "decider"

      true ->
        m_clean |> String.replace(" ", "_")
    end
  end

  defp playoff_match_id(m_clean) do
    cond do
      String.contains?(m_clean, "quarterfinal 1") or String.contains?(m_clean, "quarterfinals 1") or
        String.contains?(m_clean, "qf 1") or String.contains?(m_clean, "qf1") ->
        "playoffs_qf_1"

      String.contains?(m_clean, "quarterfinal 2") or String.contains?(m_clean, "quarterfinals 2") or
        String.contains?(m_clean, "qf 2") or String.contains?(m_clean, "qf2") ->
        "playoffs_qf_2"

      String.contains?(m_clean, "quarterfinal 3") or String.contains?(m_clean, "quarterfinals 3") or
        String.contains?(m_clean, "qf 3") or String.contains?(m_clean, "qf3") ->
        "playoffs_qf_3"

      String.contains?(m_clean, "quarterfinal 4") or String.contains?(m_clean, "quarterfinals 4") or
        String.contains?(m_clean, "qf 4") or String.contains?(m_clean, "qf4") ->
        "playoffs_qf_4"

      String.contains?(m_clean, "semifinal 1") or String.contains?(m_clean, "semifinals 1") or
        String.contains?(m_clean, "sf 1") or String.contains?(m_clean, "sf1") ->
        "playoffs_sf_1"

      String.contains?(m_clean, "semifinal 2") or String.contains?(m_clean, "semifinals 2") or
        String.contains?(m_clean, "sf 2") or String.contains?(m_clean, "sf2") ->
        "playoffs_sf_2"

      String.contains?(m_clean, "third") or String.contains?(m_clean, "3rd") ->
        "playoffs_third_place"

      String.contains?(m_clean, "grand") or String.contains?(m_clean, "final") ->
        "playoffs_finals"

      true ->
        "playoffs_" <> String.replace(m_clean, " ", "_")
    end
  end

  defp resolve_group_name(stage_name) do
    s = String.downcase(stage_name)

    cond do
      String.contains?(s, "group a") -> "Group A"
      String.contains?(s, "group b") -> "Group B"
      String.contains?(s, "group c") -> "Group C"
      String.contains?(s, "group d") -> "Group D"
      true -> "Playoffs"
    end
  end

  defp resolve_round_name(stage_name, match_name) do
    group = resolve_group_name(stage_name)
    m = String.downcase(match_name)

    if group == "Playoffs" do
      cond do
        String.contains?(m, "quarterfinal 1") or String.contains?(m, "quarterfinals 1") -> "Quarterfinal 1"
        String.contains?(m, "quarterfinal 2") or String.contains?(m, "quarterfinals 2") -> "Quarterfinal 2"
        String.contains?(m, "quarterfinal 3") or String.contains?(m, "quarterfinals 3") -> "Quarterfinal 3"
        String.contains?(m, "quarterfinal 4") or String.contains?(m, "quarterfinals 4") -> "Quarterfinal 4"
        String.contains?(m, "semifinal 1") or String.contains?(m, "semifinals 1") -> "Semifinal 1"
        String.contains?(m, "semifinal 2") or String.contains?(m, "semifinals 2") -> "Semifinal 2"
        String.contains?(m, "third") or String.contains?(m, "3rd") -> "3rd Place Match"
        String.contains?(m, "grand") or String.contains?(m, "final") -> "Grand Finals"
        true -> match_name
      end
    else
      cond do
        String.contains?(m, "initial match 1") -> "#{group} - Opening 1"
        String.contains?(m, "initial match 2") -> "#{group} - Opening 2"
        String.contains?(m, "winner") -> "#{group} - Winners Match"
        String.contains?(m, "elim") -> "#{group} - Elimination Match"
        String.contains?(m, "decider") -> "#{group} - Decider Match"
        true -> "#{group} - #{match_name}"
      end
    end
  end

  defp match_order(id) do
    case id do
      "g1_opening_1" -> 1
      "g1_opening_2" -> 2
      "g1_winners" -> 3
      "g1_elim" -> 4
      "g1_decider" -> 5
      "g2_opening_1" -> 6
      "g2_opening_2" -> 7
      "g2_winners" -> 8
      "g2_elim" -> 9
      "g2_decider" -> 10
      "g3_opening_1" -> 11
      "g3_opening_2" -> 12
      "g3_winners" -> 13
      "g3_elim" -> 14
      "g3_decider" -> 15
      "g4_opening_1" -> 16
      "g4_opening_2" -> 17
      "g4_winners" -> 18
      "g4_elim" -> 19
      "g4_decider" -> 20
      "playoffs_qf_1" -> 101
      "playoffs_qf_2" -> 102
      "playoffs_qf_3" -> 103
      "playoffs_qf_4" -> 104
      "playoffs_sf_1" -> 105
      "playoffs_sf_2" -> 106
      "playoffs_third_place" -> 107
      "playoffs_finals" -> 108
      _ -> 999
    end
  end

  defp source_type(id, slot) do
    case {id, slot} do
      {id, _}
      when id in [
             "g1_opening_1",
             "g1_opening_2",
             "g2_opening_1",
             "g2_opening_2",
             "g3_opening_1",
             "g3_opening_2",
             "g4_opening_1",
             "g4_opening_2"
           ] ->
        "seed"

      {"g" <> _ = g_id, :top} when binary_part(g_id, 3, 7) == "winners" ->
        "winner_of"

      {"g" <> _ = g_id, :bottom} when binary_part(g_id, 3, 7) == "winners" ->
        "winner_of"

      {"g" <> _ = g_id, :top} when binary_part(g_id, 3, 4) == "elim" ->
        "loser_of"

      {"g" <> _ = g_id, :bottom} when binary_part(g_id, 3, 4) == "elim" ->
        "loser_of"

      {"g" <> _ = g_id, :top} when binary_part(g_id, 3, 7) == "decider" ->
        "loser_of"

      {"g" <> _ = g_id, :bottom} when binary_part(g_id, 3, 7) == "decider" ->
        "winner_of"

      {"playoffs_qf_" <> _, _} ->
        "stage_advancement"

      {"playoffs_sf_" <> _, _} ->
        "winner_of"

      {"playoffs_third_place", _} ->
        "loser_of"

      {"playoffs_finals", _} ->
        "winner_of"

      _ ->
        "seed"
    end
  end

  defp source_id(id, slot) do
    case {id, slot} do
      {"g1_winners", :top} -> "g1_opening_1"
      {"g1_winners", :bottom} -> "g1_opening_2"
      {"g1_elim", :top} -> "g1_opening_1"
      {"g1_elim", :bottom} -> "g1_opening_2"
      {"g1_decider", :top} -> "g1_winners"
      {"g1_decider", :bottom} -> "g1_elim"
      {"g2_winners", :top} -> "g2_opening_1"
      {"g2_winners", :bottom} -> "g2_opening_2"
      {"g2_elim", :top} -> "g2_opening_1"
      {"g2_elim", :bottom} -> "g2_opening_2"
      {"g2_decider", :top} -> "g2_winners"
      {"g2_decider", :bottom} -> "g2_elim"
      {"g3_winners", :top} -> "g3_opening_1"
      {"g3_winners", :bottom} -> "g3_opening_2"
      {"g3_elim", :top} -> "g3_opening_1"
      {"g3_elim", :bottom} -> "g3_opening_2"
      {"g3_decider", :top} -> "g3_winners"
      {"g3_decider", :bottom} -> "g3_elim"
      {"g4_winners", :top} -> "g4_opening_1"
      {"g4_winners", :bottom} -> "g4_opening_2"
      {"g4_elim", :top} -> "g4_opening_1"
      {"g4_elim", :bottom} -> "g4_opening_2"
      {"g4_decider", :top} -> "g4_winners"
      {"g4_decider", :bottom} -> "g4_elim"
      {"playoffs_qf_1", :top} -> "g1_winners"
      {"playoffs_qf_1", :bottom} -> "g2_decider"
      {"playoffs_qf_2", :top} -> "g3_winners"
      {"playoffs_qf_2", :bottom} -> "g4_decider"
      {"playoffs_qf_3", :top} -> "g2_winners"
      {"playoffs_qf_3", :bottom} -> "g1_decider"
      {"playoffs_qf_4", :top} -> "g4_winners"
      {"playoffs_qf_4", :bottom} -> "g3_decider"
      {"playoffs_sf_1", :top} -> "playoffs_qf_1"
      {"playoffs_sf_1", :bottom} -> "playoffs_qf_2"
      {"playoffs_sf_2", :top} -> "playoffs_qf_3"
      {"playoffs_sf_2", :bottom} -> "playoffs_qf_4"
      {"playoffs_third_place", :top} -> "playoffs_sf_1"
      {"playoffs_third_place", :bottom} -> "playoffs_sf_2"
      {"playoffs_finals", :top} -> "playoffs_sf_1"
      {"playoffs_finals", :bottom} -> "playoffs_sf_2"
      _ -> nil
    end
  end

  defp sort_matches(matches) do
    Enum.sort_by(matches, & &1.match_order)
  end

  defp propagate_bracket_sources(matches) do
    matches_map = Map.new(matches, &{&1.match_identifier, &1})

    Enum.map(matches, fn m ->
      top =
        if is_nil(m.top_name) or m.top_name == "" do
          resolve_participant(m.top_source_type, m.top_source_identifier, matches_map)
        else
          m.top_name
        end

      bottom =
        if is_nil(m.bottom_name) or m.bottom_name == "" do
          resolve_participant(m.bottom_source_type, m.bottom_source_identifier, matches_map)
        else
          m.bottom_name
        end

      m
      |> Map.put(:top_name, top)
      |> Map.put(:bottom_name, bottom)
    end)
  end

  defp resolve_participant("winner_of", source_id, matches_map) do
    case Map.get(matches_map, source_id) do
      %{is_complete: true, actual_winner_name: w} when is_binary(w) and w != "" -> w
      _ -> nil
    end
  end

  defp resolve_participant("loser_of", source_id, matches_map) do
    case Map.get(matches_map, source_id) do
      %{is_complete: true, actual_winner_name: w, top_name: t, bottom_name: b} when is_binary(w) ->
        if names_match?(w, t), do: b, else: t

      _ ->
        nil
    end
  end

  defp resolve_participant("stage_advancement", source_id, matches_map) do
    # In GSL, winner of winners match advances as 1st seed; winner of decider advances as 2nd seed
    resolve_participant("winner_of", source_id, matches_map)
  end

  defp resolve_participant(_, _, _), do: nil

  # --- MatchStats building ---

  defp build_lineup_map(lineups) do
    Enum.reduce(lineups, %{}, fn l, acc ->
      key = clean_player_name(l.name)

      deck_map =
        Enum.reduce(l.decks || [], %{}, fn d, d_acc ->
          class_val =
            case Deck.class(d) || Map.get(d, :class) do
              nil ->
                cn = Deck.class_name(d)
                if cn && cn != "", do: cn, else: nil

              val when is_atom(val) ->
                Atom.to_string(val)

              val when is_binary(val) ->
                val

              _ ->
                nil
            end

          if class_val do
            norm_class = class_val |> String.downcase() |> String.replace(" ", "")
            archetype = Deck.archetype(d) || Map.get(d, :archetype) || class_val

            d_acc
            |> Map.put(norm_class, archetype)
            |> Map.put(String.downcase(class_val), archetype)
          else
            d_acc
          end
        end)

      archetypes =
        (l.decks || [])
        |> Enum.map(fn d ->
          Deck.archetype(d) || Map.get(d, :archetype) || to_string(Deck.class(d) || "")
        end)
        |> Enum.reject(&(&1 == ""))

      Map.put(acc, key, %{lineup: l, decks: deck_map, archetypes: archetypes})
    end)
  end

  defp enrich_matches_with_decks(matches, lineup_map) do
    Enum.map(matches, fn m ->
      if Enum.empty?(m.completed_games) do
        m
      else
        p1_key = clean_player_name(m.top_name)
        p2_key = clean_player_name(m.bottom_name)

        p1_info = Map.get(lineup_map, p1_key)
        p2_info = Map.get(lineup_map, p2_key)

        enriched_games =
          Enum.map(m.completed_games, fn game ->
            p1_game_class = String.downcase(game.p1_deck || "")
            p2_game_class = String.downcase(game.p2_deck || "")

            top_deck = resolve_archetype(p1_info, p1_game_class, game.p1_deck)
            bottom_deck = resolve_archetype(p2_info, p2_game_class, game.p2_deck)

            top_won? = names_match?(game.winner, m.top_name)
            bottom_won? = names_match?(game.winner, m.bottom_name)

            winning_deck =
              cond do
                top_won? -> top_deck
                bottom_won? -> bottom_deck
                true -> nil
              end

            losing_deck =
              cond do
                top_won? -> bottom_deck
                bottom_won? -> top_deck
                true -> nil
              end

            winner_name =
              cond do
                top_won? -> m.top_name
                bottom_won? -> m.bottom_name
                true -> game.winner
              end

            loser_name =
              cond do
                top_won? -> m.bottom_name
                bottom_won? -> m.top_name
                true -> nil
              end

            Map.merge(game, %{
              top_deck: top_deck,
              bottom_deck: bottom_deck,
              top_won?: top_won?,
              bottom_won?: bottom_won?,
              winning_deck: winning_deck,
              losing_deck: losing_deck,
              winner_name: winner_name,
              loser_name: loser_name
            })
          end)

        top_won_decks =
          enriched_games
          |> Enum.filter(& &1.top_won?)
          |> Enum.map(& &1.top_deck)
          |> Enum.reject(&is_nil/1)
          |> Enum.uniq()

        top_lost_decks =
          enriched_games
          |> Enum.filter(& &1.bottom_won?)
          |> Enum.map(& &1.top_deck)
          |> Enum.reject(&is_nil/1)
          |> Enum.uniq()

        bottom_won_decks =
          enriched_games
          |> Enum.filter(& &1.bottom_won?)
          |> Enum.map(& &1.bottom_deck)
          |> Enum.reject(&is_nil/1)
          |> Enum.uniq()

        bottom_lost_decks =
          enriched_games
          |> Enum.filter(& &1.top_won?)
          |> Enum.map(& &1.bottom_deck)
          |> Enum.reject(&is_nil/1)
          |> Enum.uniq()

        top_game_decks = build_contestant_game_decks(enriched_games, :top)
        bottom_game_decks = build_contestant_game_decks(enriched_games, :bottom)
        top_banned_deck = build_banned_deck(m.p2_banned_class, p1_info)
        bottom_banned_deck = build_banned_deck(m.p1_banned_class, p2_info)

        top_deck_statuses = build_contestant_deck_statuses(m, :top, p1_info, enriched_games)
        bottom_deck_statuses = build_contestant_deck_statuses(m, :bottom, p2_info, enriched_games)

        %{
          m
          | completed_games: enriched_games,
            top_won_decks: top_won_decks,
            top_lost_decks: top_lost_decks,
            bottom_won_decks: bottom_won_decks,
            bottom_lost_decks: bottom_lost_decks,
            top_game_decks: top_game_decks,
            bottom_game_decks: bottom_game_decks,
            top_banned_deck: top_banned_deck,
            bottom_banned_deck: bottom_banned_deck,
            top_deck_statuses: top_deck_statuses,
            bottom_deck_statuses: bottom_deck_statuses
        }
      end
    end)
  end

  defp build_contestant_game_decks(completed_games, side) do
    Enum.map(completed_games, fn g ->
      deck_raw =
        case side do
          :top -> g[:top_deck] || g[:p1_deck]
          :bottom -> g[:bottom_deck] || g[:p2_deck]
        end

      status =
        cond do
          side == :top && g[:top_won?] -> :won
          side == :bottom && g[:bottom_won?] -> :won
          true -> :lost
        end

      class_extracted =
        Deck.extract_class(deck_raw) || to_string(deck_raw) || "unknown"

      class_slug = class_extracted |> to_string() |> String.downcase()

      outcome_str = if status == :won, do: "Won", else: "Lost"
      tooltip = "Game #{g[:game_number]}: #{deck_raw} (#{outcome_str})"

      %{
        game_number: g[:game_number],
        deck_name: deck_raw,
        class_slug: class_slug,
        status: status,
        tooltip: tooltip
      }
    end)
  end

  defp build_banned_deck(nil, _player_info), do: nil
  defp build_banned_deck("", _player_info), do: nil

  defp build_banned_deck(banned_class, player_info) do
    banned_clean = String.downcase(to_string(banned_class))
    deck_name = resolve_archetype(player_info, banned_clean, banned_class)

    class_extracted =
      Deck.extract_class(deck_name) || Deck.extract_class(banned_class) || to_string(banned_class)

    class_slug = class_extracted |> to_string() |> String.downcase()

    %{
      deck_name: deck_name,
      class_slug: class_slug,
      status: :banned,
      tooltip: "Banned: #{deck_name}"
    }
  end

  defp build_contestant_deck_statuses(m, side, player_info, completed_games) do
    banned_class_raw =
      case side do
        :top -> m.p2_banned_class
        :bottom -> m.p1_banned_class
      end

    banned_norm =
      if banned_class_raw do
        banned_class_raw
        |> to_string()
        |> Deck.extract_class()
        |> Kernel.||(banned_class_raw)
        |> to_string()
        |> String.downcase()
      else
        nil
      end

    lineup_decks =
      if player_info && Map.get(player_info, :lineup) && player_info.lineup.decks do
        Enum.map(player_info.lineup.decks, fn d ->
          arch = Deck.archetype(d) || Map.get(d, :archetype) || to_string(Deck.class(d) || "")
          class_name = Deck.class_name(d) || to_string(Deck.class(d) || "")
          {arch, class_name}
        end)
      else
        nil
      end

    deck_candidates =
      if lineup_decks && Enum.any?(lineup_decks) do
        lineup_decks
      else
        played =
          case side do
            :top -> Enum.map(completed_games, & &1[:top_deck])
            :bottom -> Enum.map(completed_games, & &1[:bottom_deck])
          end
          |> Enum.reject(&(&1 == nil or &1 == ""))
          |> Enum.uniq()

        all_names =
          if banned_class_raw && banned_class_raw != "" do
            Enum.uniq(played ++ [banned_class_raw])
          else
            played
          end

        Enum.map(all_names, fn name -> {name, name} end)
      end

    deck_candidates
    |> Enum.map(fn {deck_name, class_hint} ->
      class_extracted =
        Deck.extract_class(class_hint) || Deck.extract_class(deck_name) || class_hint || "unknown"

      class_slug = class_extracted |> to_string() |> String.downcase()

      is_banned? = banned_norm && class_slug == banned_norm

      won_games =
        Enum.filter(completed_games, fn g ->
          won? = if side == :top, do: g[:top_won?], else: g[:bottom_won?]
          deck = if side == :top, do: g[:top_deck], else: g[:bottom_deck]

          deck_class =
            (Deck.extract_class(deck) || to_string(deck))
            |> to_string()
            |> String.downcase()

          won? && deck_class == class_slug
        end)

      lost_games =
        Enum.filter(completed_games, fn g ->
          lost? = if side == :top, do: g[:bottom_won?], else: g[:top_won?]
          deck = if side == :top, do: g[:top_deck], else: g[:bottom_deck]

          deck_class =
            (Deck.extract_class(deck) || to_string(deck))
            |> to_string()
            |> String.downcase()

          lost? && deck_class == class_slug
        end)

      {status, tooltip, sort_order} =
        cond do
          is_banned? ->
            {:banned, "#{deck_name} (Banned)", 4}

          Enum.any?(won_games) ->
            won_nums = Enum.map(won_games, &"G#{&1.game_number}") |> Enum.join(", ")
            {:won, "#{deck_name} (Won #{won_nums})", 1}

          Enum.any?(lost_games) ->
            lost_nums = Enum.map(lost_games, &"G#{&1.game_number}") |> Enum.join(", ")
            {:lost, "#{deck_name} (Lost #{lost_nums})", 2}

          true ->
            {:unplayed, "#{deck_name} (Unplayed)", 3}
        end

      %{
        name: deck_name,
        class_slug: class_slug,
        status: status,
        tooltip: tooltip,
        sort_order: sort_order
      }
    end)
    |> Enum.sort_by(& &1.sort_order)
  end

  defp build_match_stats(matches, lineup_map) do
    matches
    |> Enum.filter(fn m ->
      # Only process matches that have at least one completed game
      Enum.any?(m.completed_games)
    end)
    |> Enum.map(fn m ->
      p1_key = clean_player_name(m.top_name)
      p2_key = clean_player_name(m.bottom_name)

      p1_info = Map.get(lineup_map, p1_key)
      p2_info = Map.get(lineup_map, p2_key)

      # P1 banned P2's class -> this is a banned deck in P2's lineup
      # P2 banned P1's class -> this is a banned deck in P1's lineup
      p1_banned_class_clean = m.p2_banned_class && String.downcase(m.p2_banned_class)
      p2_banned_class_clean = m.p1_banned_class && String.downcase(m.p1_banned_class)

      p1_banned_arch = resolve_archetype(p1_info, p1_banned_class_clean, m.p2_banned_class)
      p2_banned_arch = resolve_archetype(p2_info, p2_banned_class_clean, m.p1_banned_class)

      banned = [p1_banned_arch, p2_banned_arch] |> Enum.filter(& &1)

      p1_not_banned = resolve_not_banned(p1_info, p1_banned_arch)
      p2_not_banned = resolve_not_banned(p2_info, p2_banned_arch)
      not_banned = p1_not_banned ++ p2_not_banned

      results =
        Enum.map(m.completed_games, fn game ->
          pairs =
            cond do
              Map.get(game, :top_won?) ->
                [{game.top_deck, game.bottom_deck}]

              Map.get(game, :bottom_won?) ->
                [{game.bottom_deck, game.top_deck}]

              names_match?(game.winner, m.top_name) ->
                p1_game_class = String.downcase(game.p1_deck || "")
                p2_game_class = String.downcase(game.p2_deck || "")

                [
                  {resolve_archetype(p1_info, p1_game_class, game.p1_deck),
                   resolve_archetype(p2_info, p2_game_class, game.p2_deck)}
                ]

              names_match?(game.winner, m.bottom_name) ->
                p1_game_class = String.downcase(game.p1_deck || "")
                p2_game_class = String.downcase(game.p2_deck || "")

                [
                  {resolve_archetype(p2_info, p2_game_class, game.p2_deck),
                   resolve_archetype(p1_info, p1_game_class, game.p1_deck)}
                ]

              true ->
                []
            end

          %Result{winner_loser_pairs: pairs}
        end)

      %MatchStats{
        banned: banned,
        not_banned: not_banned,
        results: results
      }
    end)
  end

  defp resolve_archetype(nil, _class_clean, raw_class), do: raw_class

  defp resolve_archetype(%{decks: decks}, class_clean, raw_class) do
    norm = class_clean && class_clean |> String.downcase() |> String.replace(" ", "")
    Map.get(decks, norm) || Map.get(decks, class_clean) || raw_class
  end

  defp resolve_not_banned(nil, _banned_arch), do: []

  defp resolve_not_banned(%{archetypes: archetypes}, banned_arch) do
    if banned_arch do
      Enum.reject(archetypes, &(&1 == banned_arch))
    else
      archetypes
    end
  end
end
