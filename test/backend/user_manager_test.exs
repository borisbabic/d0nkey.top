defmodule Backend.UserManagerTest do
  use Backend.DataCase

  alias Backend.UserManager
  alias Backend.UserManager.Group
  alias Backend.UserManager.GroupMembership

  describe "users" do
    alias Backend.UserManager.User

    @valid_attrs %{
      "battletag" => "some battletag",
      "bnet_id" => 42,
      "hide_ads" => true,
      "admin_roles" => ["users", "battletag_info"],
      "decklist_options" => %{"border" => "dark_grey", "gradient" => "card_class"}
    }
    @update_attrs %{
      "battletag" => "some updated battletag",
      "bnet_id" => 43,
      "hide_ads" => false,
      "admin_roles" => ["super"],
      "decklist_options" => %{"border" => "card_class", "gradient" => "dark_grey"}
    }
    @invalid_attrs %{"battletag" => nil, "bnet_id" => nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> UserManager.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert UserManager.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert UserManager.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = UserManager.create_user(@valid_attrs)
      assert user.battletag == "some battletag"
      assert user.bnet_id == 42
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserManager.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = UserManager.update_user(user, @update_attrs)
      assert user.battletag == "some updated battletag"
      assert user.bnet_id == 43
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = UserManager.update_user(user, @invalid_attrs)
      assert user == UserManager.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = UserManager.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> UserManager.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = UserManager.change_user(user)
    end
  end

  @valid_group_attrs %{"name" => "some name"}
  @update_group_attrs %{"name" => "some updated name"}
  @invalid_group_attrs %{"name" => nil}

  describe "#paginate_groups/1" do
    test "returns paginated list of groups" do
      for _ <- 1..20 do
        group_fixture()
      end

      {:ok, %{groups: groups} = page} = UserManager.paginate_groups(%{})

      assert length(groups) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end
  end

  describe "#list_groups/0" do
    test "returns all groups" do
      group = group_fixture()
      assert UserManager.list_groups() |> delete_owners() == [group] |> delete_owners()
    end
  end

  defp delete_owners(groups), do: Enum.map(groups, & Map.delete(&1, :owner))

  describe "#get_group!/1" do
    test "returns the group with given id" do
      group = group_fixture()
      assert UserManager.get_group!(group.id) == group
    end
  end

  describe "#create_group/1" do
    test "with valid data creates a group" do
      assert {:ok, %Group{} = group} = UserManager.create_group(@valid_group_attrs, owner_id())
      assert group.name == "some name"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserManager.create_group(@invalid_group_attrs, owner_id())
    end
  end

  describe "#update_group/2" do
    test "with valid data updates the group" do
      group = group_fixture()
      assert {:ok, group} = UserManager.update_group(group, @update_group_attrs)
      assert %Group{} = group
      assert group.name == "some updated name"
    end

    test "with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = UserManager.update_group(group, @invalid_group_attrs)
      assert group == UserManager.get_group!(group.id)
    end
  end

  describe "#change_group/1" do
    test "returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = UserManager.change_group(group)
    end
  end

  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(@valid_group_attrs)
      |> UserManager.create_group(owner_id())

    group
  end

  def owner_id() do
    user = create_temp_user()

    user.id
  end

end
