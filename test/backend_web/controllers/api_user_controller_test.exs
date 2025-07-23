defmodule BackendWeb.ApiUserControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Api

  @create_attrs %{password: "some password", username: "some username"}
  @update_attrs %{password: "some updated password", username: "some updated username"}
  @invalid_attrs %{password: nil, username: nil}

  def fixture(:api_user) do
    {:ok, api_user} = Api.create_api_user(@create_attrs)
    api_user
  end

  describe "index" do
    @describetag :authenticated
    @describetag :api_users
    test "lists all api_users", %{conn: conn} do
      conn = get(conn, Routes.api_user_path(conn, :index))
      assert html_response(conn, 200) =~ "Api users"
    end
  end

  describe "new api_user" do
    @describetag :authenticated
    @describetag :api_users
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.api_user_path(conn, :new))
      assert html_response(conn, 200) =~ "New Api user"
    end
  end

  describe "create api_user" do
    @describetag :authenticated
    @describetag :api_users

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.api_user_path(conn, :create), api_user: @invalid_attrs
      assert html_response(conn, 200) =~ "New Api user"
    end
  end

  describe "edit api_user" do
    @describetag :authenticated
    @describetag :api_users
    setup [:create_api_user]

    test "renders form for editing chosen api_user", %{conn: conn, api_user: api_user} do
      conn = get(conn, Routes.api_user_path(conn, :edit, api_user))
      assert html_response(conn, 200) =~ "Edit Api user"
    end
  end

  describe "update api_user" do
    @describetag :authenticated
    @describetag :api_users
    setup [:create_api_user]

    test "redirects when data is valid", %{conn: conn, api_user: api_user} do
      conn = put conn, Routes.api_user_path(conn, :update, api_user), api_user: @update_attrs
      assert redirected_to(conn) == Routes.api_user_path(conn, :show, api_user)

      conn = get(conn, Routes.api_user_path(conn, :show, api_user))
      refute html_response(conn, 200) =~ api_user.password
    end
  end

  defp create_api_user(_) do
    api_user = fixture(:api_user)
    {:ok, api_user: api_user}
  end
end
