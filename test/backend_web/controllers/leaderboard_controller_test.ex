defmodule BackendWeb.LeaderboardControllerTest do
  @moduledoc false
  use BackendWeb.ConnCase

  test "get /leaderboard?seasonId=0 will return warning", %{conn: conn} do
    url = Routes.leaderboard_path(conn, :index, %{"season_id" => 0})
    conn = get(conn, url)
    assert html_response(conn, 200) =~ "is-warning"
  end
end
