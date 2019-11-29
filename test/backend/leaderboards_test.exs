defmodule Backend.LeaderboardsTest do
  use Backend.DataCase

  alias Backend.Leaderboards

  describe "leaderboard_snapshot" do
    alias Backend.Leaderboards.LeaderboardSnapshot

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def leaderboard_snapshot_fixture(attrs \\ %{}) do
      {:ok, leaderboard_snapshot} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Leaderboards.create_leaderboard_snapshot()

      leaderboard_snapshot
    end

    test "list_leaderboard_snapshot/0 returns all leaderboard_snapshot" do
      leaderboard_snapshot = leaderboard_snapshot_fixture()
      assert Leaderboards.list_leaderboard_snapshot() == [leaderboard_snapshot]
    end

    test "get_leaderboard_snapshot!/1 returns the leaderboard_snapshot with given id" do
      leaderboard_snapshot = leaderboard_snapshot_fixture()
      assert Leaderboards.get_leaderboard_snapshot!(leaderboard_snapshot.id) == leaderboard_snapshot
    end

    test "create_leaderboard_snapshot/1 with valid data creates a leaderboard_snapshot" do
      assert {:ok, %LeaderboardSnapshot{} = leaderboard_snapshot} = Leaderboards.create_leaderboard_snapshot(@valid_attrs)
    end

    test "create_leaderboard_snapshot/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Leaderboards.create_leaderboard_snapshot(@invalid_attrs)
    end

    test "update_leaderboard_snapshot/2 with valid data updates the leaderboard_snapshot" do
      leaderboard_snapshot = leaderboard_snapshot_fixture()
      assert {:ok, %LeaderboardSnapshot{} = leaderboard_snapshot} = Leaderboards.update_leaderboard_snapshot(leaderboard_snapshot, @update_attrs)
    end

    test "update_leaderboard_snapshot/2 with invalid data returns error changeset" do
      leaderboard_snapshot = leaderboard_snapshot_fixture()
      assert {:error, %Ecto.Changeset{}} = Leaderboards.update_leaderboard_snapshot(leaderboard_snapshot, @invalid_attrs)
      assert leaderboard_snapshot == Leaderboards.get_leaderboard_snapshot!(leaderboard_snapshot.id)
    end

    test "delete_leaderboard_snapshot/1 deletes the leaderboard_snapshot" do
      leaderboard_snapshot = leaderboard_snapshot_fixture()
      assert {:ok, %LeaderboardSnapshot{}} = Leaderboards.delete_leaderboard_snapshot(leaderboard_snapshot)
      assert_raise Ecto.NoResultsError, fn -> Leaderboards.get_leaderboard_snapshot!(leaderboard_snapshot.id) end
    end

    test "change_leaderboard_snapshot/1 returns a leaderboard_snapshot changeset" do
      leaderboard_snapshot = leaderboard_snapshot_fixture()
      assert %Ecto.Changeset{} = Leaderboards.change_leaderboard_snapshot(leaderboard_snapshot)
    end
  end

  describe "leaderboard" do
    alias Backend.Leaderboards.Leaderboard

    @valid_attrs %{server: "some server", start_date: "2010-04-17T14:00:00Z", upstream_id: 42}
    @update_attrs %{server: "some updated server", start_date: "2011-05-18T15:01:01Z", upstream_id: 43}
    @invalid_attrs %{server: nil, start_date: nil, upstream_id: nil}

    def leaderboard_fixture(attrs \\ %{}) do
      {:ok, leaderboard} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Leaderboards.create_leaderboard()

      leaderboard
    end

    test "list_leaderboard/0 returns all leaderboard" do
      leaderboard = leaderboard_fixture()
      assert Leaderboards.list_leaderboard() == [leaderboard]
    end

    test "get_leaderboard!/1 returns the leaderboard with given id" do
      leaderboard = leaderboard_fixture()
      assert Leaderboards.get_leaderboard!(leaderboard.id) == leaderboard
    end

    test "create_leaderboard/1 with valid data creates a leaderboard" do
      assert {:ok, %Leaderboard{} = leaderboard} = Leaderboards.create_leaderboard(@valid_attrs)
      assert leaderboard.server == "some server"
      assert leaderboard.start_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert leaderboard.upstream_id == 42
    end

    test "create_leaderboard/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Leaderboards.create_leaderboard(@invalid_attrs)
    end

    test "update_leaderboard/2 with valid data updates the leaderboard" do
      leaderboard = leaderboard_fixture()
      assert {:ok, %Leaderboard{} = leaderboard} = Leaderboards.update_leaderboard(leaderboard, @update_attrs)
      assert leaderboard.server == "some updated server"
      assert leaderboard.start_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert leaderboard.upstream_id == 43
    end

    test "update_leaderboard/2 with invalid data returns error changeset" do
      leaderboard = leaderboard_fixture()
      assert {:error, %Ecto.Changeset{}} = Leaderboards.update_leaderboard(leaderboard, @invalid_attrs)
      assert leaderboard == Leaderboards.get_leaderboard!(leaderboard.id)
    end

    test "delete_leaderboard/1 deletes the leaderboard" do
      leaderboard = leaderboard_fixture()
      assert {:ok, %Leaderboard{}} = Leaderboards.delete_leaderboard(leaderboard)
      assert_raise Ecto.NoResultsError, fn -> Leaderboards.get_leaderboard!(leaderboard.id) end
    end

    test "change_leaderboard/1 returns a leaderboard changeset" do
      leaderboard = leaderboard_fixture()
      assert %Ecto.Changeset{} = Leaderboards.change_leaderboard(leaderboard)
    end
  end

  describe "leaderboard_entry" do
    alias Backend.Leaderboards.LeaderboardEntry

    @valid_attrs %{battletag: "some battletag"}
    @update_attrs %{battletag: "some updated battletag"}
    @invalid_attrs %{battletag: nil}

    def leaderboard_entry_fixture(attrs \\ %{}) do
      {:ok, leaderboard_entry} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Leaderboards.create_leaderboard_entry()

      leaderboard_entry
    end

    test "list_leaderboard_entry/0 returns all leaderboard_entry" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert Leaderboards.list_leaderboard_entry() == [leaderboard_entry]
    end

    test "get_leaderboard_entry!/1 returns the leaderboard_entry with given id" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert Leaderboards.get_leaderboard_entry!(leaderboard_entry.id) == leaderboard_entry
    end

    test "create_leaderboard_entry/1 with valid data creates a leaderboard_entry" do
      assert {:ok, %LeaderboardEntry{} = leaderboard_entry} = Leaderboards.create_leaderboard_entry(@valid_attrs)
      assert leaderboard_entry.battletag == "some battletag"
    end

    test "create_leaderboard_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Leaderboards.create_leaderboard_entry(@invalid_attrs)
    end

    test "update_leaderboard_entry/2 with valid data updates the leaderboard_entry" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert {:ok, %LeaderboardEntry{} = leaderboard_entry} = Leaderboards.update_leaderboard_entry(leaderboard_entry, @update_attrs)
      assert leaderboard_entry.battletag == "some updated battletag"
    end

    test "update_leaderboard_entry/2 with invalid data returns error changeset" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Leaderboards.update_leaderboard_entry(leaderboard_entry, @invalid_attrs)
      assert leaderboard_entry == Leaderboards.get_leaderboard_entry!(leaderboard_entry.id)
    end

    test "delete_leaderboard_entry/1 deletes the leaderboard_entry" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert {:ok, %LeaderboardEntry{}} = Leaderboards.delete_leaderboard_entry(leaderboard_entry)
      assert_raise Ecto.NoResultsError, fn -> Leaderboards.get_leaderboard_entry!(leaderboard_entry.id) end
    end

    test "change_leaderboard_entry/1 returns a leaderboard_entry changeset" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert %Ecto.Changeset{} = Leaderboards.change_leaderboard_entry(leaderboard_entry)
    end
  end

  describe "leaderboard_entry" do
    alias Backend.Leaderboards.LeaderboardEntry

    @valid_attrs %{battletag: "some battletag", position: 42, rating: 42}
    @update_attrs %{battletag: "some updated battletag", position: 43, rating: 43}
    @invalid_attrs %{battletag: nil, position: nil, rating: nil}

    def leaderboard_entry_fixture(attrs \\ %{}) do
      {:ok, leaderboard_entry} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Leaderboards.create_leaderboard_entry()

      leaderboard_entry
    end

    test "list_leaderboard_entry/0 returns all leaderboard_entry" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert Leaderboards.list_leaderboard_entry() == [leaderboard_entry]
    end

    test "get_leaderboard_entry!/1 returns the leaderboard_entry with given id" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert Leaderboards.get_leaderboard_entry!(leaderboard_entry.id) == leaderboard_entry
    end

    test "create_leaderboard_entry/1 with valid data creates a leaderboard_entry" do
      assert {:ok, %LeaderboardEntry{} = leaderboard_entry} = Leaderboards.create_leaderboard_entry(@valid_attrs)
      assert leaderboard_entry.battletag == "some battletag"
      assert leaderboard_entry.position == 42
      assert leaderboard_entry.rating == 42
    end

    test "create_leaderboard_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Leaderboards.create_leaderboard_entry(@invalid_attrs)
    end

    test "update_leaderboard_entry/2 with valid data updates the leaderboard_entry" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert {:ok, %LeaderboardEntry{} = leaderboard_entry} = Leaderboards.update_leaderboard_entry(leaderboard_entry, @update_attrs)
      assert leaderboard_entry.battletag == "some updated battletag"
      assert leaderboard_entry.position == 43
      assert leaderboard_entry.rating == 43
    end

    test "update_leaderboard_entry/2 with invalid data returns error changeset" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Leaderboards.update_leaderboard_entry(leaderboard_entry, @invalid_attrs)
      assert leaderboard_entry == Leaderboards.get_leaderboard_entry!(leaderboard_entry.id)
    end

    test "delete_leaderboard_entry/1 deletes the leaderboard_entry" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert {:ok, %LeaderboardEntry{}} = Leaderboards.delete_leaderboard_entry(leaderboard_entry)
      assert_raise Ecto.NoResultsError, fn -> Leaderboards.get_leaderboard_entry!(leaderboard_entry.id) end
    end

    test "change_leaderboard_entry/1 returns a leaderboard_entry changeset" do
      leaderboard_entry = leaderboard_entry_fixture()
      assert %Ecto.Changeset{} = Leaderboards.change_leaderboard_entry(leaderboard_entry)
    end
  end

  describe "leaderboard" do
    alias Backend.Leaderboards.Leaderboard

    @valid_attrs %{leaderboard_id: "some leaderboard_id", server: "some server", start_date: "2010-04-17T14:00:00Z", upstream_id: 42}
    @update_attrs %{leaderboard_id: "some updated leaderboard_id", server: "some updated server", start_date: "2011-05-18T15:01:01Z", upstream_id: 43}
    @invalid_attrs %{leaderboard_id: nil, server: nil, start_date: nil, upstream_id: nil}

    def leaderboard_fixture(attrs \\ %{}) do
      {:ok, leaderboard} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Leaderboards.create_leaderboard()

      leaderboard
    end

    test "list_leaderboard/0 returns all leaderboard" do
      leaderboard = leaderboard_fixture()
      assert Leaderboards.list_leaderboard() == [leaderboard]
    end

    test "get_leaderboard!/1 returns the leaderboard with given id" do
      leaderboard = leaderboard_fixture()
      assert Leaderboards.get_leaderboard!(leaderboard.id) == leaderboard
    end

    test "create_leaderboard/1 with valid data creates a leaderboard" do
      assert {:ok, %Leaderboard{} = leaderboard} = Leaderboards.create_leaderboard(@valid_attrs)
      assert leaderboard.leaderboard_id == "some leaderboard_id"
      assert leaderboard.server == "some server"
      assert leaderboard.start_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert leaderboard.upstream_id == 42
    end

    test "create_leaderboard/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Leaderboards.create_leaderboard(@invalid_attrs)
    end

    test "update_leaderboard/2 with valid data updates the leaderboard" do
      leaderboard = leaderboard_fixture()
      assert {:ok, %Leaderboard{} = leaderboard} = Leaderboards.update_leaderboard(leaderboard, @update_attrs)
      assert leaderboard.leaderboard_id == "some updated leaderboard_id"
      assert leaderboard.server == "some updated server"
      assert leaderboard.start_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert leaderboard.upstream_id == 43
    end

    test "update_leaderboard/2 with invalid data returns error changeset" do
      leaderboard = leaderboard_fixture()
      assert {:error, %Ecto.Changeset{}} = Leaderboards.update_leaderboard(leaderboard, @invalid_attrs)
      assert leaderboard == Leaderboards.get_leaderboard!(leaderboard.id)
    end

    test "delete_leaderboard/1 deletes the leaderboard" do
      leaderboard = leaderboard_fixture()
      assert {:ok, %Leaderboard{}} = Leaderboards.delete_leaderboard(leaderboard)
      assert_raise Ecto.NoResultsError, fn -> Leaderboards.get_leaderboard!(leaderboard.id) end
    end

    test "change_leaderboard/1 returns a leaderboard changeset" do
      leaderboard = leaderboard_fixture()
      assert %Ecto.Changeset{} = Leaderboards.change_leaderboard(leaderboard)
    end
  end

  describe "leaderboard" do
    alias Backend.Leaderboards.Leaderboard

    @valid_attrs %{leaderboard_id: "some leaderboard_id", region: "some region", server: "some server", start_date: "2010-04-17T14:00:00Z", upstream_id: 42}
    @update_attrs %{leaderboard_id: "some updated leaderboard_id", region: "some updated region", server: "some updated server", start_date: "2011-05-18T15:01:01Z", upstream_id: 43}
    @invalid_attrs %{leaderboard_id: nil, region: nil, server: nil, start_date: nil, upstream_id: nil}

    def leaderboard_fixture(attrs \\ %{}) do
      {:ok, leaderboard} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Leaderboards.create_leaderboard()

      leaderboard
    end

    test "list_leaderboard/0 returns all leaderboard" do
      leaderboard = leaderboard_fixture()
      assert Leaderboards.list_leaderboard() == [leaderboard]
    end

    test "get_leaderboard!/1 returns the leaderboard with given id" do
      leaderboard = leaderboard_fixture()
      assert Leaderboards.get_leaderboard!(leaderboard.id) == leaderboard
    end

    test "create_leaderboard/1 with valid data creates a leaderboard" do
      assert {:ok, %Leaderboard{} = leaderboard} = Leaderboards.create_leaderboard(@valid_attrs)
      assert leaderboard.leaderboard_id == "some leaderboard_id"
      assert leaderboard.region == "some region"
      assert leaderboard.server == "some server"
      assert leaderboard.start_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert leaderboard.upstream_id == 42
    end

    test "create_leaderboard/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Leaderboards.create_leaderboard(@invalid_attrs)
    end

    test "update_leaderboard/2 with valid data updates the leaderboard" do
      leaderboard = leaderboard_fixture()
      assert {:ok, %Leaderboard{} = leaderboard} = Leaderboards.update_leaderboard(leaderboard, @update_attrs)
      assert leaderboard.leaderboard_id == "some updated leaderboard_id"
      assert leaderboard.region == "some updated region"
      assert leaderboard.server == "some updated server"
      assert leaderboard.start_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert leaderboard.upstream_id == 43
    end

    test "update_leaderboard/2 with invalid data returns error changeset" do
      leaderboard = leaderboard_fixture()
      assert {:error, %Ecto.Changeset{}} = Leaderboards.update_leaderboard(leaderboard, @invalid_attrs)
      assert leaderboard == Leaderboards.get_leaderboard!(leaderboard.id)
    end

    test "delete_leaderboard/1 deletes the leaderboard" do
      leaderboard = leaderboard_fixture()
      assert {:ok, %Leaderboard{}} = Leaderboards.delete_leaderboard(leaderboard)
      assert_raise Ecto.NoResultsError, fn -> Leaderboards.get_leaderboard!(leaderboard.id) end
    end

    test "change_leaderboard/1 returns a leaderboard changeset" do
      leaderboard = leaderboard_fixture()
      assert %Ecto.Changeset{} = Leaderboards.change_leaderboard(leaderboard)
    end
  end

  describe "leaderboard" do
    alias Backend.Leaderboards.Leaderboard

    @valid_attrs %{leaderboard_id: "some leaderboard_id", region: "some region", season_id: "some season_id", start_date: "2010-04-17T14:00:00Z", upstream_id: 42}
    @update_attrs %{leaderboard_id: "some updated leaderboard_id", region: "some updated region", season_id: "some updated season_id", start_date: "2011-05-18T15:01:01Z", upstream_id: 43}
    @invalid_attrs %{leaderboard_id: nil, region: nil, season_id: nil, start_date: nil, upstream_id: nil}

    def leaderboard_fixture(attrs \\ %{}) do
      {:ok, leaderboard} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Leaderboards.create_leaderboard()

      leaderboard
    end

    test "list_leaderboard/0 returns all leaderboard" do
      leaderboard = leaderboard_fixture()
      assert Leaderboards.list_leaderboard() == [leaderboard]
    end

    test "get_leaderboard!/1 returns the leaderboard with given id" do
      leaderboard = leaderboard_fixture()
      assert Leaderboards.get_leaderboard!(leaderboard.id) == leaderboard
    end

    test "create_leaderboard/1 with valid data creates a leaderboard" do
      assert {:ok, %Leaderboard{} = leaderboard} = Leaderboards.create_leaderboard(@valid_attrs)
      assert leaderboard.leaderboard_id == "some leaderboard_id"
      assert leaderboard.region == "some region"
      assert leaderboard.season_id == "some season_id"
      assert leaderboard.start_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert leaderboard.upstream_id == 42
    end

    test "create_leaderboard/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Leaderboards.create_leaderboard(@invalid_attrs)
    end

    test "update_leaderboard/2 with valid data updates the leaderboard" do
      leaderboard = leaderboard_fixture()
      assert {:ok, %Leaderboard{} = leaderboard} = Leaderboards.update_leaderboard(leaderboard, @update_attrs)
      assert leaderboard.leaderboard_id == "some updated leaderboard_id"
      assert leaderboard.region == "some updated region"
      assert leaderboard.season_id == "some updated season_id"
      assert leaderboard.start_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert leaderboard.upstream_id == 43
    end

    test "update_leaderboard/2 with invalid data returns error changeset" do
      leaderboard = leaderboard_fixture()
      assert {:error, %Ecto.Changeset{}} = Leaderboards.update_leaderboard(leaderboard, @invalid_attrs)
      assert leaderboard == Leaderboards.get_leaderboard!(leaderboard.id)
    end

    test "delete_leaderboard/1 deletes the leaderboard" do
      leaderboard = leaderboard_fixture()
      assert {:ok, %Leaderboard{}} = Leaderboards.delete_leaderboard(leaderboard)
      assert_raise Ecto.NoResultsError, fn -> Leaderboards.get_leaderboard!(leaderboard.id) end
    end

    test "change_leaderboard/1 returns a leaderboard changeset" do
      leaderboard = leaderboard_fixture()
      assert %Ecto.Changeset{} = Leaderboards.change_leaderboard(leaderboard)
    end
  end
end
