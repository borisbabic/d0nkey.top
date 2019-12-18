defmodule BackendWeb.LeaderboardController do
  use BackendWeb, :controller
  alias Backend.Leaderboards
  alias Backend.MastersTour

  # def index(conn, %{"region" => region, "leaderboardId" => leaderboard_id, "seasonId" => season_id}) do
  #   {entry, updated_at} = Leaderboards.fetch_current_entries(region, leaderboard_id, season_id)
  #   invited = MastersTour.list_invited_players()
  #   render(conn, "index.html", %{entry: entry, invited: invited, region: region, leaderboard_id: leaderboard_id, updated_at: updated_at})
  # end
  def index(conn, params = %{"region" => region, "leaderboardId" => leaderboard_id}) do
    # seasonId can be nil
    {entry, updated_at} = Leaderboards.fetch_current_entries(region, leaderboard_id, params["seasonId"])
    invited = MastersTour.list_invited_players("Indonesia") # todo figure out a better way to handle tour stops
    render(conn, "index.html", %{entry: entry, invited: invited, region: region, leaderboard_id: leaderboard_id, updated_at: updated_at})
  end
  def index(conn, params) do
    new_params =
      params
      |> Map.put_new("region", "EU")
      |> Map.put_new("leaderboardId", "STD")
    index(conn, new_params)
  end
end
