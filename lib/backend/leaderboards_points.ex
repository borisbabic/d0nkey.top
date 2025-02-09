defmodule Backend.LeaderboardsPoints do
  @moduledoc false
  alias Backend.Leaderboards
  alias Backend.LeaderboardsPoints.HsEsports2023
  @type season_points :: {season_id :: integer(), best_rank :: integer(), points :: integer()}
  @type player_row ::
          {account_id :: String.t(), season_points :: [season_points], total_points :: integer()}

  def calculate(ps, leaderboard_id, use_current \\ false) do
    system = system(ps)
    seasons = system.get_relevant_ldb_seasons(ps, leaderboard_id, use_current)
    regions = system.get_relevant_ldb_regions(ps, leaderboard_id)

    create_criteria(seasons, regions, leaderboard_id)
    |> Leaderboards.entries()
    |> group_by_player()
    |> Enum.map(&calculate_player_row(&1, system))
    |> system.filter_player_rows(ps, leaderboard_id)
    |> Enum.sort(&sorter/2)

    # |> Enum.sort_by(&elem(&1, 2), :desc)
  end

  def sorter({_, season_points_a, total_a}, {_, season_points_b, total_b})
      when total_a == total_b,
      do: compare_best_finishes(season_points_a, season_points_b)

  def sorter({_, _, total_a}, {_, _, total_b}), do: total_a < total_b

  def compare_best_finishes(sp_a, sp_b) do
    best_ranks_a = Enum.map(sp_a, &elem(&1, 1)) |> Enum.sort(:asc)
    best_ranks_b = Enum.map(sp_b, &elem(&1, 1)) |> Enum.sort(:asc)

    Backend.Grandmasters.PromotionRanking.compare_lists(best_ranks_a, best_ranks_b)
  end

  defp group_by_player(entries) do
    mapping = Backend.Battlenet.create_mapping()
    Enum.group_by(entries, fn %{account_id: a} -> Map.get(mapping, a, a) end)
  end

  @spec calculate_player_row(
          {String.t(), [Backend.Leaderboards.Entry.t()]},
          points_system :: module()
        ) :: player_row
  defp calculate_player_row({account_id, entries}, system) do
    season_points =
      entries
      |> Enum.group_by(&season_id_grouping/1)
      |> Enum.map(&create_season_points(&1, system))

    total_points = season_points |> Enum.map(&elem(&1, 2)) |> Enum.sum()
    {account_id, season_points, total_points}
  end

  @spec create_season_points(
          {integer(), [Backend.Leaderboards.Entry.t()]},
          points_system :: module()
        ) :: season_points
  defp create_season_points({season_id, entries}, system) do
    best_rank = entries |> Enum.map(& &1.rank) |> Enum.min()
    points = system.points_for_rank!(best_rank)
    {season_id, best_rank, points}
  end

  defp season_id_grouping(%{season: %{season_id: season_id}}), do: season_id

  defp create_criteria(leaderboard_seasons, leaderboard_regions, leaderboard_id) do
    seasons =
      for r <- leaderboard_regions,
          s <- leaderboard_seasons,
          do: %Hearthstone.Leaderboards.Season{
            season_id: s,
            region: r,
            leaderboard_id: leaderboard_id
          }

    [
      {"seasons", seasons},
      {"max_rank", 100},
      :latest_in_season,
      :preload_season
    ]
  end

  def current_season_id() do
  end

  def get_relevant_ldb_seasons(season_slug, leaderboard_id, use_current \\ false) do
    system(season_slug).get_relevant_ldb_seasons(season_slug, leaderboard_id, use_current)
  end

  def points_season_display(season_slug) do
    # Maybe make this system specific?
    String.split(season_slug)
    |> Enum.map_join(" ", &Recase.to_title/1)
  end

  def system("2023_"), do: HsEsports2023
  def system("2024_"), do: HsEsports2023
  def system(_), do: HsEsports2023

  def points_seasons() do
    systems()
    |> Enum.flat_map(& &1.points_seasons())
  end

  defp systems(), do: [HsEsports2023]
end
