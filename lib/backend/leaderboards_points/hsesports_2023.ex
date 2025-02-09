defmodule Backend.LeaderboardsPoints.HsEsports2023 do
  @moduledoc "HsEsports 2023 2024 system"
  alias Backend.LeaderboardsPoints.PointsSystem
  alias Backend.Blizzard
  @behaviour PointsSystem

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
    {"2023", nil, 121, ["STD"]},
    {"2024", "spring", 124, ["STD"]},
    {"2024", "spring", 125, ["STD"]},
    {"2024", "summer", 128, ["STD"]},
    {"2024", "summer", 129, ["STD"]},
    {"2024", nil, 132, ["STD"]},
    {"2024", nil, 133, ["STD"]}
  ]

  @spec points_for_rank(rank :: integer()) ::
          {:ok, points :: integer()} | {:error, error :: atom()}
  @impl true
  def points_for_rank(r) when r < 1, do: {:error, :rank_below_one}
  def points_for_rank(1), do: {:ok, 8}
  def points_for_rank(r) when r <= 5, do: {:ok, 7}
  def points_for_rank(r) when r <= 10, do: {:ok, 6}
  def points_for_rank(r) when r <= 20, do: {:ok, 5}
  def points_for_rank(r) when r <= 30, do: {:ok, 4}
  def points_for_rank(r) when r <= 40, do: {:ok, 3}
  def points_for_rank(r) when r <= 50, do: {:ok, 2}
  def points_for_rank(r) when r <= 100, do: {:ok, 1}
  def points_for_rank(_), do: {:ok, 0}

  @impl true
  def filter_player_rows(rows, _, _), do: rows

  @spec points_for_rank!(rank :: integer()) :: points :: integer()
  @impl true
  def points_for_rank!(r) do
    case points_for_rank(r) do
      {:ok, points} -> points
      {:error, error} -> raise to_string(error)
    end
  end

  @impl true
  def get_relevant_ldb_regions(_season_slug, _leaderboard_id) do
    [:EU, :US, :AP]
  end

  @doc """
  Gets the leaderboard seasons used for calculating points for the points season `ps`
  """
  @impl true
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

  @impl true
  def points_seasons() do
    @season_mapper
    |> Enum.filter(&elem(&1, 1))
    |> Enum.flat_map(fn {year, season, _, _} -> [year, "#{year}_#{season}"] end)
    |> Enum.uniq()
  end

  ######

  def current_points_season() do
    current = Blizzard.current_constructed_season_id()

    case Enum.find(@season_mapper, &(current == elem(&1, 2) && elem(&1, 1))) do
      {year, season, _, _} -> "#{year}_#{season}"
      _ -> Blizzard.now().year |> to_string()
    end
  end

  defp remove_too_soon(seasons, use_current) do
    comparator = if use_current, do: &Kernel.<=/2, else: &Kernel.</2
    current = Blizzard.current_constructed_season_id()
    Enum.filter(seasons, &comparator.(&1, current))
  end

  defp extract_season({_, _, s, _}), do: s
end
