defmodule Backend.Battlefy do
  @moduledoc false
  alias Backend.Infrastructure.BattlefyCommunicator, as: Api
  alias Backend.Battlefy.Tournament
  alias Backend.Battlefy.Tournament.CustomField
  alias Backend.Battlefy.Standings
  alias Backend.Battlefy.Team
  alias Backend.Battlefy.MatchTeam
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.Match.Next
  alias Backend.Battlefy.MatchDeckstrings
  alias Backend.Battlefy.Stage
  alias Backend.BattlefyUtil
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Lineup

  # 192 = 24 (length of id) * 8 (bits in a byte)
  @type region :: :Asia | :Europe | :Americas
  @regions [:Americas, :Asia, :Europe]
  @type battlefy_id :: <<_::192>>
  @type tournament_id :: battlefy_id
  @type user_id :: battlefy_id
  @type team_id :: battlefy_id
  @type stage_id :: battlefy_id
  @type match_id :: battlefy_id
  @type organization_id :: battlefy_id
  @type get_matches_opt :: {:round, integer()}
  @type get_matches_options :: [get_matches_opt]
  @type get_tournament_matches_opt :: {:stage, integer()} | get_matches_opt
  @type get_tournament_matches_options :: [get_tournament_matches_opt]
  @type future_opponents :: %{winner: [Match.t()], loser: [Match.t()]}

  @organization_slugs [
    "houserivalries",
    "super-girl-gamer-pro",
    "ilh-events",
    "hearthstone-esports-thailand",
    # "fantastic-pro-league",
    "tierras-de-fuego-hs",
    "akg-games",
    "liga-kombatklub-de-hearthstone",
    "btw-esports",
    "juega-duro-hearthstone",
    "dreamhack-community-clash",
    "black-claws",
    "osc-esports",
    "classic-hearthstone"
  ]
  @organization_stats_configs (for num <- [6, 5, 4, 3, 2], do: %{
                                    from: ~D[2020-05-01],
                                    organization_slug: "juega-duro-hearthstone",
                                    title: "GRITO DE GUERRA #{num}",
                                    stats_slug: "grito-de-guerra-#{num}",
                                    pattern: ~r/GRITO DE GUERRA #{num}/i
                                  }) ++ [
                                    %{
                                      from: ~D[2021-10-20],
                                      organization_slug: "black-claws",
                                      title: "Black Claws x America's Navy",
                                      stats_slug: "black-claws-x-americas-navy",
                                      pattern: ~r/750 - Black Claws x America's Navy/i
                                    },
                                    %{
                                      from: ~D[2021-11-11],
                                      organization_slug: "black-claws",
                                      title: "Black Claws x Bang & Olufsen",
                                      stats_slug: "black-claws-x-bang-olufsen",
                                      pattern: ~r/Black Claws x Bang & Olufsen/i
                                    },
                                    %{
                                      from: ~D[2020-06-01],
                                      organization_slug: "juega-duro-hearthstone",
                                      title: "GRITO DE GUERRA",
                                      stats_slug: "grito-de-guerra",
                                      pattern: ~r/GRITO DE GUERRA/i
                                    },
                                    %{
                                      from: ~D[2020-06-01],
                                      organization_slug: "btw-esports",
                                      title: "Copa DoomHammer",
                                      stats_slug: "btw-copa-doomhammer",
                                      pattern: ~r/Copa DoomHammer/i
                                    },
                                    %{
                                      from: ~D[2020-06-01],
                                      organization_slug: "ilh-events",
                                      title: "ILH Events EU Open",
                                      stats_slug: "ilh-events-eu-open",
                                      pattern: ~r/ILH Events EU Open/i
                                    },
                                    %{
                                      from: ~D[2020-06-01],
                                      organization_slug: "osc-esports",
                                      title: "HearthStone Americas Open",
                                      stats_slug: "osc-hearthstone-americas-open",
                                      pattern: ~r/HearthStone Americas Open/i
                                    },
                                    %{
                                      from: ~D[2020-06-01],
                                      organization_slug: "osc-esports",
                                      title: "Leeroy Jenkins Cup",
                                      stats_slug: "osc-leeroy-jenkins-cup",
                                      pattern: ~r/Leeroy Jenkins Cup/i
                                    },
                                    %{
                                      from: ~D[2020-06-01],
                                      organization_slug: "osc-esports",
                                      title: "Zephrys the Great Tournament",
                                      stats_slug: "osc-zephrys-the-great-tournament",
                                      pattern: ~r/Zephrys the Great Tournament/i
                                    },
                                    %{
                                      from: ~D[2022-06-01],
                                      organization_slug: "classic-hearthstone",
                                      title: "Classic Hearthstone",
                                      stats_slug: "classic-hearthstone",
                                      pattern: ~r/Classic Hearthstone /i
                                    },
                                    %{
                                      from: ~D[2022-06-01],
                                      organization_slug: "classic-hearthstone",
                                      title: "Classic Hearthstone EU",
                                      stats_slug: "classic-hearthstone-eu",
                                      pattern: ~r/Classic Hearthstone EU/i
                                    },
                                    %{
                                      from: ~D[2022-06-01],
                                      organization_slug: "classic-hearthstone",
                                      title: "Classic Hearthstone NA",
                                      stats_slug: "classic-hearthstone-na",
                                      pattern: ~r/Classic Hearthstone NA/i
                                    }
                                  ]

  @spec get_stage_standings(Stage.t() | String.t()) :: [Standings.t()]
  def get_stage_standings(stage_id) when is_binary(stage_id) do
    stage_id
    |> get_stage()
    |> get_stage_standings()
  end

  def get_stage_standings(%{id: id, standing_ids: [_ | _]}) do
    Api.get_standings!(id)
  end

  def get_stage_standings(%{id: id, current_round: 1}) do
    create_standings_from_round1_matches(%{id: id})
  end

  def get_stage_standings(%{id: id, bracket: %{current_round_number: 0}}) do
    create_standings_from_round1_matches(%{id: id})
  end

  def get_stage_standings(%{id: _, current_round: 0}) do
    []
  end

  def get_stage_standings(%{id: id, current_round: current_round})
      when is_integer(current_round) do
    get_stage_round_standings(id, current_round)
  end

  def get_stage_standings(%{id: id, bracket: %{current_round_number: round}})
      when is_integer(round) do
    # sometimes the current round is not completely updated
    # I assume it won't lag behind by more than 1
    get_stage_round_standings(id, round + 1)
  end

  def get_stage_standings(stage) do
    create_standings_from_matches(stage)
  end

  def battlefy_id?(id), do: id |> String.match?(~r/^[a-f\d]{24}$/i)

  def get_stage_round_standings(stage_id, round) when round > 0 do
    case Api.get_round_standings(stage_id, round) do
      [] -> get_stage_round_standings(stage_id, round - 1)
      standings -> standings
    end
  end

  def get_stage_round_standings(_stage_id, _round), do: []

  @spec get_standings(tournament_id() | stage_id()) :: [Standings.t()]
  def get_standings(some_id) do
    with [] <- get_tournament_standings(some_id),
         stage when not is_nil(stage) <- get_stage(some_id),
         s when s in [nil, []] <- get_stage_standings(stage) do
      []
    else
      standings -> standings
    end
  end

  def create_standings_from_round1_matches(%{
        id: id
      }) do
    matches = get_matches(id, round: 1) || []

    # num_losers = Enum.count(matches, fn %{top: top, bottom: bottom} -> top.winner || bottom.winnere end)
    # num_people = matches
    # |> Enum.map(fn %{top: top, bottom: bottom} ->
    #   [top.team, bottom.team] |> Enum.filter() |> Enum.count()
    # end)
    # |> Enum.sum()
    # loser_pos = num_people - num_losers
    # in_progress_pos = num_losers + 1

    matches
    |> Enum.flat_map(fn %{top: top, bottom: bottom} ->
      {winners, losers, in_progress} =
        case {top.winner, bottom.winner} do
          {true, false} ->
            {[top], [bottom], []}

          {false, true} ->
            {[bottom], [top], []}

          # not yet finished
          {false, false} ->
            {[], [], [bottom, top]}

          {nil, nil} ->
            {[], [], [bottom, top]}

          # :shrug:
          _ ->
            {[], [], []}
        end

      losers_standings =
        losers
        |> Enum.map(fn l ->
          %Standings{
            team: l.team,
            place: 0,
            wins: 0,
            losses: 1
          }
        end)

      in_progress_standings =
        in_progress
        |> Enum.map(fn ip ->
          %Standings{team: ip.team, place: 0, wins: 0, losses: 0}
        end)

      winners_standings =
        winners
        |> Enum.map(fn w ->
          %Standings{team: w.team, place: 0, wins: 1, losses: 0}
        end)

      List.flatten([losers_standings, in_progress_standings, winners_standings])
    end)
    # remove byes and the opponents of people waiting
    |> Enum.filter(fn s -> s.team end)
    |> Enum.sort_by(fn s -> s.place end, :asc)
  end

  @spec find_auto_wins_losses([Match.t()]) :: {Map.t(), Map.t()}
  def find_auto_wins_losses(matches) do
    auto_wins =
      matches
      |> Enum.flat_map(fn
        %{top: %{winner: true, team: %{name: name}}, is_bye: true} ->
          [name]

        %{bottom: %{winner: true, team: %{name: name}}, is_bye: true} ->
          [name]

        # not counting these because of new masters tour qualifier rules
        # top.winner && (top.score == nil || top.score == 0) -> [top.team.name]
        # bottom.winner && (bottom.score == nil || bottom.score == 0) -> [bottom.team.name]
        # top.winner && top.ready_at != nil && bottom.ready_at == nil -> [top.team.name]
        # bottom.winner && top.ready_at == nil && bottom.ready_at != nil -> [bottom.team.name]
        _ ->
          []
      end)
      |> Enum.frequencies()

    auto_losses = %{}
    # matches
    # |> Enum.flat_map(fn %{double_loss: _double_loss, top: _top, bottom: _bottom} ->

    # cond do
    # not counting these because of new masters tour qualifier rules
    # double_loss -> [top.team.name, bottom.team.name]
    # top.ready_at != nil && bottom.ready_at == nil -> [bottom.team.name]
    # top.ready_at == nil && bottom.ready_at != nil -> [top.team.name]
    # true -> []
    # end
    # end)
    # |> Enum.frequencies()

    {auto_wins, auto_losses}
  end

  @spec create_single_elim_standings([Match.t()], integer) :: [Standings.t()]
  def create_single_elim_standings(matches, rounds) do
    {auto_wins, auto_losses} = find_auto_wins_losses(matches)

    matches
    |> Enum.flat_map(fn %{top: top, bottom: bottom, round_number: round_number} ->
      pos = (:math.pow(2, rounds - round_number) + 1) |> trunc()

      {winners, losers, in_progress} =
        case {top.winner, bottom.winner} do
          {true, false} ->
            {[top], [bottom], []}

          {false, true} ->
            {[bottom], [top], []}

          # not yet finished
          {false, false} ->
            {[], [], [bottom, top]}

          # :shrug
          _ ->
            {[], [], []}
        end

      losers_standings =
        losers
        |> Enum.map(fn l ->
          %Standings{
            team: l.team,
            place: pos,
            wins: round_number - 1,
            losses: 1,
            auto_wins: get_auto_wins(auto_wins, l.team),
            auto_losses: get_auto_losses(auto_losses, l.team)
          }
        end)

      in_progress_standings =
        in_progress
        |> Enum.map(fn ip ->
          %Standings{
            team: ip.team,
            place: 0,
            wins: round_number - 1,
            losses: 0,
            auto_wins: get_auto_wins(auto_wins, ip.team),
            auto_losses: get_auto_losses(auto_losses, ip.team)
          }
        end)

      winners_standings =
        if round_number == rounds,
          do:
            winners
            |> Enum.map(fn w ->
              %Standings{
                team: w.team,
                place: 1,
                wins: round_number,
                losses: 0,
                auto_wins: get_auto_wins(auto_wins, w.team),
                auto_losses: get_auto_losses(auto_losses, w.team)
              }
            end),
          else: []

      List.flatten([losers_standings, in_progress_standings, winners_standings])
    end)
    # remove byes and the opponents of people waiting
    |> Enum.filter(fn s -> s.team end)
    |> Enum.sort_by(fn s -> s.place end, :asc)
  end

  def get_auto_wins(auto_wins, %{name: name}), do: auto_wins[name] || 0
  def get_auto_wins(_, _), do: 0
  def get_auto_losses(auto_losses, %{name: name}), do: auto_losses[name] || 0
  def get_auto_losses(_, _), do: 0

  @spec create_standings_from_matches(Stage.t()) :: [Standings.t()]
  def create_standings_from_matches(%{
        id: id,
        bracket: bracket = %{type: "elimination", style: "single"}
      }) do
    {rounds, _max_position} =
      case {bracket.rounds_count, bracket.teams_count} do
        {nil, nil} -> raise "Handle this case d0nkey!"
        {nil, teams_count} -> {:math.log2(teams_count) |> Float.ceil() |> trunc(), teams_count}
        {rounds_count, nil} -> {rounds_count, :math.pow(2, rounds_count) |> trunc()}
        {rounds_count, teams_count} -> {rounds_count, teams_count}
      end

    id
    |> get_matches()
    |> create_single_elim_standings(rounds)
  end

  def create_standings_from_matches(%{id: id}),
    do: id |> get_matches() |> create_standings_from_matches()

  def create_standings_from_matches(matches = [_ | _]) do
    matches
    |> Enum.reduce(%{}, fn m = %{top: top, bottom: bottom}, acc ->
      acc
      |> add_team_to_stats(top, bottom, m)
      |> add_team_to_stats(bottom, top, m)
    end)
    |> Map.values()
  end

  def create_standings_from_matches(_) do
    nil
  end

  defp auto_win?(_, _, %{is_bye: true}), do: true

  defp auto_win?(winner, loser, _),
    do:
      winner.score == nil || winner.score == 0 ||
        (winner.ready_at != nil && loser.ready_at == nil)

  defp auto_loss?(_, _, %{double_loss: true}), do: true
  defp auto_loss?(w, l, m), do: auto_win?(w, l, m)

  def add_team_to_stats(team_map, t = %{team: team = %{name: name}}, opponent, m) do
    standings =
      team_map |> Map.get(name) ||
        %Standings{
          team: team,
          place: 0,
          wins: 0,
          losses: 0,
          auto_wins: 0,
          auto_losses: 0
        }

    new_standings =
      cond do
        t.winner ->
          %{
            standings
            | wins: standings.wins + 1,
              auto_wins: standings.auto_wins + if(auto_win?(t, opponent, m), do: 1, else: 0)
          }

        opponent.winner || m.double_loss ->
          %{
            standings
            | losses: standings.losses + 1,
              auto_losses: standings.auto_losses + if(auto_loss?(opponent, t, m), do: 1, else: 0)
          }

        true ->
          standings
      end

    team_map
    |> Map.put(name, new_standings)
  end

  def add_team_to_stats(team_map, _, _, _), do: team_map

  def get_all_tournament_standings(%{stage_ids: stage_ids}),
    do: stage_ids |> Enum.map(&get_stage_standings/1)

  def get_all_tournament_standings(tournament_id),
    do: tournament_id |> get_tournament() |> get_all_tournament_standings()

  @spec get_stage(stage_id) :: Stage.t()
  def get_stage(stage_id) do
    Api.get_stage(stage_id)
  end

  @spec get_tournament_standings_and_stage_id(Tournament.t()) ::
          {:ok, {stage_id(), [Standings.t()]}} | :error
  def get_tournament_standings_and_stage_id(%{stage_ids: stage_ids}) do
    result =
      stage_ids
      |> Enum.reverse()
      |> Enum.find_value(fn id ->
        id
        |> Api.get_stage()
        |> get_stage_standings()
        |> case do
          [] -> nil
          s -> {id, s}
        end
      end)

    case result do
      nil -> :error
      result -> {:ok, result}
    end
  end

  @spec get_tournament_standings(tournament_id() | Tournament.t() | %{stage_ids: [stage_id]}) :: [
          Standings.t()
        ]
  def get_tournament_standings(id) when is_binary(id) or is_integer(id),
    do: get_tournament(id) |> get_tournament_standings()

  def get_tournament_standings(%Tournament{} = tournament) do
    case get_tournament_standings_and_stage_id(tournament) do
      {:ok, {_, standings}} ->
        standings

      _ ->
        []
    end
  end

  @spec stage_id_for_standings(Tournament.t()) :: stage_id()
  def stage_id_for_standings(%{stage_ids: stage_ids}) do
    stage_ids
    |> Enum.reverse()
  end

  @spec get_tournament(tournament_id) :: Tournament.t()
  def get_tournament(tournament_id) do
    Api.get_tournament(tournament_id)
  end

  @spec get_tournament_matches(
          Tournament.t() | %{stage_ids: [stage_id]},
          get_tournament_matches_options
        ) :: [Match.t()]
  def get_tournament_matches(id_or_tournament, opts \\ [])

  def get_tournament_matches(%{stage_ids: stage_ids}, opts) do
    stage_ids
    |> Enum.at(opts[:stage] || 0)
    |> get_matches(Util.reject_keys(opts, [:stage]))
  end

  @spec get_tournament_matches(tournament_id, get_tournament_matches_options) :: [Match.t()]
  def get_tournament_matches(tournament_id, opts) do
    tournament_id
    |> get_tournament()
    |> get_tournament_matches(opts)
  end

  @spec get_matches(stage_id | Stage.t(), get_matches_options) :: [Match.t()]
  def get_matches(stage_or_id, opts \\ [])
  def get_matches(%Stage{id: id}, opts), do: get_matches(id, opts)

  def get_matches(stage_id, opts) do
    Api.get_matches(stage_id, opts)
  end

  @spec get_future_and_player_stage_matches(stage_id, String.t()) :: [Match.t()]
  def get_future_and_player_stage_matches(stage_id, team_name),
    do: stage_id |> get_stage() |> get_future_and_player_matches(team_name)

  @spec get_future_and_player_matches(Stage.t(), String.t()) :: [Match.t()]
  def get_future_and_player_matches(%Stage{id: _id} = stage, team_name) do
    do_get_future_and_player_matches([stage], team_name)
  end

  @spec get_future_and_player_matches(tournament_id, String.t()) :: [Match.t()]
  def get_future_and_player_matches(tournament_id, team_name) when is_binary(tournament_id) do
    tournament_id
    |> get_tournament()
    |> Map.get(:stages)
    |> do_get_future_and_player_matches(team_name)
  end

  def get_future_and_player_matches(_, _), do: {[], [], nil}

  defp do_get_future_and_player_matches([], _), do: {[], [], nil}

  defp do_get_future_and_player_matches([%Stage{id: id} | rest], team_name) do
    matches = get_matches(id)
    # total_rounds = stage.bracket && stage.bracket.rounds_count

    player_matches =
      matches
      |> Match.filter_team(team_name)
      |> Match.sort_by_round(:desc)

    case player_matches do
      [latest | _] ->
        future_opponents = future_opponents(matches, latest)
        # future_opponents = get_future_opponents(matches, total_rounds, team_name)

        {future_opponents, player_matches, id}

      [] ->
        do_get_future_and_player_matches(rest, team_name)
    end
  end

  def future_opponents(matches, %{
        id: id,
        next: %{winner: winner, loser: loser},
        top: %{team: top},
        bottom: %{team: bottom}
      })
      when top != nil and bottom != nil do
    %{
      winner: future_opponents(matches, winner, id),
      waiting: [],
      loser: future_opponents(matches, loser, id)
    }
  end

  def future_opponents(matches, %{id: id}) do
    %{
      winner: [],
      waiting: possible_future_opponents(matches, id, id),
      loser: []
    }
  end

  def future_opponents(_, _), do: %{winner: [], loser: [], waiting: []}

  @spec future_opponents([Match.t()], Match.NextRound.t() | nil, String.t() | match_id()) :: [
          Match.t()
        ]
  def future_opponents(matches, %{match_id: match_id}, id) do
    possible_future_opponents(matches, match_id, id)
  end

  def future_opponents(_, _, _), do: []

  def possible_future_opponents(matches, future_match_id, current_match_id \\ nil) do
    matches
    |> Enum.filter(
      &(Map.get(&1, :next) |> Next.has_match_id?(future_match_id) && &1.id != current_match_id)
    )
    |> Enum.flat_map(fn
      %{top: %{winner: top}, bottom: %{winner: bot}} when top == true or bot == true ->
        []

      match = %{top: %{winner: false, team: top}, bottom: %{winner: false, team: bot}}
      when top != nil and bot != nil ->
        [match]

      match ->
        [match | possible_future_opponents(matches, match.id)]
    end)
  end

  @spec get_future_opponents(tournament_id, String.t()) :: [Match.t()]
  def get_future_opponents(tournament_id, team_name) do
    tournament = Api.get_tournament(tournament_id)
    [stage | _] = tournament.stages
    matches = get_matches(stage.id)
    get_future_opponents(stage, matches, team_name)
  end

  def get_future_opponents(
        stage = %{bracket: %{type: "elimination", style: "single"}},
        matches,
        team_name
      ) do
    total_rounds = stage.bracket && stage.bracket.rounds_count
    get_future_opponents(matches, total_rounds, team_name)
  end

  def get_future_opponents(%{}, _, _), do: []

  @spec get_future_opponents([Match.t()], integer, String.t()) :: [Match.t()]
  def get_future_opponents(matches, total_rounds, team_name) do
    latest_team_game =
      %{top: top, bottom: bottom} =
      matches
      |> Match.filter_team(team_name)
      |> case do
        [] -> %{top: nil, bottom: nil}
        matches -> matches |> Enum.max_by(fn %{round_number: rn} -> rn end)
      end

    case {top, bottom} do
      {%{team: nil}, _} ->
        latest_team_game
        |> BattlefyUtil.prev_top(matches, total_rounds)
        |> get_future_from_previous(matches, total_rounds)

      {_, %{team: nil}} ->
        latest_team_game
        |> BattlefyUtil.prev_bottom(matches, total_rounds)
        |> get_future_from_previous(matches, total_rounds)

      {%{winner: false}, %{winner: false}} ->
        get_future_from_next(latest_team_game, matches, total_rounds)

      _ ->
        []
    end
  end

  @spec get_future_from_next(Match.t(), [Match.t()], integer) :: [Match.t()]
  def get_future_from_next(
        %{match_number: match_number, round_number: round_number},
        matches,
        total_rounds
      ) do
    next_match_num = BattlefyUtil.next_round_match(match_number, round_number, total_rounds)

    with %{top: %{team: nil}, bottom: %{team: nil}} <- matches |> Match.find(next_match_num),
         neighbor_num when is_integer(neighbor_num) <-
           BattlefyUtil.get_neighbor(match_number, round_number, total_rounds) do
      matches
      |> Match.find(neighbor_num)
      |> get_future_from_previous(matches, total_rounds)
    else
      nil -> []
      next_match -> [next_match]
    end
  end

  @spec get_future_from_previous(Match.t(), [Match.t()], integer) :: [Match.t()]
  def get_future_from_previous(nil, _, _) do
    []
  end

  @spec get_future_from_previous(Match.t(), [Match.t()], integer) :: [Match.t()]
  def get_future_from_previous(match = %{round_number: 1}, _, _) do
    [match]
  end

  @spec get_future_from_previous(Match.t(), [Match.t()], integer) :: [Match.t()]
  def get_future_from_previous(
        match = %{top: top, bottom: bottom},
        matches,
        total_rounds
      ) do
    prev_top = BattlefyUtil.prev_top(match, matches, total_rounds)
    prev_bottom = BattlefyUtil.prev_bottom(match, matches, total_rounds)

    case {top.team, bottom.team} do
      {nil, nil} ->
        Enum.flat_map([prev_top, prev_bottom], fn m ->
          get_future_from_previous(m, matches, total_rounds)
        end)

      {nil, _} ->
        [match | get_future_from_previous(prev_top, matches, total_rounds)]

      {_, nil} ->
        [match | get_future_from_previous(prev_bottom, matches, total_rounds)]

      _ ->
        [match]
    end
  end

  @spec get_deckstrings(%{stage_id: stage_id, tournament_id: tournament_id}, [
          Blizzard.battletag()
        ]) :: Map.t()
  def get_deckstrings(info = %{tournament_id: tournament_id}, battletags)
      when is_list(battletags) do
    matches = get_deckstrings_matches(info)

    Util.async_map(battletags, fn btag ->
      case get_team_match_position(matches, btag) do
        {match, position} ->
          deckstrings =
            get_match_deckstrings(tournament_id, match.id)
            |> MatchDeckstrings.get(position)
            |> Enum.map(&MatchDeckstrings.remove_comments/1)

          {btag, deckstrings}

        _ ->
          nil
      end
    end)
    |> Enum.filter(& &1)
    |> Map.new()
  end

  def get_match_deckstrings(tournament_id, match_id),
    do: Api.get_match_deckstrings(tournament_id, match_id)

  @spec get_deckstrings(%{
          stage_id: stage_id | nil,
          tournament_id: tournament_id,
          battletag_full: Blizzard.battletag()
        }) ::
          [Blizzard.deckstring()]
  def get_deckstrings(info = %{battletag_full: battletag_full}) do
    get_deckstrings(info, [battletag_full]) |> Map.get(battletag_full)
  end

  defp get_deckstrings_matches(%{stage_id: stage_id}) when is_binary(stage_id),
    do: get_matches(stage_id)

  defp get_deckstrings_matches(%{tournament_id: tournament_id}),
    do: get_tournament_matches(tournament_id, round: 1)

  @spec get_team_match_position([Match.t()], Blizzard.battletag()) :: {Match.t(), atom()}
  def get_team_match_position(matches, battletag_full) do
    matches
    |> Enum.flat_map(fn m ->
      cond do
        battletag_full == MatchTeam.get_name(m.top) -> [{m, :top}]
        battletag_full == MatchTeam.get_name(m.bottom) -> [{m, :bottom}]
        true -> []
      end
    end)
    |> Enum.at(0)
  end

  @spec regions :: [region]
  def regions() do
    @regions
  end

  @spec regions(:string) :: [String.t()]
  def regions(:string) do
    Enum.map(@regions, &to_string/1)
  end

  def get_hsdeckviewer_link(get_deckstrings_options) do
    get_deckstrings_options
    |> get_deckstrings()
    |> Backend.HSDeckViewer.create_link()
  end

  @spec get_match_url(Tournament.t(), Match.t()) :: String.t()
  def get_match_url(
        %{id: tournament_id, slug: tournament_slug, organization: %{slug: org_slug}},
        %{id: match_id, stage_id: stage_id}
      ) do
    "https://battlefy.com/#{org_slug}/#{tournament_slug}/#{tournament_id}/stage/#{stage_id}/match/#{match_id}"
  end

  @spec get_tour_stop_id!(Blizzard.tour_stop()) :: tournament_id()
  def get_tour_stop_id!(tour_stop) do
    case get_tour_stop_id(tour_stop) do
      {:ok, id} -> id
      {:error, reason} -> reason
    end
  end

  @spec get_tour_stop_id(Blizzard.tour_stop()) :: {:ok, tournament_id()} | {:error, String.t()}
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_tour_stop_id(tour_stop) do
    Backend.MastersTour.TourStop.get_battlefy_id(tour_stop)
  end

  def create_tournament_link(tournament_id) when is_binary(tournament_id),
    do: get_tournament(tournament_id) |> create_tournament_link()

  def create_tournament_link(%{slug: slug, id: id, organization: %{slug: org_slug}}) do
    create_tournament_link(slug, id, org_slug)
  end

  def create_tournament_link(slug, id, org_slug) do
    "https://battlefy.com/#{org_slug}/#{slug}/#{id}/info"
  end

  def hardcoded_organization_slugs(), do: @organization_slugs

  def organization_stats(org_slug),
    do: @organization_stats_configs |> Enum.filter(&Kernel.==(&1.organization_slug, org_slug))

  def stats_config(stats_slug),
    do: @organization_stats_configs |> Enum.find(&Kernel.==(&1.stats_slug, stats_slug))

  def hardcoded_organizations() do
    hardcoded_organization_slugs()
    |> Enum.map(&Api.get_organization/1)
    |> Enum.filter(&Util.id/1)
  end

  def get_stats_stage_standings(s = %Stage{}) do
    if s |> Stage.bracket_type() == :single_elimination do
      s |> create_standings_from_matches()
    else
      s |> get_stage_standings()
    end
  end

  def create_tournament_stats(%{stage_ids: stage_ids, name: name, id: id}) do
    stage_ids
    |> Enum.map(&get_stage/1)
    |> Enum.map(fn s ->
      bracket_type = s |> Stage.bracket_type()
      standings = s |> get_stats_stage_standings()
      {bracket_type, standings}
    end)
    |> Backend.TournamentStats.create_tournament_team_stats(name, id)
  end

  @doc """
  Extracts the tournament id from a link to the tournament

  ## Example
    iex> Backend.Battlefy.tournament_link_to_id("https://battlefy.com/tierras-de-fuego-hs/el-camino-de-kaelthas-20/5f5bc93e0c405a2571493bf4/info?infoTab=details")
    "5f5bc93e0c405a2571493bf4"
    iex> Backend.Battlefy.tournament_link_to_id("https://battlefy.com/tierras-de-fuego-hs/el-camino-de-kaelthas-20/5f5bc93e0c405a2571493bf4/stage/5f888122a9c3434f84077e3e/match/5f88827f97c3d42eac842b06")
    "5f5bc93e0c405a2571493bf4"
    iex> Backend.Battlefy.tournament_link_to_id("5f5bc93e0c405a2571493bf4")
    "5f5bc93e0c405a2571493bf4"
    iex> Backend.Battlefy.tournament_link_to_id("5f5bc93e0c405a2571493bf4 #bla bla bla, this should be ignored")
    "5f5bc93e0c405a2571493bf4"
  """
  @spec tournament_link_to_id(String.t() | tournament_id()) :: tournament_id()
  def tournament_link_to_id(id = <<_::192>>), do: id

  def tournament_link_to_id(link) do
    no_comments =
      link
      |> String.replace(~r/#.*/, "")
      |> String.trim()

    if 24 == String.length(no_comments) do
      no_comments
    else
      no_comments
      |> String.replace(~r/http.*battlefy.com/, "")
      |> String.split("/")
      |> Enum.at(3)
    end
  end

  @spec lineups(tournament_id) :: [Lineup]
  def lineups(tournament_id) do
    case Hearthstone.get_lineups(tournament_id, "battlefy") do
      lineups = [_ | _] ->
        lineups

      _ ->
        Backend.Battlefy.LineupFetcher.fetch_async(tournament_id)
        []
    end
  end

  @spec get_participants(String.t()) :: [Team.t()]
  def get_participants(tournament_id) do
    Api.get_participants(tournament_id)
  end

  @spec get_match!(String.t()) :: Match.t()
  def get_match!(match_id) do
    Api.get_match!(match_id)
  end

  @spec get_organization_tournaments(String.t(), Date.t(), Date.t(), boolean) :: [Tournament.t()]
  def get_organization_tournaments(slug_or_id, from, to, only_hearthstone \\ true) do
    org_id =
      case Api.get_organization(slug_or_id) do
        %{id: id} -> id
        _ -> slug_or_id
      end

    Api.get_organization_tournaments_from_to(org_id, from, to)
    |> filter_hearthstone(only_hearthstone)
  end

  @spec filter_hearthstone([Tournament.t()], only_hearthstone :: boolean()) :: [Tournament.t()]
  def filter_hearthstone(tournaments, false), do: tournaments
  def filter_hearthstone(tournaments, true), do: filter_hearthstone(tournaments)

  @spec filter_hearthstone([Tournament.t()]) :: [Tournament.t()]
  def filter_hearthstone(tournaments),
    do: Enum.filter(tournaments, &Tournament.Game.is_hearthstone/1)

  @spec sort_standings([Standings.t()]) :: [Standings.t()]
  def sort_standings(standings) do
    standings
    |> Enum.sort_by(fn s -> String.upcase(s.team.name) end)
    |> Enum.sort_by(fn s -> s.losses end)
    |> Enum.sort_by(fn s -> s.wins end, :desc)
    |> Enum.sort_by(fn s -> s.place end)
  end

  def custom_field_value(struct, field_id, default \\ nil)

  def custom_field_value(%{team: t}, field_id, default),
    do: custom_field_value(t, field_id, default)

  def custom_field_value(struct, field_id, default),
    do: CustomField.value(struct, field_id, default)

  def merge_standings_by_custom_field(
        standings,
        field_id,
        opts \\ [value_mapper: & &1, display_map: %{}]
      ) do
    merged_opts = Keyword.merge([value_mapper: & &1, display_map: %{}], opts)
    mapper = Keyword.get(merged_opts, :value_mapper)
    display_map = Keyword.get(merged_opts, :display_map)

    standings
    |> Enum.group_by(fn s ->
      with val when not is_nil(val) <- custom_field_value(s, field_id) do
        mapper.(val)
      end
    end)
    |> Map.drop([nil])
    |> Enum.map(fn {grouped_by, standings} ->
      new_name = Map.get(display_map, grouped_by, grouped_by)
      merge_standings(standings, new_name)
    end)
  end

  @doc "Merge the win/loss record of the `standings` together into one fake standings with the team name `name`"
  @spec merge_standings([Standings.t()], String.t()) :: Standings.t()
  def merge_standings(standings, name \\ nil) do
    # use the first team name if no name supplied
    name_to_use = name || get_in(standings, [Access.at(0), Access.key(:team), Access.key(:name)])

    merged =
      Enum.reduce(standings, %{wins: 0, losses: 0, auto_wins: 0, auto_losses: 0}, fn s, acc ->
        %{
          wins: (Map.get(s, :wins) || 0) + acc.wins,
          auto_wins: (Map.get(s, :auto_wins) || 0) + acc.auto_wins,
          losses: (Map.get(s, :losses) || 0) + acc.losses,
          auto_losses: (Map.get(s, :auto_losses) || 0) + acc.auto_losses
        }
      end)

    %Standings{
      losses: merged.losses,
      wins: merged.wins,
      auto_losses: merged.auto_losses,
      auto_wins: merged.auto_wins,
      place: nil,
      team: %Team{
        players: [],
        name: name_to_use
      }
    }
  end

  def set_lineup_display_name_with_stages(
        tournament_id,
        stage_name_regex \\ ".",
        regex_flags \\ "i"
      ) do
    regex = Regex.compile!(stage_name_regex, regex_flags)
    tournament = get_tournament(tournament_id)
    lineups = lineups(tournament_id)
    lineup_player_map = Map.new(lineups, &{&1.name, &1})

    player_stage_tuples =
      for stage <- tournament.stages,
          Regex.match?(regex, stage.name),
          %{team: %{name: name}} <- get_stage_standings(stage.id),
          Map.has_key?(lineup_player_map, name) do
        {name, stage.name}
      end

    Enum.group_by(player_stage_tuples, &elem(&1, 0), &elem(&1, 1))
    |> Enum.reduce(Ecto.Multi.new(), fn {name, stage_names}, multi ->
      stage_prefix = Enum.sort(stage_names) |> Enum.join(" | ")
      display_name = "#{stage_prefix} - #{name}"

      case Map.get(lineup_player_map, name) do
        %{id: id} = lineup ->
          cs = Lineup.set_display_name(lineup, display_name)
          Ecto.Multi.update(multi, "set_lineup_display_name_#{id}", cs)

        _ ->
          multi
      end
    end)
    |> Backend.Repo.transaction()
  end
end
