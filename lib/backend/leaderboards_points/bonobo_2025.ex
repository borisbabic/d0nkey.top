defmodule Backend.LeaderboardsPoints.Bonobo2025 do
  @moduledoc false
  alias Backend.LeaderboardsPoints.PointsSystem
  @behaviour PointsSystem

  @ladder_battlefy_id "6778f937f050080017206bf6"

  @spec points_for_rank(rank :: integer()) ::
          {:ok, points :: integer()} | {:error, error :: atom()}
  @impl true
  def points_for_rank(r) when r < 1, do: {:error, :rank_below_one}
  def points_for_rank(1), do: {:ok, 15}
  def points_for_rank(r) when r <= 2, do: {:ok, 12}
  def points_for_rank(r) when r <= 5, do: {:ok, 10}
  def points_for_rank(r) when r <= 10, do: {:ok, 9}
  def points_for_rank(r) when r <= 20, do: {:ok, 8}
  def points_for_rank(r) when r <= 50, do: {:ok, 7}
  def points_for_rank(r) when r <= 100, do: {:ok, 6}
  def points_for_rank(r) when r <= 200, do: {:ok, 5}
  def points_for_rank(r) when r <= 500, do: {:ok, 4}
  def points_for_rank(r) when r <= 1000, do: {:ok, 3}
  def points_for_rank(r) when r <= 2000, do: {:ok, 2}
  def points_for_rank(r) when r <= 5000, do: {:ok, 1}
  def points_for_rank(_), do: {:ok, 0}

  @spec points_for_rank!(rank :: integer()) :: points :: integer()
  @impl true
  def points_for_rank!(r) do
    case points_for_rank(r) do
      {:ok, points} -> points
      {:error, error} -> raise to_string(error)
    end
  end

  @impl true
  def get_relevant_ldb_regions(_, _), do: [:EU]
  @impl true
  def get_relevant_ldb_seasons(_, _, use_current), do: 135..145 |> remove_too_soon(use_current)

  @impl true
  def max_rank(_, _), do: 5000
  @impl true
  def replace_entries(entries, _ps, _leaderboard_id), do: entries
  @impl true
  def info_links(_), do: [%{display: "Bonobo Discord", link: "https://discord.gg/vz8DcuN45m"}]

  @impl true
  def filter_player_rows(rows, _, _) do
    participants = Backend.Battlefy.get_participants(@ladder_battlefy_id)

    players_mapset =
      participants
      |> Enum.map(fn team ->
        team
        |> Backend.Battlefy.Team.player_or_team_name()
        |> Backend.Battlenet.Battletag.shorten()
      end)
      |> MapSet.new()

    Enum.filter(rows, fn {account_id, _, _} -> MapSet.member?(players_mapset, account_id) end)
  end

  defp remove_too_soon(seasons, use_current) do
    comparator = if use_current, do: &Kernel.<=/2, else: &Kernel.</2
    current = Backend.Blizzard.current_constructed_season_id(:EU)
    Enum.filter(seasons, &comparator.(&1, current))
  end

  @impl true
  def points_seasons(), do: ["bonobo_2025"]
end
