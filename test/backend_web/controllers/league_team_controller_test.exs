defmodule BackendWeb.LeagueTeamControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Fantasy

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:league_team) do
    {:ok, league_team} = Fantasy.create_league_team(@create_attrs)
    league_team
  end

  describe "index" do
    test "lists all league_teams", %{conn: conn} do
      conn = get(conn, Routes.league_team_path(conn, :index))
      assert html_response(conn, 200) =~ "League teams"
    end
  end

  describe "new league_team" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.league_team_path(conn, :new))
      assert html_response(conn, 200) =~ "New League team"
    end
  end

  describe "create league_team" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.league_team_path(conn, :create), league_team: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.league_team_path(conn, :show, id)

      conn = get(conn, Routes.league_team_path(conn, :show, id))
      assert html_response(conn, 200) =~ "League team Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.league_team_path(conn, :create), league_team: @invalid_attrs
      assert html_response(conn, 200) =~ "New League team"
    end
  end

  describe "edit league_team" do
    setup [:create_league_team]

    test "renders form for editing chosen league_team", %{conn: conn, league_team: league_team} do
      conn = get(conn, Routes.league_team_path(conn, :edit, league_team))
      assert html_response(conn, 200) =~ "Edit League team"
    end
  end

  describe "update league_team" do
    setup [:create_league_team]

    test "redirects when data is valid", %{conn: conn, league_team: league_team} do
      conn =
        put conn, Routes.league_team_path(conn, :update, league_team), league_team: @update_attrs

      assert redirected_to(conn) == Routes.league_team_path(conn, :show, league_team)

      conn = get(conn, Routes.league_team_path(conn, :show, league_team))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, league_team: league_team} do
      conn =
        put conn, Routes.league_team_path(conn, :update, league_team), league_team: @invalid_attrs

      assert html_response(conn, 200) =~ "Edit League team"
    end
  end

  describe "delete league_team" do
    setup [:create_league_team]

    test "deletes chosen league_team", %{conn: conn, league_team: league_team} do
      conn = delete(conn, Routes.league_team_path(conn, :delete, league_team))
      assert redirected_to(conn) == Routes.league_team_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.league_team_path(conn, :show, league_team))
      end
    end
  end

  defp create_league_team(_) do
    league_team = fixture(:league_team)
    {:ok, league_team: league_team}
  end
end
