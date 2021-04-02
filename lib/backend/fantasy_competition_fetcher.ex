defmodule Backend.FantasyCompetitionFetcher do
  @moduledoc false
  alias Backend.Fantasy.Competition.Participant
  alias Backend.MastersTour.TourStop
  alias Backend.Battlefy
  alias Backend.Hearthstone
  @spec get_participants(League.t()) :: [Participant.t()]
  def get_participants(%{competition_type: "masters_tour", competition: competition}) do
    competition
    |> TourStop.get()
    |> case do
      %{battlefy_id: bid} when is_binary(bid) -> bid |> get_battlefy_participants()
      _ -> []
    end
  end

  def get_participants(%{
        competition_type: "grandmasters",
        competition: <<"gm_"::binary, gm_season_raw::binary>>
      }) do
    gm_season_raw
    |> Hearthstone.parse_gm_season()
    |> case do
      {:ok, gm_season} ->
        Backend.PlayerInfo.get_grandmasters(gm_season) |> Enum.map(&%Participant{name: &1})

      _ ->
        []
    end
  end

  def fetch_results(%{
        competition_type: "grandmasters",
        competition: <<"gm_"::binary, _gm_season_raw::binary>>
      }) do
    []
    # with {:ok, } <- gm_season_raw |> Hearthstone.parse_gm_season(),
    # [] <- ret do
    # ret
    # else
    # _ -> []
    # end
  end

  defp get_battlefy_participants(tournament_id) do
    tournament_id
    |> Battlefy.get_participants()
    |> Enum.map(fn p ->
      %Participant{
        name: p.name
      }
    end)
  end

  def fetch_results(%{
        competition_type: "masters_tour",
        competition: competition,
        point_system: "gm_points_2021"
      }) do
    competition
    |> Backend.MastersTour.get_ts_points_ranking(:points_2021)
    |> Map.new()
  end

  def fetch_results(l = %{competition_type: "masters_tour", competition: competition}) do
    competition
    |> TourStop.get()
    |> case do
      %{battlefy_id: bid} when is_binary(bid) -> bid |> get_battlefy_results(l)
      _ -> %{}
    end
  end

  def get_battlefy_results(tournament_id, %{point_system: "total_wins"}) do
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
