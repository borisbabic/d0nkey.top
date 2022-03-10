defmodule BackendWeb.GroupControllerTest do
  use BackendWeb.ConnCase

  alias Backend.UserManager

  @create_attrs %{"name" => "some name"}
  @update_attrs %{"name" => "some updated name"}
  @invalid_attrs %{"name" => nil}

  def fixture(:group) do
    {:ok, group} = UserManager.create_group(add_owner(@create_attrs))
    group
  end

  describe "index" do
    @describetag :authenticated
    @describetag :groups
    test "lists all groups", %{conn: conn} do
      conn = get conn, Routes.group_path(conn, :index)
      assert html_response(conn, 200) =~ "Groups"
    end
  end

  describe "index auth test" do
    @describetag :authenticated
    @describetag :twitch_commands
    test "unathenticated without right role", %{conn: conn} do
      conn = get conn, Routes.group_path(conn, :index)
      assert html_response(conn, 403)
    end
  end

  defp add_owner(attrs) do
    owner = create_temp_user()
    Map.put(attrs, "owner", owner)
  end
end
