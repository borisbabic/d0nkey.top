defmodule BackendWeb.LeagueControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Fantasy

  @create_attrs %{
    competition: "some competition",
    competition_type: "some competition_type",
    max_teams: 42,
    name: "some name",
    point_system: "some point_system",
    roster_size: 42
  }
  @update_attrs %{
    competition: "some updated competition",
    competition_type: "some updated competition_type",
    max_teams: 43,
    name: "some updated name",
    point_system: "some updated point_system",
    roster_size: 43
  }
  @invalid_attrs %{
    competition: nil,
    competition_type: nil,
    max_teams: nil,
    name: nil,
    point_system: nil,
    roster_size: nil
  }

  def fixture(:league) do
    # owner = fixtures(:users)
    {:ok, owner} = BackendWeb.ConnCase.ensure_auth_user()

    {:ok, league} =
      @create_attrs
      |> Map.put(:owner, owner)
      |> Fantasy.create_league()

    league
  end

  describe "index" do
    @describetag :authenticated
    @describetag :fantasy_leagues
    test "lists all leagues", %{conn: conn} do
      conn = get(conn, Routes.league_path(conn, :index))
      assert html_response(conn, 200) =~ "Leagues"
    end
  end

  describe "new league" do
    @describetag :authenticated
    @describetag :fantasy_leagues
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.league_path(conn, :new))
      assert html_response(conn, 200) =~ "New League"
    end
  end

  describe "create league" do
    @describetag :authenticated
    @describetag :fantasy_leagues
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.league_path(conn, :create), league: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.league_path(conn, :show, id)

      conn = get(conn, Routes.league_path(conn, :show, id))
      assert html_response(conn, 200) =~ "League Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.league_path(conn, :create), league: @invalid_attrs
      assert html_response(conn, 200) =~ "New League"
    end
  end

  describe "edit league" do
    @describetag :authenticated
    @describetag :fantasy_leagues
    setup [:create_league]

    test "renders form for editing chosen league", %{conn: conn, league: league} do
      conn = get(conn, Routes.league_path(conn, :edit, league))
      assert html_response(conn, 200) =~ "Edit League"
    end
  end

  describe "update league" do
    @describetag :authenticated
    @describetag :fantasy_leagues
    setup [:create_league]

    test "redirects when data is valid", %{conn: conn, league: league} do
      conn = put conn, Routes.league_path(conn, :update, league), league: @update_attrs
      assert redirected_to(conn) == Routes.league_path(conn, :show, league)

      conn = get(conn, Routes.league_path(conn, :show, league))
      assert html_response(conn, 200) =~ "some updated competition"
    end

    test "renders errors when data is invalid", %{conn: conn, league: league} do
      conn = put conn, Routes.league_path(conn, :update, league), league: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit League"
    end
  end

  describe "delete league" do
    @describetag :authenticated
    @describetag :fantasy_leagues
    setup [:create_league]

    test "deletes chosen league", %{conn: conn, league: league} do
      conn = delete(conn, Routes.league_path(conn, :delete, league))
      assert redirected_to(conn) == Routes.league_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.league_path(conn, :show, league))
      end
    end
  end

  defp create_league(_) do
    league = fixture(:league)
    {:ok, league: league}
  end
end
