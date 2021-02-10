defmodule Backend.BattlenetTest do
  use Backend.DataCase

  alias Backend.Battlenet

  describe "battletag_info" do
    alias Backend.Battlenet.Battletag

    @valid_attrs %{
      battletag_full: "some battletag_full",
      battletag_short: "some battletag_short",
      country: "some country",
      priority: 42,
      reported_by: "some reported_by"
    }
    @update_attrs %{
      battletag_full: "some updated battletag_full",
      battletag_short: "some updated battletag_short",
      country: "some updated country",
      priority: 43,
      reported_by: "some updated reported_by"
    }
    @invalid_attrs %{
      battletag_full: nil,
      battletag_short: nil,
      country: nil,
      priority: nil,
      reported_by: nil
    }

    def battletag_fixture(attrs \\ %{}) do
      {:ok, battletag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Battlenet.create_battletag()

      battletag
    end

    test "paginate_battletag_info/1 returns paginated list of battletag_info" do
      for _ <- 1..20 do
        battletag_fixture()
      end

      {:ok, %{battletag_info: battletag_info} = page} = Battlenet.paginate_battletag_info(%{})

      assert length(battletag_info) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_battletag_info/0 returns all battletag_info" do
      battletag = battletag_fixture()
      assert Battlenet.list_battletag_info() == [battletag]
    end

    test "get_battletag!/1 returns the battletag with given id" do
      battletag = battletag_fixture()
      assert Battlenet.get_battletag!(battletag.id) == battletag
    end

    test "create_battletag/1 with valid data creates a battletag" do
      assert {:ok, %Battletag{} = battletag} = Battlenet.create_battletag(@valid_attrs)
      assert battletag.battletag_full == "some battletag_full"
      assert battletag.battletag_short == "some battletag_short"
      assert battletag.country == "some country"
      assert battletag.priority == 42
      assert battletag.reported_by == "some reported_by"
    end

    test "create_battletag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Battlenet.create_battletag(@invalid_attrs)
    end

    test "update_battletag/2 with valid data updates the battletag" do
      battletag = battletag_fixture()
      assert {:ok, battletag} = Battlenet.update_battletag(battletag, @update_attrs)
      assert %Battletag{} = battletag
      assert battletag.battletag_full == "some updated battletag_full"
      assert battletag.battletag_short == "some updated battletag_short"
      assert battletag.country == "some updated country"
      assert battletag.priority == 43
      assert battletag.reported_by == "some updated reported_by"
    end

    test "update_battletag/2 with invalid data returns error changeset" do
      battletag = battletag_fixture()
      assert {:error, %Ecto.Changeset{}} = Battlenet.update_battletag(battletag, @invalid_attrs)
      assert battletag == Battlenet.get_battletag!(battletag.id)
    end

    test "delete_battletag/1 deletes the battletag" do
      battletag = battletag_fixture()
      assert {:ok, %Battletag{}} = Battlenet.delete_battletag(battletag)
      assert_raise Ecto.NoResultsError, fn -> Battlenet.get_battletag!(battletag.id) end
    end

    test "change_battletag/1 returns a battletag changeset" do
      battletag = battletag_fixture()
      assert %Ecto.Changeset{} = Battlenet.change_battletag(battletag)
    end
  end
end
