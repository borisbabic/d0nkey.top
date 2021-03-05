defmodule Backend.FantasyTest do
  use Backend.DataCase

  alias Backend.Fantasy

  describe "leagues" do
    alias Backend.Fantasy.League

    @valid_attrs %{
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

    def league_fixture(attrs \\ %{}) do
      {:ok, league} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Fantasy.create_league()

      league
    end

    test "paginate_leagues/1 returns paginated list of leagues" do
      for _ <- 1..20 do
        league_fixture()
      end

      {:ok, %{leagues: leagues} = page} = Fantasy.paginate_leagues(%{})

      assert length(leagues) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_leagues/0 returns all leagues" do
      league = league_fixture()
      assert Fantasy.list_leagues() == [league]
    end

    test "get_league!/1 returns the league with given id" do
      league = league_fixture()
      assert Fantasy.get_league!(league.id) == league
    end

    test "create_league/1 with valid data creates a league" do
      assert {:ok, %League{} = league} = Fantasy.create_league(@valid_attrs)
      assert league.competition == "some competition"
      assert league.competition_type == "some competition_type"
      assert league.max_teams == 42
      assert league.name == "some name"
      assert league.point_system == "some point_system"
      assert league.roster_size == 42
    end

    test "create_league/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fantasy.create_league(@invalid_attrs)
    end

    test "update_league/2 with valid data updates the league" do
      league = league_fixture()
      assert {:ok, league} = Fantasy.update_league(league, @update_attrs)
      assert %League{} = league
      assert league.competition == "some updated competition"
      assert league.competition_type == "some updated competition_type"
      assert league.max_teams == 43
      assert league.name == "some updated name"
      assert league.point_system == "some updated point_system"
      assert league.roster_size == 43
    end

    test "update_league/2 with invalid data returns error changeset" do
      league = league_fixture()
      assert {:error, %Ecto.Changeset{}} = Fantasy.update_league(league, @invalid_attrs)
      assert league == Fantasy.get_league!(league.id)
    end

    test "delete_league/1 deletes the league" do
      league = league_fixture()
      assert {:ok, %League{}} = Fantasy.delete_league(league)
      assert_raise Ecto.NoResultsError, fn -> Fantasy.get_league!(league.id) end
    end

    test "change_league/1 returns a league changeset" do
      league = league_fixture()
      assert %Ecto.Changeset{} = Fantasy.change_league(league)
    end
  end

  describe "league_teams" do
    alias Backend.Fantasy.LeagueTeam

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def league_team_fixture(attrs \\ %{}) do
      {:ok, league_team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Fantasy.create_league_team()

      league_team
    end

    test "paginate_league_teams/1 returns paginated list of league_teams" do
      for _ <- 1..20 do
        league_team_fixture()
      end

      {:ok, %{league_teams: league_teams} = page} = Fantasy.paginate_league_teams(%{})

      assert length(league_teams) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_league_teams/0 returns all league_teams" do
      league_team = league_team_fixture()
      assert Fantasy.list_league_teams() == [league_team]
    end

    test "get_league_team!/1 returns the league_team with given id" do
      league_team = league_team_fixture()
      assert Fantasy.get_league_team!(league_team.id) == league_team
    end

    test "create_league_team/1 with valid data creates a league_team" do
      assert {:ok, %LeagueTeam{} = league_team} = Fantasy.create_league_team(@valid_attrs)
    end

    test "create_league_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fantasy.create_league_team(@invalid_attrs)
    end

    test "update_league_team/2 with valid data updates the league_team" do
      league_team = league_team_fixture()
      assert {:ok, league_team} = Fantasy.update_league_team(league_team, @update_attrs)
      assert %LeagueTeam{} = league_team
    end

    test "update_league_team/2 with invalid data returns error changeset" do
      league_team = league_team_fixture()
      assert {:error, %Ecto.Changeset{}} = Fantasy.update_league_team(league_team, @invalid_attrs)
      assert league_team == Fantasy.get_league_team!(league_team.id)
    end

    test "delete_league_team/1 deletes the league_team" do
      league_team = league_team_fixture()
      assert {:ok, %LeagueTeam{}} = Fantasy.delete_league_team(league_team)
      assert_raise Ecto.NoResultsError, fn -> Fantasy.get_league_team!(league_team.id) end
    end

    test "change_league_team/1 returns a league_team changeset" do
      league_team = league_team_fixture()
      assert %Ecto.Changeset{} = Fantasy.change_league_team(league_team)
    end
  end

  describe "league_team_picks" do
    alias Backend.Fantasy.LeagueTeamPick

    @valid_attrs %{pick: "some pick"}
    @update_attrs %{pick: "some updated pick"}
    @invalid_attrs %{pick: nil}

    def league_team_pick_fixture(attrs \\ %{}) do
      {:ok, league_team_pick} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Fantasy.create_league_team_pick()

      league_team_pick
    end

    test "paginate_league_team_picks/1 returns paginated list of league_team_picks" do
      for _ <- 1..20 do
        league_team_pick_fixture()
      end

      {:ok, %{league_team_picks: league_team_picks} = page} =
        Fantasy.paginate_league_team_picks(%{})

      assert length(league_team_picks) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_league_team_picks/0 returns all league_team_picks" do
      league_team_pick = league_team_pick_fixture()
      assert Fantasy.list_league_team_picks() == [league_team_pick]
    end

    test "get_league_team_pick!/1 returns the league_team_pick with given id" do
      league_team_pick = league_team_pick_fixture()
      assert Fantasy.get_league_team_pick!(league_team_pick.id) == league_team_pick
    end

    test "create_league_team_pick/1 with valid data creates a league_team_pick" do
      assert {:ok, %LeagueTeamPick{} = league_team_pick} =
               Fantasy.create_league_team_pick(@valid_attrs)

      assert league_team_pick.pick == "some pick"
    end

    test "create_league_team_pick/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fantasy.create_league_team_pick(@invalid_attrs)
    end

    test "update_league_team_pick/2 with valid data updates the league_team_pick" do
      league_team_pick = league_team_pick_fixture()

      assert {:ok, league_team_pick} =
               Fantasy.update_league_team_pick(league_team_pick, @update_attrs)

      assert %LeagueTeamPick{} = league_team_pick
      assert league_team_pick.pick == "some updated pick"
    end

    test "update_league_team_pick/2 with invalid data returns error changeset" do
      league_team_pick = league_team_pick_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Fantasy.update_league_team_pick(league_team_pick, @invalid_attrs)

      assert league_team_pick == Fantasy.get_league_team_pick!(league_team_pick.id)
    end

    test "delete_league_team_pick/1 deletes the league_team_pick" do
      league_team_pick = league_team_pick_fixture()
      assert {:ok, %LeagueTeamPick{}} = Fantasy.delete_league_team_pick(league_team_pick)

      assert_raise Ecto.NoResultsError, fn ->
        Fantasy.get_league_team_pick!(league_team_pick.id)
      end
    end

    test "change_league_team_pick/1 returns a league_team_pick changeset" do
      league_team_pick = league_team_pick_fixture()
      assert %Ecto.Changeset{} = Fantasy.change_league_team_pick(league_team_pick)
    end
  end
end
