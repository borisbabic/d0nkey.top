defmodule BackendWeb.ProfileSettingsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Streaming
  alias Backend.UserManager
  alias Backend.CollectionManager.Collection
  alias Backend.UserManager.User.DecklistOptions

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
          <.form for={%{}} as={:user} id="profile_settings_form" phx-submit="submit">
            <div>
              <label for="country_code" class="label">Country Flag</label>
              <select name="country_code" class="select has-text-black">
              {options_for_select([{"Select Country", nil} | country_options()], @user.country_code)}
              </select>
            </div>
            <div>
              <label for="cross_out_country" class="label">Cross Out Country</label>
              <input type="checkbox" name="cross_out_country" checked={@user.cross_out_country} />
            </div>
            <div>
              <label for="show_region" class="label">Show Region Instead of Country</label>
              <input type="checkbox" name="show_region" checked={@user.show_region} />
            </div>
            <br>
            <div>
              <label for="unicode_icon" class="label">Player Icon</label>
              <select name="unicode_icon" class="select has-text-black">
                {options_for_select([{"None/Custom", nil}, {pride_flag(), pride_flag()}, {peace_symbol(), peace_symbol()}], @user.unicode_icon)}
              </select>
              For custom icons see <a href="/patreon">patreon</a>
            </div>
            <br>
            <label class="label">Deck Sheets</label>
            <div>
              <select name="default_sheet_id" class="select has-text-black" value={@user.default_sheet_id}>
                {options_for_select(Components.DeckListingModal.sheet_options(@user), @user.default_sheet_id)}
              </select>
              <label for="default_sheet_id">Default Sheet</label>
            </div>
            <div>
              <input type="search" name="default_sheet_source" class="has-text-black" value={@user.default_sheet_source}/>
              <label for="default_sheet_source">Default Source</label>
            </div>
            <label class="label">Collection</label>
            <div>
              <select name="current_collection_id" class="select has-text-black" value={@user.current_collection_id}>
                {options_for_select(collection_options(@user), @user.current_collection_id)}
              </select>
              <label for="current_collection_id">Current Collection</label>
            </div>
            <label class="label">Decklist Options</label>
            <div>
              <select name="border" class="select has-text-black">
                {options_for_select(["Border Color": "border_color", "Card Class": "card_class", "Deck Class": "deck_class", "Rarity": "rarity", "Dark Grey": "dark_grey", "Deck Format": "deck_format"], DecklistOptions.border(@user.decklist_options))}
              </select>>
              <label for="border">Border Color</label>
            </div>
            <div>
              <select name="gradient" class="select has-text-black">
               {options_for_select(["Gradient Color": "gradient_color", "Card Class": "card_class", "Deck Class": "deck_class", "Rarity": "rarity", "Dark Grey": "dark_grey", "Deck Format": "deck_format"], DecklistOptions.gradient(@user.decklist_options))}
              </select>>
              <label for="gradient">Gradient Color</label>
            </div>
            <div>
              <.input type="checkbox" name="show_one" checked={DecklistOptions.show_one(@user.decklist_options)} label="Show 1 for singleton cards"/>
            </div>
            <div>
              <.input type="checkbox" name="show_one_for_legendaries" checked={DecklistOptions.show_one_for_legendaries(@user.decklist_options)} label="Show 1 for singleton legendaries"/>
            </div>
            <div>
              <.input type="checkbox" name="show_dust_above" checked={DecklistOptions.show_dust_above(@user.decklist_options)} label="Show dust above cards"/>
            </div>
            <div>
              <.input type="checkbox" name="show_dust_below" checked={DecklistOptions.show_dust_below(@user.decklist_options)} label="Show dust below cards"/>
            </div>
            <div>
              <.input type="checkbox" name="use_missing_dust" checked={DecklistOptions.use_missing_dust(@user.decklist_options)} label="Use missing dust instead of total"/>
            </div>
            <div>
              <.input type="checkbox" name="fade_missing_cards" checked={DecklistOptions.use_missing_dust(@user.decklist_options)} label="Fade missing cards in decks"/>
            </div>
            <br>
            <div>
              <select name="replay_preference" class="select has-text-black" value={@user.replay_preference}>
                {options_for_select([{"All", :all}, {"Streamed", :streamed}, {"None", :none}], @user.replay_preference)}
              </select>
              <label for="replay_preference">Which replays do you want to be considered public? (only affects new replays)</label>
            </div>
            <br>
            <div>
              <label for="battlefy_slug" class="label">Battlefy Slug. Open your battlefy profile then paste the url and I'll extract it</label>
              <input name="battlefy_slug" class="has-text-black is-small" value={@user.battlefy_slug}/>
            </div>
            <button type="submit" class="button">Save</button>
            <div :if={@user.twitch_id}>
              <button type="button" :on-click="disconnect_twitch" class="button">Disconnect Twitch {twitch_username(@user)}</button>
            </div>
            <div :if={!@user.twitch_id}>
              <a class="button" href="/auth/twitch">Connect Twitch</a>
            </div>
            <div :if={@user.patreon_id} class="level level-left">
              <button type="button" :on-click="disconnect_patreon" class="button">Disconnect Patreon</button>
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
          </.form>
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

  def handle_event("submit", attrs_raw, socket = %{assigns: %{user: user}}) do
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

  defp to_bool("on"), do: true
  defp to_bool("true"), do: true
  defp to_bool("false"), do: false
  defp to_bool(""), do: false
  defp to_bool(val), do: val

  def parse_decklist_color_option(attrs, params, key) do
    if params[key] && DecklistOptions.valid_color?(params[key]) do
      attrs |> Map.put(key, params[key])
    else
      attrs
    end
  end
end
