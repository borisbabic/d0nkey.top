defmodule Backend.LeaderboardsPoints.China2026 do
  @moduledoc false
  alias Backend.LeaderboardsPoints.PointsSystem
  alias Backend.LeaderboardsPoints.HsEsports2025
  @behaviour PointsSystem

  @season_mapper [
    {"2026", "spring", 149, ["STD"]},
    {"2026", "spring", 150, ["STD"]},
    {"2026", "summer", 151, ["STD"]},
    {"2026", "summer", 152, ["STD"]}
  ]
  @points [
    {{1, 1}, 15},
    {{2, 2}, 14},
    {{3, 3}, 13},
    {{4, 5}, 12},
    {{6, 7}, 11},
    {{8, 10}, 10},
    {{11, 15}, 9},
    {{16, 20}, 8},
    {{21, 50}, 6},
    {{51, 100}, 5}
  ]
  @spec points_for_rank(rank :: integer()) ::
          {:ok, points :: integer()} | {:error, error :: atom()}
  @impl true
  def points_for_rank(r) when r < 1, do: {:error, :rank_below_one}

  def points_for_rank(rank) do
    {:ok, HsEsports2025.find_points(rank, @points)}
  end

  def get_points_system(), do: @points
  @spec points_for_rank!(rank :: integer()) :: points :: integer()
  @impl true
  def points_for_rank!(r) do
    case points_for_rank(r) do
      {:ok, points} -> points
      {:error, error} -> raise to_string(error)
    end
  end

  @impl true
  def get_relevant_ldb_regions(_, _), do: [:CN]
  @impl true
  def get_relevant_ldb_seasons(ps, leaderboard_id, use_current) do
    HsEsports2025.get_leaderboard_seasons(ps, leaderboard_id, @season_mapper, "china_")
    |> remove_too_soon(use_current)
  end

  @impl true
  def max_rank(_, _), do: 100
  @impl true
  def replace_entries(entries, _ps, _leaderboard_id), do: entries
  @impl true
  def info_links(_),
    do: [
      %{
        display: "System info",
        link: "https://x.com/glormagic/status/2022239505244381655/photo/4"
      }
    ]

  @impl true
  def filter_player_rows(rows, _, _) do
    rows
  end

  defp remove_too_soon(seasons, use_current) do
    comparator = if use_current, do: &Kernel.<=/2, else: &Kernel.</2
    current = Backend.Blizzard.current_constructed_season_id(:CN)
    Enum.filter(seasons, &comparator.(&1, current))
  end

  @impl true
  def points_seasons(), do: HsEsports2025.points_seasons(@season_mapper, "china_")

  @impl true
  def points_for_ladder_season(leaderboard_id, season_id, region) do
    HsEsports2025.find_points_for_season(
      leaderboard_id,
      season_id,
      region,
      @season_mapper,
      @points,
      "China Points",
      get_relevant_ldb_regions(nil, leaderboard_id)
    )
  end
end
