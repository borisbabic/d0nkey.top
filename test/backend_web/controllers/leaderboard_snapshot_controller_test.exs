defmodule BackendWeb.LeaderboardSnapshotControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Leaderboards

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:leaderboard_snapshot) do
    {:ok, leaderboard_snapshot} = Leaderboards.create_leaderboard_snapshot(@create_attrs)
    leaderboard_snapshot
  end

  describe "index" do
    test "lists all leaderboard_snapshot", %{conn: conn} do
      conn = get(conn, Routes.leaderboard_snapshot_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Leaderboard snapshot"
    end
  end

  describe "new leaderboard_snapshot" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.leaderboard_snapshot_path(conn, :new))
      assert html_response(conn, 200) =~ "New Leaderboard snapshot"
    end
  end

  describe "create leaderboard_snapshot" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.leaderboard_snapshot_path(conn, :create), leaderboard_snapshot: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.leaderboard_snapshot_path(conn, :show, id)

      conn = get(conn, Routes.leaderboard_snapshot_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Leaderboard snapshot"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.leaderboard_snapshot_path(conn, :create), leaderboard_snapshot: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Leaderboard snapshot"
    end
  end

  describe "edit leaderboard_snapshot" do
    setup [:create_leaderboard_snapshot]

    test "renders form for editing chosen leaderboard_snapshot", %{conn: conn, leaderboard_snapshot: leaderboard_snapshot} do
      conn = get(conn, Routes.leaderboard_snapshot_path(conn, :edit, leaderboard_snapshot))
      assert html_response(conn, 200) =~ "Edit Leaderboard snapshot"
    end
  end

  describe "update leaderboard_snapshot" do
    setup [:create_leaderboard_snapshot]

    test "redirects when data is valid", %{conn: conn, leaderboard_snapshot: leaderboard_snapshot} do
      conn = put(conn, Routes.leaderboard_snapshot_path(conn, :update, leaderboard_snapshot), leaderboard_snapshot: @update_attrs)
      assert redirected_to(conn) == Routes.leaderboard_snapshot_path(conn, :show, leaderboard_snapshot)

      conn = get(conn, Routes.leaderboard_snapshot_path(conn, :show, leaderboard_snapshot))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, leaderboard_snapshot: leaderboard_snapshot} do
      conn = put(conn, Routes.leaderboard_snapshot_path(conn, :update, leaderboard_snapshot), leaderboard_snapshot: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Leaderboard snapshot"
    end
  end

  describe "delete leaderboard_snapshot" do
    setup [:create_leaderboard_snapshot]

    test "deletes chosen leaderboard_snapshot", %{conn: conn, leaderboard_snapshot: leaderboard_snapshot} do
      conn = delete(conn, Routes.leaderboard_snapshot_path(conn, :delete, leaderboard_snapshot))
      assert redirected_to(conn) == Routes.leaderboard_snapshot_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.leaderboard_snapshot_path(conn, :show, leaderboard_snapshot))
      end
    end
  end

  defp create_leaderboard_snapshot(_) do
    leaderboard_snapshot = fixture(:leaderboard_snapshot)
    {:ok, leaderboard_snapshot: leaderboard_snapshot}
  end
end
