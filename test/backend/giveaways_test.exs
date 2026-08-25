defmodule Backend.GiveawaysTest do
  use Backend.DataCase

  alias Backend.Giveaways
  alias Backend.Giveaways.Giveaway

  import Backend.GiveawaysFixtures
  import Backend.UserFixtures

  describe "giveaways" do
    alias Backend.Giveaways.Giveaway

    @invalid_attrs %{name: nil, config: nil, deadline: nil}

    test "list_giveaways/0 returns all giveaways" do
      giveaway = giveaway_fixture()
      assert Giveaways.list_giveaways() == [giveaway]
    end

    test "get_giveaway!/1 returns the giveaway with given id" do
      giveaway = giveaway_fixture()
      assert_same(Giveaways.get_giveaway!(giveaway.id), giveaway)
    end

    test "create_giveaway/1 with valid data creates a giveaway" do
      creator = user_fixture()
      valid_attrs = %{name: "some name", config: %{}, deadline: ~N[2026-06-29 22:57:00]}

      assert {:ok, %Giveaway{} = giveaway} = Giveaways.create_giveaway(valid_attrs, creator)
      assert giveaway.name == "some name"
      assert giveaway.creator_id == creator.id
      assert giveaway.config == %{}
      assert giveaway.deadline == ~N[2026-06-29 22:57:00]
    end

    test "create_giveaway/1 with invalid data returns error changeset" do
      creator = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Giveaways.create_giveaway(@invalid_attrs, creator)
    end

    test "update_giveaway/2 with valid data updates the giveaway" do
      creator = user_fixture()
      giveaway = giveaway_fixture(%{creator: creator})
      update_attrs = %{name: "some updated name", config: %{}, deadline: ~N[2026-06-30 22:57:00]}

      assert {:ok, %Giveaway{} = giveaway} = Giveaways.update_giveaway(giveaway, update_attrs)
      assert giveaway.name == "some updated name"
      assert giveaway.creator_id == creator.id
      assert giveaway.config == %{}
      assert giveaway.deadline == ~N[2026-06-30 22:57:00]
    end

    test "update_giveaway/2 with invalid data returns error changeset" do
      giveaway = giveaway_fixture()
      assert {:error, %Ecto.Changeset{}} = Giveaways.update_giveaway(giveaway, @invalid_attrs)
      assert_same(giveaway, Giveaways.get_giveaway!(giveaway.id))
    end

    test "delete_giveaway/1 deletes the giveaway" do
      giveaway = giveaway_fixture()
      assert {:ok, %Giveaway{}} = Giveaways.delete_giveaway(giveaway)
      assert_raise Ecto.NoResultsError, fn -> Giveaways.get_giveaway!(giveaway.id) end
    end

    test "change_giveaway/1 returns a giveaway changeset" do
      giveaway = giveaway_fixture()
      assert %Ecto.Changeset{} = Giveaways.change_giveaway(giveaway)
    end
  end

  describe "giveaway_entrys" do
    test "enter/2 errors when called twice" do
      giveaway = giveaway_fixture()
      user = user_fixture()
      assert {:ok, _} = Giveaways.enter(giveaway, user)
      assert {:error, _} = Giveaways.enter(giveaway, user)
    end

    test "create_giveaway/2 with codes sets normalized codes" do
      creator = user_fixture()

      valid_attrs = %{
        name: "Giveaway with codes",
        deadline: ~N[2026-06-29 22:57:00],
        codes: "CODE_A\nCODE_B\n\nCODE_C "
      }

      assert {:ok, %Giveaway{} = giveaway} = Giveaways.create_giveaway(valid_attrs, creator)
      assert giveaway.codes == ["CODE_A", "CODE_B", "CODE_C"]
    end

    test "pick_winners/2 assigns distinct codes to each winner" do
      creator = user_fixture()

      giveaway =
        giveaway_fixture(%{
          creator: creator,
          number_of_winners: 2,
          codes: ["CODE_A", "CODE_B"]
        })

      user1 = user_fixture(%{battletag: "User1#1001"})
      user2 = user_fixture(%{battletag: "User2#1002"})

      assert {:ok, _} = Giveaways.enter(giveaway, user1)
      assert {:ok, _} = Giveaways.enter(giveaway, user2)

      assert {:ok, entries} = Giveaways.pick_winners(giveaway, creator)
      winners = Enum.filter(entries, & &1.winner)

      assert length(winners) == 2
      winner_codes = Enum.map(winners, & &1.code) |> Enum.sort()
      assert winner_codes == ["CODE_A", "CODE_B"]

      # Verify each winner only sees their own assigned code
      [winner1_entry, winner2_entry] = winners
      entry1 = Giveaways.get_entry(giveaway, winner1_entry.user)
      entry2 = Giveaways.get_entry(giveaway, winner2_entry.user)

      assert entry1.code == winner1_entry.code
      assert entry2.code == winner2_entry.code
      assert entry1.code != entry2.code
    end

    test "save_codes/2 syncs codes to already picked winners" do
      creator = user_fixture()

      giveaway =
        giveaway_fixture(%{
          creator: creator,
          number_of_winners: 2,
          codes: []
        })

      user1 = user_fixture(%{battletag: "User1#1001"})
      user2 = user_fixture(%{battletag: "User2#1002"})

      assert {:ok, _} = Giveaways.enter(giveaway, user1)
      assert {:ok, _} = Giveaways.enter(giveaway, user2)

      assert {:ok, entries} = Giveaways.pick_winners(giveaway, creator)
      winners = Enum.filter(entries, & &1.winner)
      assert Enum.all?(winners, &is_nil(&1.code))

      # Creator now adds codes
      assert {:ok, updated_giveaway} = Giveaways.save_codes(giveaway, ["PRIZE_1", "PRIZE_2"])
      assert updated_giveaway.codes == ["PRIZE_1", "PRIZE_2"]

      [winner1, winner2] = winners
      code1 = Giveaways.get_entry(giveaway, winner1.user).code
      code2 = Giveaways.get_entry(giveaway, winner2.user).code
      assert Enum.sort([code1, code2]) == ["PRIZE_1", "PRIZE_2"]
    end

    test "picking additional winners later preserves earlier winners' codes and assigns next code" do
      creator = user_fixture()

      giveaway =
        giveaway_fixture(%{
          creator: creator,
          number_of_winners: 1,
          codes: ["CODE_1", "CODE_2"]
        })

      user1 = user_fixture(%{battletag: "User1#1001"})
      user2 = user_fixture(%{battletag: "User2#1002"})

      assert {:ok, _} = Giveaways.enter(giveaway, user1)
      assert {:ok, _} = Giveaways.enter(giveaway, user2)

      assert {:ok, entries} = Giveaways.pick_winners(giveaway, creator)
      winner1 = Enum.find(entries, & &1.winner)
      assert winner1.code == "CODE_1"

      # Expand giveaway to 2 winners
      {:ok, giveaway} = Giveaways.update_giveaway(giveaway, %{number_of_winners: 2})
      assert {:ok, entries2} = Giveaways.pick_winners(giveaway, creator)
      winners2 = Enum.filter(entries2, & &1.winner)

      assert length(winners2) == 2
      first_winner = Enum.find(winners2, &(&1.id == winner1.id))
      second_winner = Enum.find(winners2, &(&1.id != winner1.id))

      assert first_winner.code == "CODE_1"
      assert second_winner.code == "CODE_2"
    end

    test "winner?/1 returns true only for current giveaway winner" do
      creator = user_fixture()

      giveaway =
        giveaway_fixture(%{
          creator: creator,
          deadline: Timex.shift(NaiveDateTime.utc_now(), hours: 1),
          number_of_winners: 1,
          codes: ["WINNER_CODE"]
        })

      user1 = user_fixture()
      user2 = user_fixture()

      assert {:ok, _} = Giveaways.enter(giveaway, user1)
      assert {:ok, _} = Giveaways.enter(giveaway, user2)
      assert {:ok, _} = Giveaways.pick_winners(giveaway, creator)

      entry1 = Giveaways.get_entry(giveaway, user1)

      if entry1.winner do
        assert Giveaways.winner?(user1) == true
        assert Giveaways.winner?(user2) == false
      else
        assert Giveaways.winner?(user1) == false
        assert Giveaways.winner?(user2) == true
      end

      assert Giveaways.winner?(nil) == false
    end
  end

  def assert_same(%Giveaway{} = one, %Giveaway{} = two) do
    one = Map.put(one, :creator, nil)
    two = Map.put(two, :creator, nil)
    assert ^one = two
  end
end
