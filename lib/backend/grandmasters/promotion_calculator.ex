defmodule Backend.Grandmasters.PromotionCalculator do
  @moduledoc false

  alias Backend.Blizzard
  alias Backend.Battlefy
  alias Backend.Battlenet.Battletag
  alias Backend.MastersTour
  alias Backend.Grandmasters.PromotionRanking
  alias Backend.Infrastructure.PlayerNationalityCache
  alias Backend.Grandmasters.TourStopPromotionPoints, as: TSPoints

  @type raw_ts_points :: {String.t(), integer(), integer()}

  @spec for_season(Blizzard.gm_season(), atom()) :: [PromotionRanking.t()]
  def for_season(season, type \\ :points_2021)

  # Probably won't ever implement for this
  def for_season({2020, 1}, _), do: []

  def for_season(season, system) do
    Blizzard.get_tour_stops_for_gm!(season)
    |> Enum.filter(fn ts ->
      Battlefy.get_tour_stop_id(ts) |> elem(0) == :ok
    end)
    |> Enum.flat_map(&ts_points(&1, system))
    |> group_ts_rankings()
    |> PromotionRanking.sort()
  end

  @spec group_ts_rankings(TSPoints.t()) :: [PromotionRanking.t()]
  def group_ts_rankings(ts_points_list) do
    ts_points_list
    |> Enum.group_by(& &1.player)
    |> Enum.map(fn {_player, ts_points_list} ->
      ts_points_list |> PromotionRanking.merge_ts()
    end)
  end

  @spec ts_points(atom(), atom()) :: [TSPoints.t()]
  def ts_points(ts, system) do
    ts
    |> MastersTour.get_mt_tournament()
    |> calculate_points(system, ts)
  end

  @spec calculate_points(Battlefy.Tournament.t(), atom(), atom()) :: [TSPoints.t()]
  def calculate_points(%{stages: [swiss, top_cut]}, system, tour_stop) do
    top_cut_standings = MastersTour.get_mt_stage_standings(top_cut)
    swiss_standings = MastersTour.get_mt_stage_standings(swiss)

    top_cut_points = top_cut_points(top_cut_standings, system, tour_stop)
    swiss_points = swiss_points(swiss_standings, system, tour_stop)

    swiss_points
    |> Enum.map(fn {player, swiss_points, swiss_place} ->
      {total_points, total_place} =
        top_cut_points
        |> Enum.find(&(player == &1 |> elem(0)))
        |> case do
          {^player, top_points, top_place} ->
            {merge_points(system, swiss_points, top_points), top_place}

          nil ->
            {swiss_points, swiss_place}
        end

      {player, total_points, total_place}
    end)
    |> to_ts_points(tour_stop)
  end

  def calculate_points(%{stages: [swiss]}, system, tour_stop) do
    swiss
    |> MastersTour.get_mt_stage_standings()
    |> swiss_points(system, tour_stop)
    |> to_ts_points(tour_stop)
  end

  def calculate_points(_, _), do: []

  @spec to_ts_points(raw_ts_points(), atom()) :: [TSPoints.t()]
  def to_ts_points(raw_points, tour_stop) do
    raw_points
    |> Enum.map(fn {player, points, place} ->
      %TSPoints{
        player: get_group_by(player),
        tour_stop: tour_stop,
        points: points,
        tiebreak: place
      }
    end)
    |> TSPoints.sort()
  end

  @spec get_group_by(String.t()) :: String.t()
  def get_group_by(name) do
    with true <- String.starts_with?(name, "Jay#"),
         actual when is_binary(actual) <- PlayerNationalityCache.get_actual_battletag(name) do
      actual
    else
      _ -> name |> Battletag.shorten() |> MastersTour.name_hacks()
    end
  end

  @spec swiss_points([Battlefy.Standings.t()], atom(), atom()) :: [raw_ts_points()]
  def swiss_points(standings, :points_2021, _) do
    standings
    |> Enum.map(fn %{team: %{name: name}, wins: wins, place: place} ->
      points =
        case wins do
          9 -> 9
          8 -> 8
          7 -> 7
          _ -> 0
        end

      {name, points, place |> normalize_2021_swiss_place()}
    end)
  end

  def swiss_points(standings, :earnings_2020, _) do
    standings
    |> Enum.map(fn %{team: %{name: name}, wins: wins, place: place} ->
      money =
        case wins do
          8 -> 3500
          7 -> 3500
          6 -> 2250
          5 -> 1000
          _ -> 850
        end

      {name, money, place}
    end)
  end

  @first_earnings {32_500, 1}
  @second_earnings {22_500, 2}
  @top4_earnings {15_000, 3}
  @top8_earnings {11_000, 5}

  @spec top_cut_points([Battlefy.Standings.t()], atom(), atom()) :: [raw_ts_points()]
  def top_cut_points(standings, :earnings_2020, tour_stop) do
    standings
    |> Enum.map(fn %{team: %{name: name}, wins: wins, place: place} ->
      shortened_name = Battletag.shorten(name)

      {money, place} =
        case {wins, place, tour_stop, shortened_name} do
          # stupid blizzard not updating battlefy till the end
          {_, _, :Arlington, "xBlyzes"} -> @first_earnings
          {3, _, _, _} -> @first_earnings
          {2, _, _, _} -> @second_earnings
          {1, _, _, _} -> @top4_earnings
          {0, _, _, _} -> @top8_earnings
          {nil, 1, _, _} -> @first_earnings
          {nil, 2, _, _} -> @second_earnings
          {nil, 3, _, _} -> @top4_earnings
          {nil, 5, _, _} -> @top8_earnings
          _ -> @top8_earnings
        end

      {name, money, place}
    end)
  end

  def top_cut_points(standings, :points_2021, _) do
    standings
    |> Enum.map(fn %{team: %{name: name}, wins: wins, place: place} ->
      {points, place} =
        case {wins, place} do
          {_, 1} -> {15, 1}
          {_, 2} -> {12, 2}
          {_, 3} -> {8, 3}
          {_, 5} -> {4, 5}
          {4, _} -> {15, 1}
          {3, _} -> {12, 2}
          {2, _} -> {8, 3}
          {1, _} -> {4, 5}
          _ -> {0, 9}
        end

      {name, points, place}
    end)
  end

  @doc """
  2020 9-16 in swiss are treated as 9th
  https://twitter.com/GnimshTV/status/1398550231634034688
  """
  defp normalize_2021_swiss_place(place) when place > 8 and place < 17, do: 9
  defp normalize_2021_swiss_place(place), do: place

  defp merge_points(:points_2021, swiss, top), do: swiss + top
  defp merge_points(:earnings_2020, _, top), do: top

  @spec convert_to_legacy([PromotionRanking.t()]) :: MastersTour.gm_money_rankings()
  def convert_to_legacy(promotion) do
    promotion
    |> Enum.map(fn p ->
      per_ts = p.per_ts |> Enum.map(&{&1.tour_stop, &1.points})
      {p.player, p.total, per_ts}
    end)
  end
end
