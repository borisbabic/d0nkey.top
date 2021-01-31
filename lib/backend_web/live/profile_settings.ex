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
              <Label>Open your battlefy profile then paste the url and I'll extract it</Label>
            </Field>
            <Submit label="Save" class="button"/>
          </Form>
        </div>
        <div :if={{ !@user }}>Not Logged In</div>
      </div>
    """
  end

  def handle_event("submit", %{"user" => attrs_raw}, socket = %{assigns: %{user: user}}) do
    attrs =
      attrs_raw
      |> parse_battlefy_slug()

    updated =
      user
      |> UserManager.update_user(attrs)
      |> case do
        {:ok, u} -> u
        _ -> user
      end

    {:noreply, socket |> assign(:user, updated)}
  end

  def parse_battlefy_slug(
        attrs = %{"battlefy_slug" => <<"https://battlefy.com/users/"::binary, slug::binary>>}
      ),
      do: attrs |> Map.put("battlefy_slug", slug)

  def parse_battlefy_slug(attrs), do: attrs
end
