defmodule BackendWeb.GroupMembershipControllerTest do
  use BackendWeb.ConnCase

  alias Backend.UserManager

  @create_attrs %{role: "some role"}
  @update_attrs %{role: "some updated role"}
  @invalid_attrs %{role: nil}

  def fixture(:group_membership) do
    {:ok, group_membership} = Player.create_group_membership(@create_attrs)
    group_membership
  end

  describe "index" do
    test "lists all group_memberships", %{conn: conn} do
      conn = get conn, Routes.group_memberships_path(conn, :index)
      assert html_response(conn, 200) =~ "Group memberships"
    end
  end

  describe "new group_membership" do
    test "renders form", %{conn: conn} do
      conn = get conn, Routes.group_memberships_path(conn, :new)
      assert html_response(conn, 200) =~ "New Group membership"
    end
  end

  describe "create group_membership" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.group_memberships_path(conn, :create), group_membership: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.group_memberships_path(conn, :show, id)

      conn = get conn, Routes.group_memberships_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Group membership Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.group_memberships_path(conn, :create), group_membership: @invalid_attrs
      assert html_response(conn, 200) =~ "New Group membership"
    end
  end

  describe "edit group_membership" do
    setup [:create_group_membership]

    test "renders form for editing chosen group_membership", %{conn: conn, group_membership: group_membership} do
      conn = get conn, Routes.group_memberships_path(conn, :edit, group_membership)
      assert html_response(conn, 200) =~ "Edit Group membership"
    end
  end

  describe "update group_membership" do
    setup [:create_group_membership]

    test "redirects when data is valid", %{conn: conn, group_membership: group_membership} do
      conn = put conn, Routes.group_memberships_path(conn, :update, group_membership), group_membership: @update_attrs
      assert redirected_to(conn) == Routes.group_memberships_path(conn, :show, group_membership)

      conn = get conn, Routes.group_memberships_path(conn, :show, group_membership)
      assert html_response(conn, 200) =~ "some updated role"
    end

    test "renders errors when data is invalid", %{conn: conn, group_membership: group_membership} do
      conn = put conn, Routes.group_memberships_path(conn, :update, group_membership), group_membership: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Group membership"
    end
  end

  describe "delete group_membership" do
    setup [:create_group_membership]

    test "deletes chosen group_membership", %{conn: conn, group_membership: group_membership} do
      conn = delete conn, Routes.group_memberships_path(conn, :delete, group_membership)
      assert redirected_to(conn) == Routes.group_memberships_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, Routes.group_memberships_path(conn, :show, group_membership)
      end
    end
  end

  defp create_group_membership(_) do
    group_membership = fixture(:group_membership)
    {:ok, group_membership: group_membership}
  end
end
