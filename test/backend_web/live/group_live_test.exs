defmodule BackendWeb.GroupLiveTest do
  use BackendWeb.ConnCase
  use BackendWeb, :verified_routes
  import Phoenix.LiveViewTest
  alias Backend.UserManager
  import Backend.UserFixtures

  test "user can join a group via the join link" do
    owner = user_fixture(%{battletag: "Owner#1111"})
    joiner = user_fixture(%{battletag: "Joiner#2222"})

    {:ok, group} = UserManager.create_group(%{"name" => "My Group"}, owner.id)

    refute UserManager.group_membership(group, joiner)

    joiner_conn = BackendWeb.ConnCase.build_conn_with_user(joiner)

    {:ok, view, html} = live(joiner_conn, ~p"/groups/#{group.id}?join_code=#{group.join_code}")

    assert html =~ "Join Group"

    view
    |> element("button", "Join Group")
    |> render_click()

    assert UserManager.group_membership(group, joiner)
  end

  test "user without a (or with an invalid) join code cannot join the group" do
    owner = user_fixture(%{battletag: "Owner#1111"})
    joiner = user_fixture(%{battletag: "Joiner#2222"})

    {:ok, group} = UserManager.create_group(%{"name" => "My Group"}, owner.id)

    joiner_conn = BackendWeb.ConnCase.build_conn_with_user(joiner)

    {:ok, _view, html} = live(joiner_conn, ~p"/groups/#{group.id}")

    refute html =~ "Join Group"
    assert html =~ "not a member of this group"
    refute UserManager.group_membership(group, joiner)

    {:ok, _view, html} =
      live(joiner_conn, ~p"/groups/#{group.id}?join_code=#{Ecto.UUID.generate()}")

    refute html =~ "Join Group"
    assert html =~ "not a member of this group"
    refute UserManager.group_membership(group, joiner)
  end
end
