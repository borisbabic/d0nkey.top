defmodule Backend.FantasyCompetitionFetcher do
  @moduledoc false
  alias Backend.Fantasy.Competition.Participant
  alias Backend.MastersTour.TourStop
  alias Backend.Battlefy
  alias Backend.Hearthstone
  alias Backend.Infrastructure.GrandmastersCommunicator
  alias Backend.Blizzard
  alias Backend.MastersTour
  alias Backend.Grandmasters.Response, as: GM

  def get_participants(%{competition_type: "card_changes"}) do
    Backend.HearthstoneJson.playable_cards()
    |> Enum.map(&%Participant{name: &1.name})
    |> Enum.uniq_by(& &1.name)
  end

  def get_participants(%{competition_type: "battlefy", competition: battlefy_id}) do
    battlefy_id
    |> get_battlefy_participants()
    |> Enum.map(&%Participant{name: &1.name})
  end

  @spec get_participants(League.t()) :: [Participant.t()]
  def get_participants(%{competition_type: "masters_tour", competition: competition}) do
    normalize_name = &Backend.Battlenet.Battletag.shorten/1

    battlefy_particpants =
      competition
      |> TourStop.get()
      |> case do
        %{battlefy_id: bid} when is_binary(bid) -> bid |> get_battlefy_participants()
        _ -> []
      end
      |> MapSet.new(&(&1.name |> normalize_name.()))

    competition
    |> MastersTour.list_officially_invited_players()
    |> Enum.map(fn ip ->
      signed_up_in_battlefy =
        battlefy_particpants |> MapSet.member?(ip.battletag_full |> normalize_name.())

      %Participant{name: ip.battletag_full, meta: %{in_battlefy: signed_up_in_battlefy}}
    end)
  end

  def current_round("grandmasters", <<"gm_"::binary, gm_season_raw::binary>>) do
    with {:ok, gm_season} <- Hearthstone.parse_gm_season(gm_season_raw),
         {_, round} <- Blizzard.current_gm_week(gm_season) do
      round
    else
      _ -> 1
    end
  end

  def current_round(_, _), do: 1

  def get_participants(%{
        competition_type: "grandmasters",
        competition: <<"gm_"::binary, gm_season_raw::binary>>
      }) do
    gm_season_raw
    |> Hearthstone.parse_gm_season()
    |> case do
      {:ok, gm_season} ->
        Backend.PlayerInfo.get_grandmasters(gm_season)
        |> Enum.sort_by(&String.upcase/1)
        |> Enum.map(&%Participant{name: &1})

      _ ->
        []
    end
  end

  defp gm_stage_matching(season, round), do: Blizzard.gm_week_title(season, round)

  defp get_battlefy_participants(tournament_id) do
    tournament_id
    |> Battlefy.get_participants()
    |> Enum.map(fn p ->
      %Participant{
        name: p.name
      }
    end)
  end

  def fetch_results(l), do: fetch_results(l, 1)

  def fetch_results(l = %{competition_type: "battlefy", competition: competition}, _),
    do: get_battlefy_results(competition, l)

  def fetch_results(%{competition_type: "card_changes", competition: _competition}, _), do: []

  def fetch_results(
        %{
          competition_type: "grandmasters",
          competition: <<"gm_"::binary, gm_season_raw::binary>>
        },
        round
      ) do
    # gm = GrandmastersCommunicator.get_gm()
    # gm |> GM.results(current_week)

    with {:ok, season} <- gm_season_raw |> Hearthstone.parse_gm_season(),
         {:ok, matcher} <- gm_stage_matching(season, round),
         gm <- GrandmastersCommunicator.get_gm() do
      gm |> GM.results(matcher)
    else
      _other ->
        %{}
    end
  end

  def fetch_results(
        %{
          competition_type: "masters_tour",
          competition: competition,
          point_system: "gm_points_2021"
        },
        _
      ) do
    competition
    |> Backend.MastersTour.get_ts_points_ranking(:points_2021)
    |> Map.new()
  end

  def fetch_results(l = %{competition_type: "masters_tour", competition: competition}, _) do
    competition
    |> TourStop.get()
    |> case do
      %{battlefy_id: bid} when is_binary(bid) -> bid |> get_battlefy_results(l)
      _ -> %{}
    end
  end

  def get_battlefy_results(_tournament_id, %{point_system: "total_wins"}) do
    %{}
    # raise "NOT WORKING RIGHT"
    ## single elim wins aren't being counted right :(
    # %{stages: stages} = tournament_id
    # |> Battlefy.get_tournament()
    # stages
    # |> sum_bf_wins()
  end

  def get_battlefy_results(tournament_id, %{point_system: "swiss_wins"}) do
    %{stages: stages} =
      tournament_id
      |> Battlefy.get_tournament()

    stages
    |> case do
      nil ->
        %{}

      s ->
        s
        |> Enum.filter(&(:swiss == &1 |> Battlefy.Stage.bracket_type()))
        |> sum_bf_wins()
    end
  end

  defp sum_bf_wins(stages = [%Battlefy.Stage{} | _]) do
    stages
    |> Enum.flat_map(&Battlefy.get_stage_standings/1)
    |> Enum.reduce(%{}, fn s, carry ->
      carry |> Map.update(s.team.name, s.wins, &(&1 + (s.wins || 0)))
    end)
  end

  defp sum_bf_wins(_), do: %{}
end
