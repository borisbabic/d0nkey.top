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
      {:ok, owner} = BackendWeb.ConnCase.ensure_auth_user()

      {:ok, league} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:owner, owner)
        |> Fantasy.create_league()

      league
      |> Backend.Fantasy.preload_league()
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
      {:ok, owner} = BackendWeb.ConnCase.ensure_auth_user()
      attrs = @valid_attrs |> Map.put(:owner, owner)
      assert {:ok, %League{} = league} = Fantasy.create_league(attrs)
      assert league.competition == "some competition"
      assert league.competition_type == "some competition_type"
      assert league.max_teams == 42
      assert league.name == "some name"
      assert league.point_system == "some point_system"
      assert league.roster_size == 42
      assert league.owner.id == owner.id
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
end
