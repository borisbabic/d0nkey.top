defmodule BackendWeb.LeaderboardController do
  require Logger
  use BackendWeb, :controller
  alias Backend.Blizzard
  alias Backend.Leaderboards
  alias Backend.MastersTour

  def index(conn, params = %{"region" => region, "leaderboardId" => leaderboard_id}) do
    leaderboard = get_leaderboard(region, leaderboard_id, params["seasonId"])
    ladder_mode = parse_ladder_mode(params)

    render(conn, "index.html", %{
      conn: conn,
      invited: leaderboard |> get_invited(),
      highlight: parse_highlight(params),
      other_ladders: leaderboard |> get_other_ladders(ladder_mode),
      leaderboard: leaderboard,
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

  defp get_leaderboard(r, l, s), do: Leaderboards.get_leaderboard(r, l, s)

  defp get_leaderboard(r, l, s) do
    try do
      Leaderboards.get_leaderboard(r, l, s)
    rescue
      _ -> nil
    end
  end
end
