defmodule BackendWeb.WipController do
  use BackendWeb, :controller
  alias Backend.Leaderboards
  alias Backend.MastersTour

  def index(conn, %{"region" => region, "leaderboardId" => leaderboard_id}) do
    entry = Leaderboards.fetch_current_entries(region, leaderboard_id)
    invited = MastersTour.list_invited_players()
    render(conn, "index.html", %{entry: entry, invited: invited, region: region, leaderboard_id: leaderboard_id})
  end
  def index(conn, params) do
    new_params =
      params
      |> Map.put_new("region", "EU")
      |> Map.put_new("leaderboardId", "STD")
    index(conn, new_params)
  end
end
