defmodule Backend.ApiTest do
  use Backend.DataCase

  alias Backend.Api

  describe "api_users" do
    alias Backend.Api.ApiUser

    @valid_attrs %{password: "some password", username: "some username"}
    @update_attrs %{password: "some updated password", username: "some updated username"}
    @invalid_attrs %{password: nil, username: nil}

    def api_user_fixture(attrs \\ %{}) do
      {:ok, api_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Api.create_api_user()

      api_user
    end

    test "paginate_api_users/1 returns paginated list of api_users" do
      for _ <- 1..20 do
        api_user_fixture()
      end

      {:ok, %{api_users: api_users} = page} = Api.paginate_api_users(%{})

      assert length(api_users) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_api_users/0 returns all api_users" do
      api_user = api_user_fixture()
      assert Api.list_api_users() == [api_user]
    end

    test "get_api_user!/1 returns the api_user with given id" do
      api_user = api_user_fixture()
      assert Api.get_api_user!(api_user.id) == api_user
    end

    test "create_api_user/1 with valid data creates a api_user" do
      assert {:ok, %ApiUser{} = api_user} = Api.create_api_user(@valid_attrs)
      assert ApiUser.verify_password?(api_user, @valid_attrs[:password])
      assert api_user.username == "some username"
    end

    test "create_api_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Api.create_api_user(@invalid_attrs)
    end

    test "update_api_user/2 with valid data updates the api_user" do
      api_user = api_user_fixture()
      assert {:ok, api_user} = Api.update_api_user(api_user, @update_attrs)
      assert %ApiUser{} = api_user
      assert ApiUser.verify_password?(api_user, @update_attrs[:password])
      assert api_user.username == "some updated username"
    end

    test "update_api_user/2 with invalid data returns error changeset" do
      api_user = api_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Api.update_api_user(api_user, @invalid_attrs)
      assert api_user == Api.get_api_user!(api_user.id)
    end

    test "delete_api_user/1 deletes the api_user" do
      api_user = api_user_fixture()
      assert {:ok, %ApiUser{}} = Api.delete_api_user(api_user)
      assert_raise Ecto.NoResultsError, fn -> Api.get_api_user!(api_user.id) end
    end

    test "change_api_user/1 returns a api_user changeset" do
      api_user = api_user_fixture()
      assert %Ecto.Changeset{} = Api.change_api_user(api_user)
    end
  end
end
