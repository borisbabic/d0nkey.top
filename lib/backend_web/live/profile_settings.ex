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
  alias Surface.Components.Form.ErrorTag

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
              <div class="level"> 
                <div class="level-left">
                  <div class="level-item">
                    <TextInput class="input is-small" value={{ @user.battlefy_slug }}/>
                  </div>
                  <div class="level-item">
                    <Label class="label" >Battlefy Slug</Label>
                  </div>
                  <div class="level-item">
                    <Label class="label" >Open your battlefy profile then paste the url and I'll extract it</Label>
                  </div>
                </div>
              </div>
            </Field>
            <Field name="country_code">
              <div class="level"> 
                <div class="level-left">
                  <div class="level-item">
                    <TextInput value={{ @user.country_code }} class="input is-small" />
                  </div>
                  <div class="level-item">
                    <Label class="label" >Enter 2 character <a href="https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2" target="_blank">alpha2 country code</a></Label>
                  </div>
                  <div class="level-item">
                    <ErrorTag field="country_code"/>
                  </div>
                </div>
              </div>
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
