defmodule BackendWeb.LeaderboardControllerTest do
  use BackendWeb.ConnCase
  ##### PLAYER STATS #####
  test "GET /leaderboard/player-stats?country[HR]=true INCLUDES D0nkey and no flag", %{conn: conn} do
    params = %{
      "country" => %{"HR" => true}
    }

    url = Routes.leaderboard_path(conn, :player_stats, params)
    conn = get(conn, url)
    assert html_response(conn, 200)
  end

  ##### LEADERBOARD #####

  test "GET /leaderboard/region=EU&seasonId=84 INCLUDES Bozzzton", %{conn: conn} do
    params = %{
      "seasonId" => 84,
      "region" => "EU"
    }

    url = Routes.leaderboard_path(conn, :index, params)
    conn = get(conn, url)
    assert html_response(conn, 200) =~ "/player-profile/Bozzzton"
  end

  test "GET /leaderboard/region=EU&seasonId=84 INCLUDES D0nkey", %{conn: conn} do
    params = %{
      "seasonId" => 74,
      "show_flags" => "yes"
    }

    url = Routes.leaderboard_path(conn, :index, params)
    conn = get(conn, url)
    assert html_response(conn, 200) =~ "https://www.countryflags.io/HR/flat/64.png"
    assert html_response(conn, 200) =~ "/player-profile/D0nkey"
  end
end
