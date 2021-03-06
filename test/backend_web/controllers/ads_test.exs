defmodule BackendWeb.AdsTest do
  use BackendWeb.ConnCase

  describe "has ads" do
    test "includes ads when not logged in", %{conn: conn} do
      conn = get(conn, Routes.empty_path(conn, :with_nav))
      assert html_response(conn, 200) =~ "adsbygoogle"
    end

    @tag :authenticated
    test "includes ads when logged in", %{conn: conn, user: _} do
      conn = get(conn, Routes.empty_path(conn, :with_nav))
      assert html_response(conn, 200) =~ "adsbygoogle"
    end
  end

  describe "no ads for admin" do
    @describetag :authenticated
    @describetag :users
    test "hides ads for admin", %{conn: conn, user: _} do
      conn = get(conn, Routes.empty_path(conn, :with_nav))
      refute html_response(conn, 200) =~ "adsbygoogle"
    end
  end

  describe "no ads when hidden" do
    setup :add_user_with_hidden_ads

    test "hides ads for hidden user", %{conn: conn, user: _} do
      conn = get(conn, Routes.empty_path(conn, :with_nav))
      refute html_response(conn, 200) =~ "adsbygoogle"
    end
  end

  def add_user_with_hidden_ads(_) do
    {:ok, user} =
      BackendWeb.ConnCase.ensure_auth_user(%{battletag: "hide_ads#2345", hide_ads: true})

    conn =
      user
      |> BackendWeb.ConnCase.build_conn_with_user()

    {:ok, conn: conn, user: user}
  end
end
