defmodule Backend.Battlefy do
  alias Backend.Infrastructure.BattlefyCommunicator, as: Api
  alias Backend.Battlefy.Tournament
  alias Backend.Battlefy.Standings
  alias Backend.Battlefy.MatchTeam

  # 192 = 24 (length of id) * 8 (bits in a byte)
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

    get_matches(id)
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
          %Standings{team: l.team, place: pos, wins: round_number - 1, losses: 1}
        end)

      in_progress_standings =
        in_progress
        |> Enum.map(fn ip ->
          %Standings{team: ip.team, place: 0, wins: round_number - 1, losses: 0}
        end)

      winners_standings =
        if round_number == rounds,
          do:
            winners
            |> Enum.map(fn w ->
              %Standings{team: w.team, place: 1, wins: round_number, losses: 0}
            end),
          else: []

      List.flatten([losers_standings, in_progress_standings, winners_standings])
    end)
    # remove byes and the opponents of people waiting
    |> Enum.filter(fn s -> s.team end)
    |> Enum.sort_by(fn s -> s.place end, :asc)
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

  # todo move this somewhere else
  def get_hsdeckviewer_link(get_deckstrings_options) do
    get_deckstrings_options
    |> get_deckstrings()
    |> Backend.HSDeckViewer.create_link()
  end
end
