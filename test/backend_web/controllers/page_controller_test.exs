defmodule BackendWeb.PageControllerTest do
  use BackendWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "leaderboard"
  end

  test "GET /api-docs renders the Developer API reference", %{conn: conn} do
    conn = get(conn, "/api-docs")
    response = html_response(conn, 200)

    assert response =~ "HSGuru Developer API"
    assert response =~ "/api/v1/meta"
    assert response =~ "/api/v1/archetypes"
    assert response =~ "/api/v1/decks"
    assert response =~ "/api/v1/streamers"
    assert response =~ "/api/v1/streamer-decks"
    assert response =~ "/api/v1/streams/live"
    assert response =~ "API Docs"
    assert response =~ "<title>\nHSGuru Developer API"
  end
end
