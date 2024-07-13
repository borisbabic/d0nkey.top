defmodule BackendWeb.NavTest do
  use BackendWeb.ConnCase

  @logged_in_links [
    "/deck-sheets",
    "/my-replays",
    "/my-decks",
    "/my-groups",
    "/profile/settings",
    "/logout"
  ]
  test "no link when not signed in", %{conn: conn} do
    conn = get(conn, Routes.empty_path(conn, :with_nav))
    response = html_response(conn, 200)

    for link <- @logged_in_links do
      refute response =~ link
    end
  end

  @tag :authenticated
  @tag :users
  test "sheet link present when logged in", %{conn: conn} do
    conn = get(conn, Routes.empty_path(conn, :with_nav))
    response = html_response(conn, 200)

    for link <- @logged_in_links do
      assert response =~ link
    end
  end
end
