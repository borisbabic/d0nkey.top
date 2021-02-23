defmodule BackendWeb.NavTest do
  use BackendWeb.ConnCase

  describe "no user tournaments link" do
    test "no link when not signed in", %{conn: conn} do
      conn = get(conn, Routes.empty_path(conn, :with_nav))
      refute html_response(conn, 200) =~ "/battlefy/user-tournaments"
    end

    @tag :authenticated
    @tag :users
    test "no link when signed in without battlefy_slug set", %{conn: conn} do
      conn = get(conn, Routes.empty_path(conn, :with_nav))
      refute html_response(conn, 200) =~ "/battlefy/user-tournaments"
    end
  end

  describe "has user tournaments link" do
    setup :add_user_with_battlefy_slug

    test "has_link_when_signed_in", %{conn: conn} do
      conn = get(conn, Routes.empty_path(conn, :with_nav))
      assert html_response(conn, 200) =~ "/battlefy/user-tournaments/"
    end
  end

  def add_user_with_battlefy_slug(_) do
    {:ok, user} =
      BackendWeb.ConnCase.create_auth_user(%{
        battlefy_slug: "d0nkey",
        battletag: "hide_ads#2345",
        hide_ads: true
      })

    conn =
      user
      |> BackendWeb.ConnCase.build_conn_with_user()

    {:ok, conn: conn, user: user}
  end
end
