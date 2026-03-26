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
    assert html =~ "Profile Settings"
    assert html =~ "Country Flag"
    assert html =~ "Save"
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
end
