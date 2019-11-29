defmodule BackendWeb.LeaderboardEntryControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Leaderboards

  @create_attrs %{battletag: "some battletag", position: 42, rating: 42}
  @update_attrs %{battletag: "some updated battletag", position: 43, rating: 43}
  @invalid_attrs %{battletag: nil, position: nil, rating: nil}

  def fixture(:leaderboard_entry) do
    {:ok, leaderboard_entry} = Leaderboards.create_leaderboard_entry(@create_attrs)
    leaderboard_entry
  end

  describe "index" do
    test "lists all leaderboard_entry", %{conn: conn} do
      conn = get(conn, Routes.leaderboard_entry_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Leaderboard entry"
    end
  end

  describe "new leaderboard_entry" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.leaderboard_entry_path(conn, :new))
      assert html_response(conn, 200) =~ "New Leaderboard entry"
    end
  end

  describe "create leaderboard_entry" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.leaderboard_entry_path(conn, :create), leaderboard_entry: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.leaderboard_entry_path(conn, :show, id)

      conn = get(conn, Routes.leaderboard_entry_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Leaderboard entry"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.leaderboard_entry_path(conn, :create), leaderboard_entry: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Leaderboard entry"
    end
  end

  describe "edit leaderboard_entry" do
    setup [:create_leaderboard_entry]

    test "renders form for editing chosen leaderboard_entry", %{conn: conn, leaderboard_entry: leaderboard_entry} do
      conn = get(conn, Routes.leaderboard_entry_path(conn, :edit, leaderboard_entry))
      assert html_response(conn, 200) =~ "Edit Leaderboard entry"
    end
  end

  describe "update leaderboard_entry" do
    setup [:create_leaderboard_entry]

    test "redirects when data is valid", %{conn: conn, leaderboard_entry: leaderboard_entry} do
      conn = put(conn, Routes.leaderboard_entry_path(conn, :update, leaderboard_entry), leaderboard_entry: @update_attrs)
      assert redirected_to(conn) == Routes.leaderboard_entry_path(conn, :show, leaderboard_entry)

      conn = get(conn, Routes.leaderboard_entry_path(conn, :show, leaderboard_entry))
      assert html_response(conn, 200) =~ "some updated battletag"
    end

    test "renders errors when data is invalid", %{conn: conn, leaderboard_entry: leaderboard_entry} do
      conn = put(conn, Routes.leaderboard_entry_path(conn, :update, leaderboard_entry), leaderboard_entry: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Leaderboard entry"
    end
  end

  describe "delete leaderboard_entry" do
    setup [:create_leaderboard_entry]

    test "deletes chosen leaderboard_entry", %{conn: conn, leaderboard_entry: leaderboard_entry} do
      conn = delete(conn, Routes.leaderboard_entry_path(conn, :delete, leaderboard_entry))
      assert redirected_to(conn) == Routes.leaderboard_entry_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.leaderboard_entry_path(conn, :show, leaderboard_entry))
      end
    end
  end

  defp create_leaderboard_entry(_) do
    leaderboard_entry = fixture(:leaderboard_entry)
    {:ok, leaderboard_entry: leaderboard_entry}
  end
end
