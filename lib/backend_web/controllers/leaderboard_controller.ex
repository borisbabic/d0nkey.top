defmodule BackendWeb.LeaderboardController do
  require Logger
  use BackendWeb, :controller
  alias Backend.Blizzard
  alias Backend.Leaderboards
  alias Backend.MastersTour

  def index(conn, params = %{"region" => _, "leaderboardId" => _}) do
    leaderboard = get_leaderboard(params)
    compare_to = params["compare_to"]
    comparison = get_comparison(leaderboard, compare_to)
    ladder_mode = parse_ladder_mode(params)

    render(conn, "index.html", %{
      conn: conn,
      invited: leaderboard |> get_invited(),
      highlight: parse_highlight(params),
      other_ladders: leaderboard |> get_other_ladders(ladder_mode),
      leaderboard: leaderboard,
      compare_to: params["compare_to"],
      comparison: comparison,
      ladder_mode: ladder_mode
    })
  end

  def index(conn, params) do
    new_params =
      params
      |> Map.put_new("region", "EU")
      |> Map.put_new("leaderboardId", "STD")

    index(conn, new_params)
  end

  def parse_ladder_mode(%{"ladder_mode" => "no"}), do: "no"
  def parse_ladder_mode(_), do: "yes"

  def get_invited(nil), do: []
  def get_invited(%{season_id: season_id}), do: get_invited(season_id)

  def get_invited(season_id) do
    case Blizzard.get_ladder_tour_stop(season_id) do
      {:ok, tour_stop} -> MastersTour.list_invited_players(tour_stop)
      {:error, _} -> []
    end
  end

  def get_other_ladders(_, "no"), do: []

  def get_other_ladders(%{season_id: s, leaderboard_id: "STD", region: r}, "yes") when s > 71 do
    Blizzard.ladders_to_check(s, r)
    |> Enum.flat_map(fn r ->
      case get_leaderboard(r, "STD", s) do
        nil -> []
        leaderboard -> [leaderboard]
      end
    end)
  end

  def get_other_ladders(_, _), do: []

  def parse_highlight(params) do
    case params["highlight"] do
      string when is_binary(string) -> MapSet.new([string])
      list when is_list(list) -> MapSet.new(list)
      _ -> nil
    end
  end

  def get_leaderboard(%{"database_id" => id}), do: Leaderboards.snapshot(id)

  def get_leaderboard(%{
        "up_to" => string_date,
        "region" => region,
        "leaderboardId" => leaderboard
      }) do
    case string_date |> Timex.parse("{RFC3339z}") do
      {:error, _} ->
        nil

      {:ok, date} ->
        Leaderboards.latest_up_to(region, leaderboard, date)
    end
  end

  def get_leaderboard(params = %{"region" => region, "leaderboardId" => leaderboard_id}) do
    get_leaderboard(region, leaderboard_id, params["seasonId"])
  end

  defp get_leaderboard(r, l, s) do
    try do
      Leaderboards.get_leaderboard(r, l, s)
    rescue
      _ -> nil
    end
  end

  defp get_comparison(l, nil), do: nil

  defp get_comparison(l, c_t) do
    try do
      Leaderboards.get_comparison(l, c_t)
    rescue
      _ -> nil
    end
  end

  def player_stats(conn, params) do
    direction =
      case params["direction"] do
        "desc" -> :desc
        "asc" -> :asc
        _ -> nil
      end

    regions = multi_select_to_array(params["regions"])
    leaderboards = multi_select_to_array(params["leaderboards"])

    min = with raw when is_binary(raw) <- params["min"], {val, _} <- Integer.parse(raw), do: val

    criteria =
      [{:latest_in_season}, {:not_current_season}]
      |> add_region_criteria(regions)
      |> add_leaderboard_criteria(leaderboards)

    stats = Leaderboards.stats(criteria)

    render(conn, "stats.html", %{
      conn: conn,
      leaderboards: leaderboards,
      regions: regions,
      direction: direction,
      min: min,
      sort_by: params["sort_by"],
      stats: stats
    })
  end

  defp add_leaderboard_criteria(criteria, []), do: add_leaderboard_criteria(criteria, nil)
  defp add_leaderboard_criteria(criteria, nil), do: [{"leaderboard_id", ["STD"]} | criteria]
  defp add_leaderboard_criteria(criteria, ids), do: [{"leaderboard_id", ids} | criteria]

  defp add_region_criteria(criteria, []), do: criteria
  defp add_region_criteria(criteria, nil), do: criteria
  defp add_region_criteria(criteria, regions), do: [{"region", regions} | criteria]
end
