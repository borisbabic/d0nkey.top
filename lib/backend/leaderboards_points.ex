defmodule Backend.LeaderboardsPoints do
  @moduledoc false
  alias Backend.Blizzard
  alias Backend.Leaderboards
  @type season_points :: {season_id :: integer(), best_rank :: integer(), points :: integer()}
  @type player_row ::
          {account_id :: String.t(), season_points :: [season_points], total_points :: integer()}

  @season_mapper [
    {"2023", "spring", 111, ["BG_LL", "STD"]},
    {"2023", "spring", 112, ["BG_LL", "STD"]},
    {"2023", "spring", 113, ["BG_LL", "STD"]},
    {"2023", "summer", 114, ["BG_LL", "STD"]},
    {"2023", "summer", 115, ["BG_LL", "STD"]},
    {"2023", "summer", 116, ["BG_LL", "STD"]},
    {"2023", "fall", 117, ["BG_LL", "STD"]},
    {"2023", "fall", 118, ["BG_LL", "STD"]},
    {"2023", "fall", 119, ["BG_LL", "STD"]},
    {"2023", nil, 120, ["STD"]},
    {"2023", nil, 121, ["STD"]}
  ]

  def calculate(ps, leaderboard_id, use_current \\ false) do
    create_criteria(ps, leaderboard_id, use_current)
    |> Leaderboards.entries()
    |> group_by_player()
    |> Enum.map(&calculate_player_row/1)
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

  @spec calculate_player_row({String.t(), [Backend.Leaderboards.Entry.t()]}) :: player_row
  defp calculate_player_row({account_id, entries}) do
    season_points =
      entries
      |> Enum.group_by(&season_id_grouping/1)
      |> Enum.map(&create_season_points/1)

    total_points = season_points |> Enum.map(&elem(&1, 2)) |> Enum.sum()
    {account_id, season_points, total_points}
  end

  @spec create_season_points({integer(), [Backend.Leaderboards.Entry.t()]}) :: season_points
  defp create_season_points({season_id, entries}) do
    best_rank = entries |> Enum.map(& &1.rank) |> Enum.min()
    points = points_for_rank(best_rank)
    {season_id, best_rank, points}
  end

  defp season_id_grouping(%{season: %{season_id: season_id}}), do: season_id

  defp points_for_rank(r) when r < 1, do: {:error, :rank_below_one}
  defp points_for_rank(1), do: 8
  defp points_for_rank(r) when r <= 5, do: 7
  defp points_for_rank(r) when r <= 10, do: 6
  defp points_for_rank(r) when r <= 20, do: 5
  defp points_for_rank(r) when r <= 30, do: 4
  defp points_for_rank(r) when r <= 40, do: 3
  defp points_for_rank(r) when r <= 50, do: 2
  defp points_for_rank(r) when r <= 100, do: 1

  def create_criteria(ps, leaderboard_id, use_current \\ false) do
    leaderboard_seasons = get_relevant_ldb_seasons(ps, leaderboard_id, use_current)

    seasons =
      for r <- Blizzard.regions(),
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

  def current_points_season() do
    current = current_season_id()

    case Enum.find(@season_mapper, &(current == elem(&1, 2) && elem(&1, 1))) do
      {year, season, _, _} -> "#{year}_#{season}"
      _ -> now().year |> to_string()
    end
  end

  defp current_season_id() do
    now() |> Timex.to_date() |> Blizzard.get_season_id()
  end

  defp now() do
    Timex.now("US/Pacific")
  end

  defp remove_too_soon(seasons, use_current \\ false) do
    comparator = if use_current, do: &Kernel.<=/2, else: &Kernel.</2
    current = current_season_id()
    Enum.filter(seasons, &comparator.(&1, current))
  end

  @doc """
  Gets the leaderboard seasons used for calculating points for the points season `ps`
  """
  def get_relevant_ldb_seasons(ps, leaderboard_id, use_current) do
    get_leaderboard_seasons(ps, leaderboard_id) |> remove_too_soon(use_current)
  end

  def get_leaderboard_seasons(points_season, leaderboard_id_raw) do
    id = to_string(leaderboard_id_raw)

    case String.split(points_season, "_") do
      [year, season] ->
        Enum.filter(@season_mapper, fn {y, s, _, ids} -> y == year && s == season && id in ids end)
        |> Enum.map(&extract_season/1)

      [year] ->
        Enum.filter(@season_mapper, fn {y, _, _, ids} -> y == year && id in ids end)
        |> Enum.map(&extract_season/1)
    end
  end

  defp extract_season({_, _, s, _}), do: s

  def points_seasons() do
    @season_mapper
    |> Enum.filter(&elem(&1, 1))
    |> Enum.flat_map(fn {year, season, _, _} -> [year, "#{year}_#{season}"] end)
    |> Enum.uniq()
  end

  def points_season_display(season) do
    String.split(season)
    |> Enum.map_join(" ", &Recase.to_title/1)
  end
end
