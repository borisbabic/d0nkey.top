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
  end

  def assert_same(%Giveaway{} = one, %Giveaway{} = two) do
    one = Map.put(one, :creator, nil)
    two = Map.put(two, :creator, nil)
    assert ^one = two
  end
end
