defmodule BackendWeb.BattlefyControllerTest do
  use BackendWeb.ConnCase

  test "GET /battlefy/tournaments-stats", %{conn: conn} do
    url = Routes.battlefy_path(conn, :tournaments_stats)
    conn = get(conn, url)

    assert html_response(conn, 200) =~ "Submit"
    assert html_response(conn, 200) =~ "Enter battlefy tournament"
  end

  test "GET /battlefy/tournaments-stats tournaments redirect", %{conn: conn} do
    url =
      Routes.battlefy_path(conn, :tournaments_stats, %{
        "tournaments" =>
          "https://battlefy.com/tierras-de-fuego-hs/el-camino-de-kaelthas-20/5f5bc93e0c405a2571493bf4/stage/5f888122a9c3434f84077e3e/match/5f88827f97c3d42eac842b06"
      })

    conn = get(conn, url)

    assert "/battlefy/tournaments-stats?tournament_ids=5f5bc93e0c405a2571493bf4" =
             redirected_to(conn, 302)
  end

  test "GET /battlefy/tournaments-stats?tournament_ids=5f5bc93e0c405a2571493bf4&title=TESTTITLE contains TESTTILE",
       %{conn: conn} do
    url =
      Routes.battlefy_path(conn, :tournaments_stats, %{
        "tournament_ids" => ["5f5bc93e0c405a2571493bf4"],
        "title" => "TESTTITLE"
      })

    conn = get(conn, url)
    assert html_response(conn, 200) =~ "TESTTITLE"
  end

  test "GET /battlefy/third-party-tournaments/stats/ilh-events-eu-open redirects with title query param",
       %{conn: conn} do
    url = Routes.battlefy_path(conn, :organization_tournament_stats, "ilh-events-eu-open")
    conn = get(conn, url)
    assert redirected_to(conn, 302) =~ ~r/\?.*title=ILH/
  end
end
