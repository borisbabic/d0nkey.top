defmodule BackendWeb.ProfileSettingsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Streaming
  alias Backend.UserManager
  alias Backend.UserManager.User.DecklistOptions
  alias Surface.Components.Form
  alias Surface.Components.Form.Checkbox
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.Select
  alias Surface.Components.Form.Label

  data(user, :map)

  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session)}
  end

  def render(assigns) do
    ~F"""
     <Context put={user: @user}>
      <div>
        <div class="title is-2">Profile Settings</div>
        <div id="nitropay-below-title-leaderboard"></div><br>
        <div :if={@user}>
          <Form for={:user} submit="submit">
            <Field name="battlefy_slug">
              <Label class="label" >Battlefy Slug. Open your battlefy profile then paste the url and I'll extract it</Label>
              <TextInput class="input is-small" value={@user.battlefy_slug}/>
            </Field>
            <br>
            <Field name="country_code">
              <Label class="label" >Country Flag</Label>
              <Select class="select" options={[{"Select Country", nil} | country_options()]} selected={@user.country_code} />
            </Field>
            <Field name="cross_out_country">
              <Label class="label" >Cross Out Country</Label>
              <Checkbox value={@user.cross_out_country} />
            </Field>
            <Field name="show_region">
              <Label class="label" >Show Region Instead of Country</Label>
              <Checkbox value={@user.show_region} />
            </Field>
            <br>
            <Field name="unicode_icon">
              <Label class="label">Player Icon</Label>
              <Select selected={@user.unicode_icon} class="select" options={[{"None/Custom", nil}, {pride_flag(), pride_flag()}, {peace_symbol(), peace_symbol()}]}/>
              For custom icons see <a href="/patreon">patreon</a>
            </Field>
            <br>
            <Label class="label">Decklist Options</Label>
            <Field name="border">
              <Select selected={DecklistOptions.border(@user.decklist_options)} class="select" options={"Border Color": "border_color", "Card Class": "card_class", "Deck Class": "deck_class", "Rarity": "rarity", "Dark Grey": "dark_grey"}/>
              <Label>Border Color</Label>
            </Field>
            <Field name="gradient">
              <Select selected={DecklistOptions.gradient(@user.decklist_options)} class="select" options={ "Gradient Color": "gradient_color", "Card Class": "card_class", "Deck Class": "deck_class", "Rarity": "rarity", "Dark Grey": "dark_grey"}/>
              <Label>Gradient Color</Label>
            </Field>
            <Field name="show_one">
              <Checkbox value={DecklistOptions.show_one(@user.decklist_options)} />
              <Label>Show 1 for singleton cards</Label>
            </Field>
            <Field name="show_one_for_legendaries">
              <Checkbox value={DecklistOptions.show_one_for_legendaries(@user.decklist_options)} />
              <Label>Show 1 for singleton legendaries</Label>
            </Field>
            <br>
            <Field name="replay_preference">
              <Select selected={@user.replay_preference} class="select" options={[{"All", :all}, {"Streamed", :streamed}, {"None", :none}]}/>
              <Label>Which replays do you want to be considered public? (only affects new replays)</Label>
            </Field>

            <Submit label="Save" class="button"/>
            <div :if={@user.twitch_id} >
              <button class="button" type="button" :on-click="disconnect_twitch">Disconnect Twitch {twitch_username(@user)}        </button>
            </div>
            <div :if={!@user.twitch_id} >
              <a class="button" href="/auth/twitch">Connect Twitch</a>
            </div>
          </Form>
        </div>
        <div :if={!@user}>Not Logged In</div>
      </div>
    </Context>
    """
  end

  def country_options() do
    Enum.map(Countriex.all(), fn %{name: name, alpha2: code} ->
      {name, code}
    end)
    |> Enum.sort_by(&elem(&1, 0), :asc)
  end

  def pride_flag() do
    <<0xF0, 0x9F, 0x8F, 0xB3, 0xEF, 0xB8, 0x8F, 0xE2, 0x80, 0x8D, 0xF0, 0x9F, 0x8C, 0x88>>
  end

  def peace_symbol() do
    <<0xE2, 0x98, 0xAE>>
  end

  def twitch_username(%{twitch_id: nil}), do: nil

  def twitch_username(%{twitch_id: twitch_id}) do
    case Streaming.streamer_by_twitch_id(twitch_id) do
      streamer = %{id: _} -> Streaming.Streamer.twitch_display(streamer)
      _ -> "Unknown twitch display???"
    end
  end

  def handle_event("disconnect_twitch", _, socket = %{assigns: %{user: user}}) do
    {:ok, updated} = UserManager.remove_twitch(user)
    {:noreply, socket |> assign(:user, updated)}
  end

  def handle_event("submit", %{"user" => attrs_raw}, socket = %{assigns: %{user: user}}) do
    attrs =
      attrs_raw
      |> parse_battlefy_slug()
      |> parse_decklist_options()

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

  def parse_decklist_options(attrs) do
    decklist_options =
      %{}
      |> parse_decklist_color_option(attrs, "gradient")
      |> parse_decklist_color_option(attrs, "border")
      |> parse_decklist_option(attrs, "show_one", DecklistOptions.show_one_default())
      |> parse_decklist_option(
        attrs,
        "show_one_for_legendaries",
        DecklistOptions.show_one_for_legendaries_default()
      )

    attrs |> Map.put("decklist_options", decklist_options)
  end

  def parse_decklist_option(attrs, params, key, default) do
    val = Map.get(params, key, default)
    Map.put(attrs, key, val)
  end

  def parse_decklist_color_option(attrs, params, key) do
    if params[key] && DecklistOptions.valid_color?(params[key]) do
      attrs |> Map.put(key, params[key])
    else
      attrs
    end
  end
end
