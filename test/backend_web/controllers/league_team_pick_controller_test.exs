defmodule BackendWeb.LeagueTeamPickControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Fantasy

  @create_attrs %{pick: "some pick"}
  @update_attrs %{pick: "some updated pick"}
  @invalid_attrs %{pick: nil}

  def fixture(:league_team_pick) do
    {:ok, league_team_pick} = Fantasy.create_league_team_pick(@create_attrs)
    league_team_pick
  end

  describe "index" do
    test "lists all league_team_picks", %{conn: conn} do
      conn = get(conn, Routes.league_team_pick_path(conn, :index))
      assert html_response(conn, 200) =~ "League team picks"
    end
  end

  describe "new league_team_pick" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.league_team_pick_path(conn, :new))
      assert html_response(conn, 200) =~ "New League team pick"
    end
  end

  describe "create league_team_pick" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post conn, Routes.league_team_pick_path(conn, :create), league_team_pick: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.league_team_pick_path(conn, :show, id)

      conn = get(conn, Routes.league_team_pick_path(conn, :show, id))
      assert html_response(conn, 200) =~ "League team pick Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post conn, Routes.league_team_pick_path(conn, :create), league_team_pick: @invalid_attrs

      assert html_response(conn, 200) =~ "New League team pick"
    end
  end

  describe "edit league_team_pick" do
    setup [:create_league_team_pick]

    test "renders form for editing chosen league_team_pick", %{
      conn: conn,
      league_team_pick: league_team_pick
    } do
      conn = get(conn, Routes.league_team_pick_path(conn, :edit, league_team_pick))
      assert html_response(conn, 200) =~ "Edit League team pick"
    end
  end

  describe "update league_team_pick" do
    setup [:create_league_team_pick]

    test "redirects when data is valid", %{conn: conn, league_team_pick: league_team_pick} do
      conn =
        put conn, Routes.league_team_pick_path(conn, :update, league_team_pick),
          league_team_pick: @update_attrs

      assert redirected_to(conn) == Routes.league_team_pick_path(conn, :show, league_team_pick)

      conn = get(conn, Routes.league_team_pick_path(conn, :show, league_team_pick))
      assert html_response(conn, 200) =~ "some updated pick"
    end

    test "renders errors when data is invalid", %{conn: conn, league_team_pick: league_team_pick} do
      conn =
        put conn, Routes.league_team_pick_path(conn, :update, league_team_pick),
          league_team_pick: @invalid_attrs

      assert html_response(conn, 200) =~ "Edit League team pick"
    end
  end

  describe "delete league_team_pick" do
    setup [:create_league_team_pick]

    test "deletes chosen league_team_pick", %{conn: conn, league_team_pick: league_team_pick} do
      conn = delete(conn, Routes.league_team_pick_path(conn, :delete, league_team_pick))
      assert redirected_to(conn) == Routes.league_team_pick_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.league_team_pick_path(conn, :show, league_team_pick))
      end
    end
  end

  defp create_league_team_pick(_) do
    league_team_pick = fixture(:league_team_pick)
    {:ok, league_team_pick: league_team_pick}
  end
end
