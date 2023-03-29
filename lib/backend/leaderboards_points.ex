defmodule Backend.LeaderboardsPoints do
  @moduledoc false
  alias Backend.Blizzard
  alias Backend.Leaderboards
  @type season_points :: {season_id :: integer(), best_rank :: integer(), points :: integer()}
  @type player_row ::
          {account_id :: String.t(), season_points :: [season_points], total_points :: integer()}

  @season_mapper [
    {"2023", "spring", 111},
    {"2023", "spring", 112},
    {"2023", "spring", 113},
    {"2023", "summer", 114},
    {"2023", "summer", 115},
    {"2023", "summer", 116},
    {"2023", "fall", 117},
    {"2023", "fall", 118},
    {"2023", "fall", 119}
  ]

  def calculate(ps, leaderboard_id, use_current \\ false) do
    create_criteria(ps, leaderboard_id, use_current)
    |> Leaderboards.entries()
    |> group_by_player()
    |> Enum.map(&calculate_player_row/1)
    |> Enum.sort_by(&elem(&1, 2), :desc)
  end

  defp group_by_player(entries) do
    Enum.group_by(entries, fn %{account_id: a} -> a end)
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
    leaderboard_seasons = get_relevant_ldb_seasons(ps, use_current)

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

    case Enum.find(@season_mapper, &(current == elem(&1, 2))) do
      {year, season, _} -> "#{year}_#{season}"
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
  def get_relevant_ldb_seasons(ps, use_current \\ false) do
    get_leaderboard_seasons(ps) |> remove_too_soon(use_current)
  end

  def get_leaderboard_seasons(points_season) do
    case String.split(points_season, "_") do
      [year, season] ->
        Enum.filter(@season_mapper, fn {y, s, _} -> y == year && s == season end)
        |> Enum.map(&extract_season/1)

      [year] ->
        Enum.filter(@season_mapper, fn {y, _, _} -> y == year end) |> Enum.map(&extract_season/1)
    end
  end

  defp extract_season({_, _, s}), do: s

  def points_seasons() do
    @season_mapper
    |> Enum.flat_map(fn {year, season, _} -> [year, "#{year}_#{season}"] end)
    |> Enum.uniq()
  end

  def points_season_display(season) do
    String.split(season)
    |> Enum.map_join(" ", &Recase.to_title/1)
  end
end
