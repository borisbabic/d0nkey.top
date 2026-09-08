defmodule Backend.BracketPredictions do
  @moduledoc """
  Context module for Bracket Predictions.
  """
  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.BracketPredictions.Tournament
  alias Backend.BracketPredictions.Stage
  alias Backend.BracketPredictions.Match
  alias Backend.BracketPredictions.Entry
  alias Backend.BracketPredictions.Pick
  alias Backend.BracketPredictions.DAG
  alias Backend.BracketPredictions.Scoring
  alias Backend.BracketPredictions.BattlefySync
  alias Backend.UserManager.User

  @doc "Lists all tournaments sorted by inserted_at descending"
  def list_tournaments do
    Tournament
    |> order_by([t], desc: t.inserted_at)
    |> Repo.all()
  end

  @doc "Gets a tournament by ID with stages and matches preloaded"
  def get_tournament!(id) do
    Tournament
    |> Repo.get!(id)
    |> Repo.preload([:creator, stages: [matches: []], matches: []])
  end

  @doc "Gets a tournament by ID or slug"
  def get_tournament(id_or_slug) do
    query =
      if is_binary(id_or_slug) and Integer.parse(id_or_slug) == :error do
        from(t in Tournament, where: t.slug == ^id_or_slug)
      else
        from(t in Tournament, where: t.id == ^id_or_slug)
      end

    query
    |> Repo.one()
    |> case do
      nil -> nil
      tour -> Repo.preload(tour, [:creator, stages: [matches: []], matches: []])
    end
  end

  @doc "Creates a basic tournament"
  def create_tournament(attrs \\ %{}) do
    creator = Map.get(attrs, :creator_id) || Map.get(attrs, "creator_id")

    creator_id =
      case creator do
        %User{id: id} -> id
        id -> id
      end

    %Tournament{creator_id: creator_id}
    |> Tournament.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a tournament"
  def update_tournament(%Tournament{} = tournament, attrs) do
    tournament
    |> Tournament.changeset(attrs)
    |> Repo.update()
  end

  @doc "Gets a tournament by ID or slug (alias for get_tournament/1)"
  def get_tournament_by_slug_or_id(id_or_slug), do: get_tournament(id_or_slug)

  @doc "Updates a stage"
  def update_stage(%Stage{} = stage, attrs) do
    stage
    |> Stage.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes a tournament"
  def delete_tournament(%Tournament{} = tournament) do
    Repo.delete(tournament)
  end

  @doc """
  High-level helper to generate a complete multi-stage tournament:
  GSL Double Elimination Groups (skipping grand finals) into Single Elimination Playoffs (with optional 3rd place match).

  `groups_data`: list of maps, e.g.:
  [
    %{name: "Group A", participants: ["Player 1", "Player 2", "Player 3", "Player 4"], battlefy_stage_id: "id_a"},
    %{name: "Group B", participants: ["Player 5", "Player 6", "Player 7", "Player 8"], battlefy_stage_id: "id_b"},
    ...
  ]
  """
  def create_gsl_into_single_elim_tournament(tournament_attrs, groups_data, options \\ []) do
    has_third_place = Keyword.get(options, :has_third_place_match, false)
    playoff_stage_id = Keyword.get(options, :playoff_battlefy_stage_id)
    group_count = length(groups_data)

    Repo.transaction(fn ->
      # 1. Create Tournament
      tournament =
        case create_tournament(tournament_attrs) do
          {:ok, t} -> t
          {:error, cs} -> Repo.rollback(cs)
        end

      # 2. Create Stage 1: GSL Double Elim Groups
      stage_1_config = %{
        "skip_grand_finals" => true,
        "group_count" => group_count,
        "advancing_per_group" => 2,
        "group_battlefy_stage_ids" =>
          Map.new(groups_data, fn g -> {g.name, Map.get(g, :battlefy_stage_id) || Map.get(g, "battlefy_stage_id")} end)
      }

      stage_1 =
        %Stage{}
        |> Stage.changeset(%{
          tournament_id: tournament.id,
          sequence: 1,
          name: "Group Stage",
          stage_type: "double_elimination_groups",
          config: stage_1_config
        })
        |> Repo.insert!()

      # 3. Create Matches for each GSL group
      Enum.each(Enum.with_index(groups_data, 1), fn {group_info, g_idx} ->
        group_name = Map.get(group_info, :name) || Map.get(group_info, "name") || "Group #{<<?A + g_idx - 1>>}"
        participants = Map.get(group_info, :participants) || Map.get(group_info, "participants") || []
        p_list = Enum.take(participants ++ ["TBD 1", "TBD 2", "TBD 3", "TBD 4"], 4)
        [p1, p2, p3, p4] = p_list
        prefix = "g#{g_idx}"

        matches_data = [
          %{
            tournament_id: tournament.id,
            stage_id: stage_1.id,
            group_name: group_name,
            round_number: 1,
            round_name: "#{group_name} - Opening 1",
            match_identifier: "#{prefix}_opening_1",
            match_order: (g_idx - 1) * 5 + 1,
            top_source_type: "seed",
            top_name: p1,
            bottom_source_type: "seed",
            bottom_name: p2
          },
          %{
            tournament_id: tournament.id,
            stage_id: stage_1.id,
            group_name: group_name,
            round_number: 1,
            round_name: "#{group_name} - Opening 2",
            match_identifier: "#{prefix}_opening_2",
            match_order: (g_idx - 1) * 5 + 2,
            top_source_type: "seed",
            top_name: p3,
            bottom_source_type: "seed",
            bottom_name: p4
          },
          %{
            tournament_id: tournament.id,
            stage_id: stage_1.id,
            group_name: group_name,
            round_number: 2,
            round_name: "#{group_name} - Winners Match",
            match_identifier: "#{prefix}_winners",
            match_order: (g_idx - 1) * 5 + 3,
            top_source_type: "winner_of",
            top_source_identifier: "#{prefix}_opening_1",
            bottom_source_type: "winner_of",
            bottom_source_identifier: "#{prefix}_opening_2"
          },
          %{
            tournament_id: tournament.id,
            stage_id: stage_1.id,
            group_name: group_name,
            round_number: 2,
            round_name: "#{group_name} - Elimination Match",
            match_identifier: "#{prefix}_elim",
            match_order: (g_idx - 1) * 5 + 4,
            top_source_type: "loser_of",
            top_source_identifier: "#{prefix}_opening_1",
            bottom_source_type: "loser_of",
            bottom_source_identifier: "#{prefix}_opening_2"
          },
          %{
            tournament_id: tournament.id,
            stage_id: stage_1.id,
            group_name: group_name,
            round_number: 3,
            round_name: "#{group_name} - Decider Match",
            match_identifier: "#{prefix}_decider",
            match_order: (g_idx - 1) * 5 + 5,
            top_source_type: "loser_of",
            top_source_identifier: "#{prefix}_winners",
            bottom_source_type: "winner_of",
            bottom_source_identifier: "#{prefix}_elim"
          }
        ]

        Enum.each(matches_data, fn m_attrs ->
          %Match{} |> Match.changeset(m_attrs) |> Repo.insert!()
        end)
      end)

      # 4. Create Stage 2: Single Elimination Playoffs
      stage_2_config = %{
        "has_third_place_match" => has_third_place,
        "battlefy_stage_id" => playoff_stage_id
      }

      stage_2 =
        %Stage{}
        |> Stage.changeset(%{
          tournament_id: tournament.id,
          sequence: 2,
          name: "Playoffs",
          stage_type: "single_elimination",
          config: stage_2_config
        })
        |> Repo.insert!()

      # 5. Create Playoff Matches
      if group_count >= 4 do
        create_top8_playoff_matches(tournament.id, stage_2.id, has_third_place)
      else
        create_top4_playoff_matches(tournament.id, stage_2.id, has_third_place)
      end

      get_tournament!(tournament.id)
    end)
  end

  defp create_top8_playoff_matches(tour_id, stage_id, has_third_place) do
    qfs = [
      %{
        tournament_id: tour_id,
        stage_id: stage_id,
        round_number: 4,
        round_name: "Quarterfinal 1",
        match_identifier: "playoffs_qf_1",
        match_order: 101,
        top_source_type: "stage_advancement",
        top_source_identifier: "g1_winners",
        bottom_source_type: "stage_advancement",
        bottom_source_identifier: "g2_decider"
      },
      %{
        tournament_id: tour_id,
        stage_id: stage_id,
        round_number: 4,
        round_name: "Quarterfinal 2",
        match_identifier: "playoffs_qf_2",
        match_order: 102,
        top_source_type: "stage_advancement",
        top_source_identifier: "g3_winners",
        bottom_source_type: "stage_advancement",
        bottom_source_identifier: "g4_decider"
      },
      %{
        tournament_id: tour_id,
        stage_id: stage_id,
        round_number: 4,
        round_name: "Quarterfinal 3",
        match_identifier: "playoffs_qf_3",
        match_order: 103,
        top_source_type: "stage_advancement",
        top_source_identifier: "g2_winners",
        bottom_source_type: "stage_advancement",
        bottom_source_identifier: "g1_decider"
      },
      %{
        tournament_id: tour_id,
        stage_id: stage_id,
        round_number: 4,
        round_name: "Quarterfinal 4",
        match_identifier: "playoffs_qf_4",
        match_order: 104,
        top_source_type: "stage_advancement",
        top_source_identifier: "g4_winners",
        bottom_source_type: "stage_advancement",
        bottom_source_identifier: "g3_decider"
      }
    ]

    sfs = [
      %{
        tournament_id: tour_id,
        stage_id: stage_id,
        round_number: 5,
        round_name: "Semifinal 1",
        match_identifier: "playoffs_sf_1",
        match_order: 105,
        top_source_type: "winner_of",
        top_source_identifier: "playoffs_qf_1",
        bottom_source_type: "winner_of",
        bottom_source_identifier: "playoffs_qf_2"
      },
      %{
        tournament_id: tour_id,
        stage_id: stage_id,
        round_number: 5,
        round_name: "Semifinal 2",
        match_identifier: "playoffs_sf_2",
        match_order: 106,
        top_source_type: "winner_of",
        top_source_identifier: "playoffs_qf_3",
        bottom_source_type: "winner_of",
        bottom_source_identifier: "playoffs_qf_4"
      }
    ]

    finals = [
      %{
        tournament_id: tour_id,
        stage_id: stage_id,
        round_number: 6,
        round_name: "Grand Finals",
        match_identifier: "playoffs_finals",
        match_order: 108,
        top_source_type: "winner_of",
        top_source_identifier: "playoffs_sf_1",
        bottom_source_type: "winner_of",
        bottom_source_identifier: "playoffs_sf_2"
      }
    ]

    third =
      if has_third_place do
        [
          %{
            tournament_id: tour_id,
            stage_id: stage_id,
            round_number: 6,
            round_name: "3rd Place Match",
            match_identifier: "playoffs_third_place",
            match_order: 107,
            top_source_type: "loser_of",
            top_source_identifier: "playoffs_sf_1",
            bottom_source_type: "loser_of",
            bottom_source_identifier: "playoffs_sf_2"
          }
        ]
      else
        []
      end

    Enum.each(qfs ++ sfs ++ third ++ finals, fn m_attrs ->
      %Match{} |> Match.changeset(m_attrs) |> Repo.insert!()
    end)
  end

  defp create_top4_playoff_matches(tour_id, stage_id, has_third_place) do
    sfs = [
      %{
        tournament_id: tour_id,
        stage_id: stage_id,
        round_number: 4,
        round_name: "Semifinal 1",
        match_identifier: "playoffs_sf_1",
        match_order: 101,
        top_source_type: "stage_advancement",
        top_source_identifier: "g1_winners",
        bottom_source_type: "stage_advancement",
        bottom_source_identifier: "g2_decider"
      },
      %{
        tournament_id: tour_id,
        stage_id: stage_id,
        round_number: 4,
        round_name: "Semifinal 2",
        match_identifier: "playoffs_sf_2",
        match_order: 102,
        top_source_type: "stage_advancement",
        top_source_identifier: "g2_winners",
        bottom_source_type: "stage_advancement",
        bottom_source_identifier: "g1_decider"
      }
    ]

    finals = [
      %{
        tournament_id: tour_id,
        stage_id: stage_id,
        round_number: 5,
        round_name: "Grand Finals",
        match_identifier: "playoffs_finals",
        match_order: 104,
        top_source_type: "winner_of",
        top_source_identifier: "playoffs_sf_1",
        bottom_source_type: "winner_of",
        bottom_source_identifier: "playoffs_sf_2"
      }
    ]

    third =
      if has_third_place do
        [
          %{
            tournament_id: tour_id,
            stage_id: stage_id,
            round_number: 5,
            round_name: "3rd Place Match",
            match_identifier: "playoffs_third_place",
            match_order: 103,
            top_source_type: "loser_of",
            top_source_identifier: "playoffs_sf_1",
            bottom_source_type: "loser_of",
            bottom_source_identifier: "playoffs_sf_2"
          }
        ]
      else
        []
      end

    Enum.each(sfs ++ third ++ finals, fn m_attrs ->
      %Match{} |> Match.changeset(m_attrs) |> Repo.insert!()
    end)
  end

  @doc "Gets a user's prediction entry for a tournament"
  def get_user_entry(tournament_id, user_id) do
    Entry
    |> where([e], e.tournament_id == ^tournament_id and e.user_id == ^user_id)
    |> preload([:user, picks: [:match]])
    |> Repo.one()
  end

  @doc "Gets an entry by ID, or nil if not found"
  def get_entry(entry_id) do
    id =
      case entry_id do
        id when is_integer(id) ->
          id

        id when is_binary(id) ->
          case Integer.parse(id) do
            {int_id, ""} -> int_id
            _ -> nil
          end

        _ ->
          nil
      end

    if id do
      case Repo.get(Entry, id) do
        nil -> nil
        entry -> Repo.preload(entry, [:user, :tournament, picks: [match: []]])
      end
    else
      nil
    end
  end

  @doc "Gets an entry by ID"
  def get_entry!(entry_id) do
    Entry
    |> Repo.get!(entry_id)
    |> Repo.preload([:user, :tournament, picks: [match: []]])
  end

  @doc "Lists all entries for a tournament sorted by rank then score"
  def list_entries_for_tournament(tournament_id) do
    Entry
    |> where([e], e.tournament_id == ^tournament_id)
    |> order_by([e], asc_nulls_last: e.rank, desc: e.total_score, asc: e.submitted_at)
    |> preload([:user, :picks])
    |> Repo.all()
  end

  @doc """
  Saves or updates a user's predictions.
  Validates against DAG engine to ensure only logically valid picks are stored.
  """
  def save_entry_predictions(%Tournament{} = tournament, %User{} = user, picks_map, entry_name \\ nil) do
    fresh_tournament = if tournament.id, do: Repo.get!(Tournament, tournament.id), else: tournament

    if Tournament.open_for_predictions?(fresh_tournament) do
      matches = Repo.all(from(m in Match, where: m.tournament_id == ^fresh_tournament.id))
      matches_by_id = Map.new(matches, &{&1.match_identifier, &1})
      evaluated_nodes = DAG.evaluate_matches(matches, picks_map)

      Repo.transaction(fn ->
        entry =
          case get_user_entry(fresh_tournament.id, user.id) do
            nil ->
              name = entry_name || "#{user.battletag || "User"}'s Bracket"

              %Entry{}
              |> Entry.changeset(%{
                tournament_id: fresh_tournament.id,
                user_id: user.id,
                name: name,
                submitted_at: NaiveDateTime.utc_now()
              })
              |> Repo.insert!()

            existing ->
              attrs = %{submitted_at: NaiveDateTime.utc_now()}

              attrs =
                if entry_name && String.trim(entry_name) != "" do
                  Map.put(attrs, :name, String.trim(entry_name))
                else
                  attrs
                end

              existing
              |> Entry.changeset(attrs)
              |> Repo.update!()
          end

        # Upsert evaluated picks
        Enum.each(evaluated_nodes, fn node ->
          match_identifier = node.match.match_identifier
          match = Map.get(matches_by_id, match_identifier)

          if match && node.picked_winner do
            pick_attrs = %{
              entry_id: entry.id,
              match_id: match.id,
              picked_winner_name: node.picked_winner,
              predicted_top_name: node.predicted_top,
              predicted_bottom_name: node.predicted_bottom,
              predicted_top_score: node.predicted_top_score,
              predicted_bottom_score: node.predicted_bottom_score
            }

            case Repo.get_by(Pick, entry_id: entry.id, match_id: match.id) do
              nil ->
                %Pick{} |> Pick.changeset(pick_attrs) |> Repo.insert!()

              existing_pick ->
                existing_pick |> Pick.changeset(pick_attrs) |> Repo.update!()
            end
          else
            if match do
              # Clean up any previously stored pick that has now been invalidated
              from(p in Pick, where: p.entry_id == ^entry.id and p.match_id == ^match.id)
              |> Repo.delete_all()
            end
          end
        end)

        get_entry!(entry.id)
      end)
    else
      {:error, :predictions_closed}
    end
  end

  @doc """
  Enters actual results for a match manually.
  Propagates winners/losers into downstream matches and triggers leaderboard recalculation.
  """
  def enter_manual_match_result(match_id, winner_name, top_score \\ nil, bottom_score \\ nil) do
    match = Repo.get!(Match, match_id) |> Repo.preload(:tournament)

    Repo.transaction(fn ->
      match
      |> Match.changeset(%{
        actual_winner_name: winner_name,
        top_score: top_score,
        bottom_score: bottom_score,
        is_complete: true
      })
      |> Repo.update!()

      # Propagate actual results to downstream matches in real tournament state
      propagate_actual_results(match.tournament_id)

      # Recalculate leaderboard
      recalculate_leaderboard(match.tournament_id)

      Repo.get!(Match, match_id)
    end)
  end

  @doc """
  Propagates completed match results forward to populate actual top_name / bottom_name
  in downstream matches that are dependent on winner_of or loser_of.
  """
  def propagate_actual_results(tournament_id) do
    do_propagate_actual_results(tournament_id)
  end

  defp do_propagate_actual_results(tournament_id) do
    matches =
      Match
      |> where([m], m.tournament_id == ^tournament_id)
      |> order_by([m], asc: m.match_order)
      |> Repo.all()

    matches_map = Map.new(matches, &{&1.match_identifier, &1})

    updated_any? =
      Enum.reduce(matches, false, fn m, acc ->
        top_source = resolve_actual_source(m.top_source_type, m.top_source_identifier, matches_map)
        bot_source = resolve_actual_source(m.bottom_source_type, m.bottom_source_identifier, matches_map)

        updates = %{}
        updates = if is_nil(m.top_name) and top_source, do: Map.put(updates, :top_name, top_source), else: updates
        updates = if is_nil(m.bottom_name) and bot_source, do: Map.put(updates, :bottom_name, bot_source), else: updates

        if map_size(updates) > 0 do
          m |> Match.changeset(updates) |> Repo.update()
          true
        else
          acc
        end
      end)

    if updated_any? do
      do_propagate_actual_results(tournament_id)
    else
      :ok
    end
  end

  defp resolve_actual_source("winner_of", src_id, matches_map) do
    case Map.get(matches_map, src_id) do
      %{is_complete: true, actual_winner_name: w} when is_binary(w) -> w
      _ -> nil
    end
  end

  defp resolve_actual_source("loser_of", src_id, matches_map) do
    case Map.get(matches_map, src_id) do
      %{is_complete: true, actual_winner_name: w, top_name: top, bottom_name: bot} when is_binary(w) ->
        if w == top, do: bot, else: top

      _ ->
        nil
    end
  end

  defp resolve_actual_source("stage_advancement", identifier, matches_map) do
    clean_id = identifier |> to_string() |> String.replace(~r/^stage_advancement:/, "")

    cond do
      String.starts_with?(clean_id, "winner_of:") ->
        resolve_actual_source("winner_of", String.replace_prefix(clean_id, "winner_of:", ""), matches_map)

      String.starts_with?(clean_id, "loser_of:") ->
        resolve_actual_source("loser_of", String.replace_prefix(clean_id, "loser_of:", ""), matches_map)

      true ->
        resolve_actual_source("winner_of", clean_id, matches_map)
    end
  end

  defp resolve_actual_source(_, _, _), do: nil

  @doc """
  Recalculates all entry points and ranks for a tournament.
  """
  def recalculate_leaderboard(tournament_id) do
    tournament = get_tournament!(tournament_id)
    matches = tournament.matches
    entries = list_entries_for_tournament(tournament_id)

    # 1. Grade each entry and update its picks and total_score in DB
    graded_entries =
      Enum.map(entries, fn entry ->
        {total_score, graded_picks} = Scoring.grade_entry(entry, matches, tournament)

        # Update picks in DB
        Enum.each(graded_picks, fn pick ->
          from(p in Pick, where: p.id == ^pick.id)
          |> Repo.update_all(
            set: [
              is_correct: pick.is_correct,
              exact_score_correct: pick.exact_score_correct,
              points_awarded: pick.points_awarded
            ]
          )
        end)

        # Update entry total score
        updated_entry =
          entry
          |> Entry.changeset(%{total_score: total_score})
          |> Repo.update!()

        Map.put(updated_entry, :picks, graded_picks)
      end)

    # 2. Compute rankings with tiebreakers and update rank in DB
    ranked_entries = Scoring.rank_entries(graded_entries)

    Enum.each(ranked_entries, fn entry ->
      from(e in Entry, where: e.id == ^entry.id)
      |> Repo.update_all(set: [rank: entry.rank])
    end)

    list_entries_for_tournament(tournament_id)
  end

  @doc """
  Syncs Battlefy results for the tournament, then recalculates the leaderboard.
  """
  def sync_battlefy_and_rescore(tournament_id) do
    tournament = get_tournament!(tournament_id)

    with {:ok, updated_count} <- BattlefySync.sync_tournament_results(tournament) do
      propagate_actual_results(tournament_id)
      recalculate_leaderboard(tournament_id)
      {:ok, updated_count}
    end
  end
end
