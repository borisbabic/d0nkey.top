defmodule BackendWeb.BattlefyControllerTest do
  use BackendWeb.ConnCase

  @moduletag :external

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
    url =
      Routes.battlefy_path(conn, :tournament, "6188ed89a422682f8a42a6ab", %{
        player: %{Furyhunter: true}
      })

    conn = get(conn, url)
    assert html_response(conn, 200) =~ "highlighted_standings"
  end

  test "GET Stormwind includes earnings and ongoing columns", %{conn: conn} do
    url =
      Routes.battlefy_path(conn, :tournament, "6188ed89a422682f8a42a6ab", %{
        show_earnings: "yes",
        show_ongoing: "yes"
      })

    conn = get(conn, url)
    assert html_response(conn, 200) =~ "ongoing_opponent"
    assert html_response(conn, 200) =~ "ongoing_score"
    assert html_response(conn, 200) =~ "earnings_column"
  end

  test "GET tournament with view_mode=standings and stage_id=all_brackets redirects to view_mode=bracket",
       %{conn: conn} do
    url =
      Routes.battlefy_path(conn, :tournament, "6188ed89a422682f8a42a6ab", %{
        "view_mode" => "standings",
        "stage_id" => "all_brackets"
      })

    conn = get(conn, url)
    assert redirected_to(conn, 302) =~ "/battlefy/tournament/6188ed89a422682f8a42a6ab?"
    assert redirected_to(conn, 302) =~ "view_mode=bracket"
    assert redirected_to(conn, 302) =~ "stage_id=all_brackets"
  end

  test "add_tournament_stage_attrs excludes All Brackets when view_mode is standings" do
    tournament =
      struct(Backend.Battlefy.Tournament, %{
        id: "test_tour",
        name: "Test Tournament",
        organization: %{slug: "test-org"},
        stages: [
          struct(Backend.Battlefy.Stage, %{
            id: "s1",
            name: "Stage 1",
            bracket: %Backend.Battlefy.Stage.Bracket{type: "elimination"}
          }),
          struct(Backend.Battlefy.Stage, %{
            id: "s2",
            name: "Stage 2",
            bracket: %Backend.Battlefy.Stage.Bracket{type: "elimination"}
          })
        ]
      })

    conn = Phoenix.ConnTest.build_conn() |> Plug.Conn.fetch_query_params()

    params = %{
      conn: conn,
      tournament: tournament,
      view_mode: "standings",
      stage_id: "s1"
    }

    result = BackendWeb.BattlefyView.add_tournament_stage_attrs(params)
    stage_names = Enum.map(result.stages, & &1.name)
    refute "All Brackets" in stage_names
  end

  test "add_tournament_stage_attrs includes All Brackets when view_mode is bracket" do
    tournament =
      struct(Backend.Battlefy.Tournament, %{
        id: "test_tour",
        name: "Test Tournament",
        organization: %{slug: "test-org"},
        stages: [
          struct(Backend.Battlefy.Stage, %{
            id: "s1",
            name: "Stage 1",
            bracket: %Backend.Battlefy.Stage.Bracket{type: "elimination"}
          }),
          struct(Backend.Battlefy.Stage, %{
            id: "s2",
            name: "Stage 2",
            bracket: %Backend.Battlefy.Stage.Bracket{type: "elimination"}
          })
        ]
      })

    conn = Phoenix.ConnTest.build_conn() |> Plug.Conn.fetch_query_params()

    params = %{
      conn: conn,
      tournament: tournament,
      view_mode: "bracket",
      stage_id: "s1"
    }

    result = BackendWeb.BattlefyView.add_tournament_stage_attrs(params)
    stage_names = Enum.map(result.stages, & &1.name)
    assert "All Brackets" in stage_names
  end
end
