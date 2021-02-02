defmodule BackendWeb.PlayerControllerTest do
  use BackendWeb.ConnCase

  test "GET /player-profile/D0nkey%232470 returns 200" do
    conn = get(conn("/player-profile/D0nkey%232470"))
    assert html_response(conn, 200) =~ "D0nkey#2470"
  end
end
