defmodule BackendWeb.ProfileSettingsLive do
  @moduledoc false
  use Surface.LiveView
  import BackendWeb.AuthHelper
  alias Backend.UserManager
  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.Label

  data(user, :map)

  def mount(_params, session, socket) do
    user =
      session
      |> load_user()

    {:ok, socket |> assign(:user, user)}
  end

  def render(assigns) do
    ~H"""
      <div class="container">
        <div class="title is-2">Profile Settings</div>
        <div :if={{ @user }}>
          <Form for={{ :user }} submit="submit">
            <Field name="battlefy_slug">
              <Label>Battlefy Slug</Label>
              <TextInput value={{ @user.battlefy_slug }}/>
            </Field>
            <Submit label="Save" class="button"/>
          </Form>
        </div>
        <div :if={{ !@user }}>Not Logged In</div>
      </div>
    """
  end

  def handle_event("submit", %{"user" => attrs}, socket = %{assigns: %{user: user}}) do
    updated =
      user
      |> UserManager.update_user(attrs)
      |> case do
        {:ok, u} -> u
        _ -> user
      end

    {:noreply, socket |> assign(:user, updated)}
  end
end
