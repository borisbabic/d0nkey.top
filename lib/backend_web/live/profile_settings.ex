defmodule BackendWeb.ProfileSettingsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Streaming
  alias Backend.UserManager
  alias Backend.CollectionManager.Collection
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
    {:ok, assign_defaults(socket, session) |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Profile Settings</div>
        <FunctionComponents.Ads.below_title/>
        <div :if={@user}>
          <Form for={%{}} as={:user} submit="submit">
            <Field name="country_code">
              <Label class="label" >Country Flag</Label>
              <Select class="select has-text-black " options={[{"Select Country", nil} | country_options()]} selected={@user.country_code} />
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
              <Select selected={@user.unicode_icon} class="select has-text-black " options={[{"None/Custom", nil}, {pride_flag(), pride_flag()}, {peace_symbol(), peace_symbol()}]}/>
              For custom icons see <a href="/patreon">patreon</a>
            </Field>
            <br>
            <Label class="label">Collection</Label>
            <Field name="current_collection_id">
              <Select selected={@user.current_collection_id} class="select has-text-black " options={collection_options(@user)}/>
              <Label>Current Collection</Label>
            </Field>
            <Label class="label">Decklist Options</Label>
            <Field name="border">
              <Select selected={DecklistOptions.border(@user.decklist_options)} class="select has-text-black " options={"Border Color": "border_color", "Card Class": "card_class", "Deck Class": "deck_class", "Rarity": "rarity", "Dark Grey": "dark_grey", "Deck Format": "deck_format"}/>
              <Label>Border Color</Label>
            </Field>
            <Field name="gradient">
              <Select selected={DecklistOptions.gradient(@user.decklist_options)} class="select has-text-black " options={ "Gradient Color": "gradient_color", "Card Class": "card_class", "Deck Class": "deck_class", "Rarity": "rarity", "Dark Grey": "dark_grey", "Deck Format": "deck_format"}/>
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
            <Field name="show_dust_above">
              <Checkbox value={DecklistOptions.show_dust_above(@user.decklist_options)} />
              <Label>Show dust above cards</Label>
            </Field>
            <Field name="show_dust_below">
              <Checkbox value={DecklistOptions.show_dust_below(@user.decklist_options)} />
              <Label>Show dust below cards</Label>
            </Field>
            <Field name="use_missing_dust">
              <Checkbox value={DecklistOptions.use_missing_dust(@user.decklist_options)} />
              <Label>Use missing dust instead of total</Label>
            </Field>
            <Field name="fade_missing_cards">
              <Checkbox value={DecklistOptions.fade_missing_cards(@user.decklist_options)} />
              <Label>Fade missing cards in decks</Label>
            </Field>
            <br>
            <Field name="replay_preference">
              <Select selected={@user.replay_preference} class="select has-text-black " options={[{"All", :all}, {"Streamed", :streamed}, {"None", :none}]}/>
              <Label>Which replays do you want to be considered public? (only affects new replays)</Label>
            </Field>
            <br>
            <Field name="battlefy_slug">
              <Label class="label" >Battlefy Slug. Open your battlefy profile then paste the url and I'll extract it</Label>
              <TextInput class="input has-text-black  is-small" value={@user.battlefy_slug}/>
            </Field>

            <Submit label="Save" class="button"/>
            <div :if={@user.twitch_id} >
              <button class="button" type="button" :on-click="disconnect_twitch">Disconnect Twitch {twitch_username(@user)}        </button>
            </div>
            <div :if={!@user.twitch_id} >
              <a class="button" href="/auth/twitch">Connect Twitch</a>
            </div>
            <div :if={@user.patreon_id} class="level level-left">
              <button class="button " type="button" :on-click="disconnect_patreon">Disconnect Patreon </button>
              <div :if={tier_info = patreon_tier_info(@user)}>
                Tier: {tier_info.title} | Ad Free: {if tier_info.ad_free, do: "Yes", else: "No"}
              </div>
              <div :if={!@user.patreon_tier_id}>
                Tier: ? | Ad Free: ? || If you're already supporting this should get updated soon. If not you can support the site at <Components.Socials.patreon link={~p"/patreon"} />
              </div>
            </div>
            <div :if={!@user.patreon_id} class="level level-left">
              <a class="button" href="/auth/patreon">Connect Patreon</a>
              <div> Tier: ? | Ad Free: ?</div>
            </div>
          </Form>
        </div>
        <div :if={!@user}>Not Logged In</div>
      </div>
    """
  end

  def patreon_tier_info(%{patreon_tier: %{title: title, ad_free: ad_free}}),
    do: %{title: title, ad_free: ad_free}

  def patreon_tier_info(_), do: nil

  defp collection_options(user) do
    collection_options =
      Backend.CollectionManager.choosable_by_user(user)
      |> Enum.map(&{Collection.display(&1), &1.id})

    [{"None", nil} | collection_options]
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
    Streaming.twitch_id_to_display(twitch_id)
  end

  def handle_event("disconnect_twitch", _, socket = %{assigns: %{user: user}}) do
    {:ok, updated} = UserManager.remove_twitch(user)
    {:noreply, socket |> assign(:user, updated)}
  end

  def handle_event("disconnect_patreon", _, socket = %{assigns: %{user: user}}) do
    {:ok, updated} = UserManager.remove_patreon(user)
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
        "fade_missing_cards",
        DecklistOptions.default_fade_missing_cards()
      )
      |> parse_decklist_option(
        attrs,
        "use_missing_dust",
        DecklistOptions.default_use_missing_dust()
      )
      |> parse_decklist_option(
        attrs,
        "show_dust_above",
        DecklistOptions.default_show_dust_above()
      )
      |> parse_decklist_option(
        attrs,
        "show_dust_below",
        DecklistOptions.default_show_dust_below()
      )
      |> parse_decklist_option(
        attrs,
        "show_one_for_legendaries",
        DecklistOptions.show_one_for_legendaries_default()
      )

    attrs |> Map.put("decklist_options", decklist_options)
  end

  def parse_decklist_option(attrs, params, key, default) do
    val = Map.get(params, key, default) |> to_bool()
    Map.put(attrs, key, val)
  end

  defp to_bool("true"), do: true
  defp to_bool("false"), do: false
  defp to_bool(val), do: val

  def parse_decklist_color_option(attrs, params, key) do
    if params[key] && DecklistOptions.valid_color?(params[key]) do
      attrs |> Map.put(key, params[key])
    else
      attrs
    end
  end
end
