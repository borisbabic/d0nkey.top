defmodule Backend.Battlefy do
  @moduledoc false
  alias Backend.Infrastructure.BattlefyCommunicator, as: Api
  alias Backend.Battlefy.Tournament
  alias Backend.Battlefy.Standings
  alias Backend.Battlefy.MatchTeam
  alias Backend.Battlefy.Match
  alias Backend.BattlefyUtil

  # 192 = 24 (length of id) * 8 (bits in a byte)
  @type region :: :Asia | :Europe | :Americas
  @regions [:Americas, :Asia, :Europe]
  @type battlefy_id :: <<_::192>>
  @type tournament_id :: battlefy_id
  @type user_id :: battlefy_id
  @type team_id :: battlefy_id
  @type stage_id :: battlefy_id
  @type match_id :: battlefy_id
  @type get_matches_opt :: {:round, integer()}
  @type get_matches_options :: [get_matches_opt]
  @type get_tournament_matches_opt :: {:stage, integer()} | get_matches_opt
  @type get_tournament_matches_options :: [get_tournament_matches_opt]

  def get_stage_standings(stage_id) when is_binary(stage_id) do
    stage_id
    |> Api.get_stage()
    |> get_stage_standings()
  end

  def get_stage_standings(%{id: id, standing_ids: [_ | _]}) do
    Api.get_standings(id)
  end

  def get_stage_standings(%{id: id, current_round: 1}) do
    create_standings_from_round1_matches(%{id: id})
  end

  def get_stage_standings(%{id: id, current_round: current_round})
      when is_integer(current_round) do
    Api.get_round_standings(id, current_round)
  end

  def get_stage_standings(stage) do
    create_standings_from_matches(stage)
  end

  def create_standings_from_round1_matches(%{
        id: id
      }) do
    matches = get_matches(id, %{round: 1})

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

          # :shrug
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

  @spec create_single_elim_standings([Match.t()], integer) :: [Standings.t()]
  def create_single_elim_standings(matches, rounds) do
    byes =
      matches
      |> Enum.flat_map(fn %{top: top, bottom: bottom, is_bye: is_bye} ->
        cond do
          is_bye && top.winner -> [top.team.name]
          is_bye && bottom.winner -> [bottom.team.name]
          top.winner && (top.score == nil || top.score == 0) -> [top.team.name]
          bottom.winner && (bottom.score == nil || bottom.score == 0) -> [bottom.team.name]
          true -> []
        end
      end)
      |> Enum.frequencies()

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
            byes: get_byes(byes, l.team)
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
            byes: get_byes(byes, ip.team)
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
                byes: get_byes(byes, w.team)
              }
            end),
          else: []

      List.flatten([losers_standings, in_progress_standings, winners_standings])
    end)
    # remove byes and the opponents of people waiting
    |> Enum.filter(fn s -> s.team end)
    |> Enum.sort_by(fn s -> s.place end, :asc)
  end

  def get_byes(byes, %{name: name}), do: byes[name] || 0
  def get_byes(_, _), do: 0

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

  def get_standings_from_matches() do
    nil
  end

  @spec get_tournament_standings(Tournament.t() | %{stage_ids: [stage_id]}) :: [Standings.t()]
  def get_tournament_standings(%{stage_ids: stage_ids}) do
    case stage_ids
         |> Enum.reverse()
         |> Enum.find_value(fn id ->
           id
           |> Api.get_stage()
           |> get_stage_standings()
         end) do
      nil -> []
      standings -> standings
    end
  end

  @spec get_tournament_standings(tournament_id) :: [Standings.t()]
  def get_tournament_standings(tournament_id) do
    tournament_id
    |> get_tournament()
    |> get_tournament_standings()
  end

  @spec get_tournament(tournament_id) :: Tournament.t()
  def get_tournament(tournament_id) do
    Api.get_tournament(tournament_id)
  end

  def get_tournament_matches(id_or_tournament, opts \\ [])

  @spec get_tournament_matches(
          Tournament.t() | %{stage_ids: [stage_id]},
          get_tournament_matches_options
        ) :: [Match.t()]
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

  @spec get_matches(stage_id, get_matches_options) :: [Match.t()]
  def get_matches(stage_id, opts \\ []) do
    Api.get_matches(stage_id, opts)
  end

  @spec get_future_and_player_matches(tournament_id, String.t()) :: [Match.t()]
  def get_future_and_player_matches(tournament_id, team_name) do
    tournament = Api.get_tournament(tournament_id)
    [stage | _] = tournament.stages
    matches = get_matches(stage.id)
    total_rounds = stage.bracket && stage.bracket.rounds_count
    future_opponents = get_future_opponents(matches, total_rounds, team_name)

    player_matches =
      matches
      |> Match.filter_team(team_name)
      |> Match.sort_by_round(:desc)

    {future_opponents, player_matches}
  end

  @spec get_matches(tournament_id, String.t()) :: [Match.t()]
  def get_future_opponents(tournament_id, team_name) do
    tournament = Api.get_tournament(tournament_id)
    [stage | _] = tournament.stages
    matches = get_matches(stage.id)
    total_rounds = stage.bracket && stage.bracket.rounds_count
    get_future_opponents(matches, total_rounds, team_name)
  end

  @spec get_future_opponents([Match.t()], integer, String.t()) :: [Match.t()]
  def get_future_opponents(matches, total_rounds, team_name) do
    latest_team_game =
      %{top: top, bottom: bottom} =
      matches
      |> Match.filter_team(team_name)
      |> Enum.max_by(fn %{round_number: rn} -> rn end)

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

  @spec get_deckstrings(%{tournament_id: tournament_id, battletag_full: Blizzard.battletag()}) ::
          [Blizzard.deckstring()]
  def get_deckstrings(%{tournament_id: tournament_id, battletag_full: battletag_full}) do
    {position, match} =
      get_tournament_matches(tournament_id, round: 1)
      |> Enum.flat_map(fn m ->
        cond do
          battletag_full == MatchTeam.get_name(m.top) -> [{:top, m}]
          battletag_full == MatchTeam.get_name(m.bottom) -> [{:bottom, m}]
          true -> []
        end
      end)
      |> Enum.at(0)

    deckstrings = Api.get_match_deckstrings(tournament_id, match.id)

    case position do
      :top -> deckstrings.top
      :bottom -> deckstrings.bottom
    end
    |> Enum.map(&Backend.Battlefy.MatchDeckstrings.remove_comments/1)
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
    "https://battlefy.com/#{org_slug}/#{tournament_slug}/#{tournament_id}/stage/#{stage_id}/match/#{
      match_id
    }"
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
    id_unknown = {:error, "ID unknown for tour stop"}

    case tour_stop do
      :LasVegas -> {:ok, "5cdb04cdce130203069be2dd"}
      :Seoul -> {:ok, "5d3117357045a2325e167ad6"}
      :Bucharest -> {:ok, "5d8276701d82bf1a20dbf45b"}
      :Arlington -> {:ok, "5e1cf8ff1e66fd33ebbfc0ed"}
      :Indonesia -> {:ok, "5e5d80217506f5240ebad221"}
      # edit_hs_decks "5ec9a33da4d7bf2e78ec166a"
      :Jönköping -> id_unknown
      :"Asia-Pacific" -> id_unknown
      :Montreal -> id_unknown
      _ -> {:error, "Unknown tour stop #{tour_stop}"}
    end
  end
end
