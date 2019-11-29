defmodule BackendWeb.LeaderboardControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Leaderboards

  @create_attrs %{leaderboard_id: "some leaderboard_id", region: "some region", season_id: "some season_id", start_date: "2010-04-17T14:00:00Z", upstream_id: 42}
  @update_attrs %{leaderboard_id: "some updated leaderboard_id", region: "some updated region", season_id: "some updated season_id", start_date: "2011-05-18T15:01:01Z", upstream_id: 43}
  @invalid_attrs %{leaderboard_id: nil, region: nil, season_id: nil, start_date: nil, upstream_id: nil}

  def fixture(:leaderboard) do
    {:ok, leaderboard} = Leaderboards.create_leaderboard(@create_attrs)
    leaderboard
  end

  describe "index" do
    test "lists all leaderboard", %{conn: conn} do
      conn = get(conn, Routes.leaderboard_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Leaderboard"
    end
  end

  describe "new leaderboard" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.leaderboard_path(conn, :new))
      assert html_response(conn, 200) =~ "New Leaderboard"
    end
  end

  describe "create leaderboard" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.leaderboard_path(conn, :create), leaderboard: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.leaderboard_path(conn, :show, id)

      conn = get(conn, Routes.leaderboard_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Leaderboard"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.leaderboard_path(conn, :create), leaderboard: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Leaderboard"
    end
  end

  describe "edit leaderboard" do
    setup [:create_leaderboard]

    test "renders form for editing chosen leaderboard", %{conn: conn, leaderboard: leaderboard} do
      conn = get(conn, Routes.leaderboard_path(conn, :edit, leaderboard))
      assert html_response(conn, 200) =~ "Edit Leaderboard"
    end
  end

  describe "update leaderboard" do
    setup [:create_leaderboard]

    test "redirects when data is valid", %{conn: conn, leaderboard: leaderboard} do
      conn = put(conn, Routes.leaderboard_path(conn, :update, leaderboard), leaderboard: @update_attrs)
      assert redirected_to(conn) == Routes.leaderboard_path(conn, :show, leaderboard)

      conn = get(conn, Routes.leaderboard_path(conn, :show, leaderboard))
      assert html_response(conn, 200) =~ "some updated leaderboard_id"
    end

    test "renders errors when data is invalid", %{conn: conn, leaderboard: leaderboard} do
      conn = put(conn, Routes.leaderboard_path(conn, :update, leaderboard), leaderboard: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Leaderboard"
    end
  end

  describe "delete leaderboard" do
    setup [:create_leaderboard]

    test "deletes chosen leaderboard", %{conn: conn, leaderboard: leaderboard} do
      conn = delete(conn, Routes.leaderboard_path(conn, :delete, leaderboard))
      assert redirected_to(conn) == Routes.leaderboard_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.leaderboard_path(conn, :show, leaderboard))
      end
    end
  end

  defp create_leaderboard(_) do
    leaderboard = fixture(:leaderboard)
    {:ok, leaderboard: leaderboard}
  end
end
