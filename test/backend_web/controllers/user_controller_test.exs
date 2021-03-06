defmodule BackendWeb.UserControllerTest do
  use BackendWeb.ConnCase

  alias Backend.UserManager

  @create_attrs %{
    battlefy_slug: "some battlefy_slug",
    battletag: "some battletag",
    bnet_id: 42,
    hide_ads: true,
    country_code: "US"
  }
  @update_attrs %{
    battlefy_slug: "some updated battlefy_slug",
    battletag: "some updated battletag",
    bnet_id: 43,
    hide_ads: false,
    country_code: "IT"
  }
  @invalid_attrs %{
    battlefy_slug: nil,
    battletag: nil,
    bnet_id: nil,
    country_code: "thisistoolong"
  }

  def fixture(:user) do
    {:ok, user} = UserManager.create_user(@create_attrs)
    user
  end

  describe "index" do
    @describetag :authenticated
    @describetag :users
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Users"
    end
  end

  describe "new user" do
    @describetag :authenticated
    @describetag :users
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    @describetag :authenticated
    @describetag :users
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.user_path(conn, :create), user: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)

      conn = get(conn, Routes.user_path(conn, :show, id))
      assert html_response(conn, 200) =~ "User Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    @describetag :authenticated
    @describetag :users
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    @describetag :authenticated
    @describetag :users
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put conn, Routes.user_path(conn, :update, user), user: @update_attrs
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated battlefy_slug"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put conn, Routes.user_path(conn, :update, user), user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    @describetag :authenticated
    @describetag :users
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
