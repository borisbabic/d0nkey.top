defmodule Backend.FantasyCompetitionFetcher do
  @moduledoc false
  alias Backend.Fantasy.Competition.Participant
  alias Backend.Fantasy.MTCompetitorMapper
  alias Backend.MastersTour.TourStop
  alias Backend.Battlefy
  alias Backend.Hearthstone
  alias Backend.Blizzard
  alias Backend.MastersTour
  alias Backend.LobbyLegends.LobbyLegendsSeason

  def get_participants(%{competition_type: "lobby_legends", competition: c}) do
    c
    |> LobbyLegendsSeason.get()
    |> LobbyLegendsSeason.players()
    |> Enum.map(& %{name: &1})

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

      %Participant{
        name: MTCompetitorMapper.map(ip.battletag_full, competition),
        meta: %{in_battlefy: signed_up_in_battlefy}
      }
    end)
  end

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

  def current_round("grandmasters", <<"gm_"::binary, gm_season_raw::binary>>) do
    with {:ok, gm_season} <- Hearthstone.parse_gm_season(gm_season_raw),
         {_, round} <- Blizzard.current_gm_week(gm_season) do
      round
    else
      _ -> 1
    end
  end

  def current_round(_, _), do: 1

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

  def fetch_results(%{competition_type: "lobby_legends"}, _), do: Map.new(%{
    "EducatedCollins" => 16.5,
    "baiyu" => 13.5,
    "Ponpata07" => 12,
    "BaboFat" => 10.5,
    "keromon" => 10,
    "ZoinhU" => 9.5,
    "summer" => 8.5,
    "Maks7k" => 3.5,

    "Curt" => 12,
    "guDDummit" => 12,
    "hof" => 12,
    "KenKen" => 14,
    "Satellite" => 8,
    "SeseiSei" => 6,
    "yjSJMR" => 6,
    "BeNice" => 14,
  })
  def fetch_results(l = %{competition_type: "battlefy", competition: competition}, _),
    do: get_battlefy_results(competition, l)

  def fetch_results(%{competition_type: "card_changes", competition: "nerfs_may_2021"}, _),
    do:
      [
        "Refreshing Spring Water",
        "First Day of School",
        "Hysteria",
        "Crabrider",
        "Mankrik"
      ]
      |> Enum.map(&{&1, 1})
      |> Map.new()

  def fetch_results(%{competition_type: "card_changes", competition: "buffs_may_2021"}, _),
    do:
      [
        "Razorboar",
        "Dark Inquisitor Xanesh",
        "Unbound Elemental",
        "Tidal Surge",
        "Lilypad Lurker",
        "Fiendish Circle",
        "Deck of Chaos",
        "Whirling Combatant",
        "Shieldmaiden",
        "N'Zoth, God of the Deep"
      ]
      |> Enum.map(&{&1, 1})
      |> Map.new()

  def fetch_results(
        %{
          competition_type: "grandmasters",
          competition: <<"gm_"::binary, gm_season_raw::binary>>
        },
        round
      ) do
    current_season = Blizzard.current_gm_season()

    gm_season_raw
    |> Hearthstone.parse_gm_season()
    |> case do
      {:ok, ^current_season} ->
        gm_stage_matching(current_season, round)
        |> Util.bangify()
        |> Backend.Grandmasters.results()

      _ ->
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
    |> Backend.Grandmasters.PromotionCalculator.ts_points(:points_2021)
    |> Enum.map(&{&1.player, &1.points})
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
