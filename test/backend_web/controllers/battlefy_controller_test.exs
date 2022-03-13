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

  test "GET Stormwind with highlight has highlighted standings", %{conn: conn} do
    url = Routes.battlefy_path(conn, :tournament, "6188ed89a422682f8a42a6ab", %{player: %{Furyhunter: true}})
    conn = get(conn, url)
    assert html_response(conn, 200) =~ "highlighted_standings"
  end
  test "GET Stormwind includes earnings and ongoing columns", %{conn: conn} do
    url = Routes.battlefy_path(conn, :tournament, "6188ed89a422682f8a42a6ab", %{show_earnings: "yes", show_ongoing: "yes"})
    conn = get(conn, url)
    assert html_response(conn, 200) =~ "ongoing_opponent"
    assert html_response(conn, 200) =~ "ongoing_score"
    assert html_response(conn, 200) =~ "earnings_column"
  end
end
