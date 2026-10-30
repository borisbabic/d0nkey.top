defmodule BackendWeb.ProfileSettingsLiveTest do
  use BackendWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Backend.UserManager

  test "renders not logged in message", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/profile/settings")
    assert html =~ "Not Logged In"
  end

  @tag :authenticated
  test "renders profile settings form when authenticated", %{conn: conn, user: _user} do
    {:ok, _view, html} = live(conn, "/profile/settings")
    assert html =~ "Profile"
    assert html =~ "Settings"
    assert html =~ "Country Flag"
  end

  @tag :authenticated
  test "submits profile settings", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, "/profile/settings")

    form = form(view, "#profile_settings_form")

    render_submit(form, %{
      "cross_out_country" => "true",
      "show_region" => "true",
      "battlefy_slug" => "https://battlefy.com/users/test_slug"
    })

    # The component assigns the updated user on submit. Let's fetch it from DB to verify.
    updated = UserManager.get_user!(user.id)
    assert updated.cross_out_country == true
    assert updated.battlefy_slug == "test_slug"
    assert updated.show_region == true
  end

  @tag :authenticated
  test "lists and disconnects youtube channels", %{conn: conn, user: user} do
    {[channel, _], []} =
      UserManager.add_youtube_channels(user, [
        %{channel_id: "UC_one", title: "One", handle: "@one"},
        %{channel_id: "UC_two", title: "Two"}
      ])

    {:ok, view, _html} = live(conn, "/profile/settings")
    assert has_element?(view, "#youtube-channel-#{channel.id}")

    view |> element("#disconnect-youtube-#{channel.id}") |> render_click()

    refute has_element?(view, "#youtube-channel-#{channel.id}")
    assert [%{channel_id: "UC_two"}] = UserManager.youtube_channels(user)
  end

  @tag :authenticated
  test "doesn't connect a youtube channel owned by another user", %{user: user} do
    {:ok, other} = UserManager.create_user(%{battletag: "Other#1234", bnet_id: 987_654})
    {[_], []} = UserManager.add_youtube_channels(other, [%{channel_id: "UC_taken", title: "T"}])

    assert {[], [%{channel_id: "UC_taken"}]} =
             UserManager.add_youtube_channels(user, [%{channel_id: "UC_taken", title: "T"}])
  end
end
