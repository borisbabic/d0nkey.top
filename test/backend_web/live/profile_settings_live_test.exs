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
    assert html =~ ~s(id="profile_settings_form")
    assert html =~ "Developer API"
    assert html =~ "Generate API Key"
    assert html =~ "/api-docs"
  end

  @tag :authenticated
  test "creates, rotates, and revokes a developer API key", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, "/profile/settings")

    assert view |> element("#generate-api-key") |> render_click() =~ "Copy this key now"
    assert has_element?(view, "#new-api-key-value")

    first_key = Backend.Api.get_active_developer_api_key(user)
    assert first_key

    assert view |> element("#rotate-api-key") |> render_click() =~ "Copy this key now"
    second_key = Backend.Api.get_active_developer_api_key(user)
    refute first_key.id == second_key.id

    assert view |> element("#revoke-api-key") |> render_click() =~ "Generate API Key"
    assert Backend.Api.get_active_developer_api_key(user) == nil
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
