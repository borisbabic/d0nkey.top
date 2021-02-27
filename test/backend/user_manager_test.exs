defmodule Backend.UserManagerTest do
  use Backend.DataCase

  alias Backend.UserManager

  describe "users" do
    alias Backend.UserManager.User

    @valid_attrs %{
      battletag: "some battletag",
      bnet_id: 42,
      hide_ads: true,
      admin_roles: ["users", "battletag_info"],
      decklist_options: %{"border" => "dark_grey", "gradient" => "card_class"}
    }
    @update_attrs %{
      battletag: "some updated battletag",
      bnet_id: 43,
      hide_ads: false,
      admin_roles: ["super"],
      decklist_options: %{"border" => "card_class", "gradient" => "dark_grey"}
    }
    @invalid_attrs %{battletag: nil, bnet_id: nil}

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
end
