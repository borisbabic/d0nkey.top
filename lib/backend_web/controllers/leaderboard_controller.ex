defmodule BackendWeb.LeaderboardController do
  use BackendWeb, :controller
  alias Backend.Blizzard
  alias Backend.Leaderboards
  alias Backend.MastersTour

  def index(conn, params = %{"region" => region, "leaderboardId" => leaderboard_id}) do
    # seasonId can be nil
    {entry, updated_at} =
      try do
        Leaderboards.fetch_current_entries(region, leaderboard_id, params["seasonId"])
      rescue
        _ -> {[], nil}
      end

    season_id =
      case Integer.parse(to_string(conn.query_params["seasonId"])) do
        :error -> Blizzard.get_season_id(Date.utc_today())
        {id, _} -> id
      end

    invited =
      case Blizzard.get_ladder_tour_stop(season_id) do
        {:ok, tour_stop} -> MastersTour.list_invited_players(tour_stop)
        {:error, _} -> []
      end

    highlight =
      case params["highlight"] do
        string when is_binary(string) -> MapSet.new([string])
        list when is_list(list) -> MapSet.new(list)
        _ -> nil
      end

    render(conn, "index.html", %{
      entry: entry,
      invited: invited,
      region: region,
      leaderboard_id: leaderboard_id,
      updated_at: updated_at,
      highlight: highlight,
      season_id: season_id
    })
  end

  def index(conn, params) do
    new_params =
      params
      |> Map.put_new("region", "EU")
      |> Map.put_new("leaderboardId", "STD")

    index(conn, new_params)
  end
end
