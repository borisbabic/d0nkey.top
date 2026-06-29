defmodule BackendWeb.ProfileSettingsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Streaming
  alias Backend.UserManager
  alias Backend.UserManager.User
  alias Backend.CollectionManager.Collection
  alias Backend.UserManager.User.DecklistOptions

  data(user, :map)
  data(custom_hues, :boolean, default: false)

  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session) |> put_user_in_context() |> assign_custom_hues()}
  end

  def render(assigns) do
    ~F"""
    <div class="tw-max-w-4xl tw-mx-auto tw-p-6 tw-space-y-8 tw-font-sans tw-text-slate-300">
      
      <!-- Title Area -->
      <header class="tw-border-b tw-border-slate-800 tw-pb-4">
        <div class="title is-2 text-white">Profile & Settings</div>
      </header>
      
      <FunctionComponents.Ads.below_title/>

      <div :if={@user}>
        <.form for={%{}} as={:user} id="profile_settings_form" phx-submit="submit" class="tw-space-y-6">
          
          <!-- Section: Country & Icon -->
          <div class="tw-p-6 has-background-dark tw-border tw-border-slate-800 tw-rounded-xl tw-space-y-4">
            <h3 class="tw-text-lg tw-font-bold text-white tw-border-b tw-border-slate-800 tw-pb-2">Country & Icon</h3>
            <div class="tw-space-y-3">
              <.input 
                options={[{"Select Country", nil} | country_options()]}
                type={"select"}
                label={"Country Flag"}
                name={"country_code"}
                value={@user.country_code} />
              <.input type="checkbox" label="Cross Out Country" name="cross_out_country" checked={@user.cross_out_country} />
              <.input type="checkbox" label="Show Region Instead of Country" name="show_region" checked={@user.show_region} />

              <.input
                type={"select"}
                label={"Player Icon"}
                name={"unicode_icon"}
                value={@user.unicode_icon}
                options={[{"None/Custom", nil}, {pride_flag(), pride_flag()}, {peace_symbol(), peace_symbol()}]}/>
              <span class="tw-text-xs tw-italic tw-text-slate-400 tw-block">
                For custom icons see <a href="/patreon" class="has-text-info tw-underline">patreon</a>
              </span>
            </div>
          </div>

          <!-- Section: Decklist Look & Colors -->
          <div class="tw-p-6 has-background-dark tw-border tw-border-slate-800 tw-rounded-xl tw-space-y-4">
            <h3 class="tw-text-lg tw-font-bold text-white tw-border-b tw-border-slate-800 tw-pb-2">Decklist Colors</h3>
            <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 tw-gap-4">
              <.input
                type="select"
                name="border"
                value={DecklistOptions.border(@user.decklist_options)}
                label="Border Color"
                options={["Border Color": "border_color", "Card Class": "card_class", "Deck Class": "deck_class", "Rarity": "rarity", "Dark Grey": "dark_grey", "Deck Format": "deck_format"]} />
              <.input
                type="select"
                name="gradient"
                value={DecklistOptions.gradient(@user.decklist_options)}
                label="Gradient Color"
                options={["Gradient Color": "gradient_color", "Card Class": "card_class", "Deck Class": "deck_class", "Rarity": "rarity", "Dark Grey": "dark_grey", "Deck Format": "deck_format"]} />
            </div>
          </div>

          <!-- Section: Decklist Options -->
          <div class="tw-p-6 has-background-dark tw-border tw-border-slate-800 tw-rounded-xl tw-space-y-4">
            <h3 class="tw-text-lg tw-font-bold text-white tw-border-b tw-border-slate-800 tw-pb-2">Decklist Options</h3>
            <div class="tw-space-y-3">
              <.input type="select" name="preferred_deckcode" value={DecklistOptions.preferred_deckcode(@user.decklist_options)} options={["Short Deckcode (Valid)": "short", "Long Deckcode (Valid)": "long", "Long Deckcode (Markdown)": "long_markdown_code"]} label="Preferred Deckcode When Copying"/>
              <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 tw-gap-2 tw-pt-2">
                <.input type="checkbox" name="show_one" checked={DecklistOptions.show_one(@user.decklist_options)} label="Show 1 for singleton cards"/>
                <.input type="checkbox" name="show_one_for_legendaries" checked={DecklistOptions.show_one_for_legendaries(@user.decklist_options)} label="Show 1 for singleton legendaries"/>
                <.input type="checkbox" name="show_dust_above" checked={DecklistOptions.show_dust_above(@user.decklist_options)} label="Show dust+action bar above cards"/>
                <.input type="checkbox" name="show_dust_below" checked={DecklistOptions.show_dust_below(@user.decklist_options)} label="Show dust+action bar below cards"/>
                <.input type="checkbox" name="use_missing_dust" checked={DecklistOptions.use_missing_dust(@user.decklist_options)} label="Use missing dust instead of total"/>
                <.input type="checkbox" name="fade_missing_cards" checked={DecklistOptions.fade_missing_cards(@user.decklist_options)} label="Fade missing cards in decks"/>
                <.input type="checkbox" name="fade_rotating_cards" checked={DecklistOptions.fade_rotating_cards(@user.decklist_options)} label="Fade rotating cards in decks"/>
              </div>
            </div>
          </div>

          <!-- Section: Deck Sheets -->
          <div class="tw-p-6 has-background-dark tw-border tw-border-slate-800 tw-rounded-xl tw-space-y-4">
            <h3 class="tw-text-lg tw-font-bold text-white tw-border-b tw-border-slate-800 tw-pb-2">Deck Sheets</h3>
            <div class="tw-space-y-3">
              <.input
                value={@user.default_sheet_id}
                name="default_sheet_id"
                type="select"
                label="Default Sheet"
                options={Components.DeckListingModal.sheet_options(@user)}
                />
              <.input type="search" label="Default Source" name="default_sheet_source" value={@user.default_sheet_source} />
            </div>
          </div>

          <!-- Section: Winrate & Impact Colors -->
          <div class="tw-p-6 has-background-dark tw-border tw-border-slate-800 tw-rounded-xl tw-space-y-4">
            <h3 class="tw-text-lg tw-font-bold text-white tw-border-b tw-border-slate-800 tw-pb-2">Winrate/Impact Colors</h3>
            <div class="tw-space-y-4">
              <div :if={@custom_hues} class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 tw-gap-4">
                <.input label="Positive Hue" name="positive_hue" value={@user.positive_hue} type="number" min={0} max={360} step={1}/>
                <.input label="Negative Hue" name="negative_hue" value={@user.negative_hue} type="number" min={0} max={360} step={1}/>
              </div>
              <div :if={!@custom_hues} class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 tw-gap-4">
                <.input
                  type="select"
                  name="positive_hue"
                  label="Positive Color"
                  options={hue_options()}
                  value={@user.positive_hue}/>
                <.input
                  type="select"
                  label="Negative Color"
                  name="negative_hue"
                  options={hue_options()}
                  value={@user.negative_hue} />
              </div>
              <div :on-click="toggle_custom_hues" class="tw-pt-2">
                <.input label="Use Custom Hues" type="checkbox" name="custom_hues" value={@custom_hues} checked={@custom_hues} />
              </div>
            </div>
          </div>

          <!-- Section: Connections -->
          <div class="tw-p-6 has-background-dark tw-border tw-border-slate-800 tw-rounded-xl tw-space-y-4">
            <h3 class="tw-text-lg tw-font-bold text-white tw-border-b tw-border-slate-800 tw-pb-2">
              Connections ({Enum.count([@user.twitch_id, @user.patreon_id], & &1)}/2)
            </h3>
            <div class="tw-space-y-4">
              <!-- Twitch Connection -->
              <div class="tw-flex tw-items-center tw-justify-between tw-bg-black/20 tw-p-3 tw-rounded-lg">
                <div>
                  <span class="tw-font-bold text-white tw-block tw-text-sm">Twitch Integration</span>
                  <span class="tw-text-xs tw-text-slate-400">Stream tracks automatically when connected.</span>
                </div>
                <div :if={@user.twitch_id}>
                  <button type="button" :on-click="disconnect_twitch" class="button is-small is-danger is-outlined">Disconnect {twitch_username(@user)}</button>
                </div>
                <div :if={!@user.twitch_id}>
                  <a class="button is-small is-link" href="/auth/twitch">Connect Twitch</a>
                </div>
              </div>

              <!-- Patreon Connection -->
              <div class="tw-bg-black/20 tw-p-3 tw-rounded-lg tw-space-y-2">
                <div class="tw-flex tw-items-center tw-justify-between">
                  <div>
                    <span class="tw-font-bold text-white tw-block tw-text-sm">Patreon Integration</span>
                    <span class="tw-text-xs tw-text-slate-400">Link your account to unlock perks.</span>
                  </div>
                  <div :if={@user.patreon_id}>
                    <button type="button" :on-click="disconnect_patreon" class="button is-small is-danger is-outlined">Disconnect Patreon</button>
                  </div>
                  <div :if={!@user.patreon_id}>
                    <a class="button is-small is-link" href="/auth/patreon">Connect Patreon</a>
                  </div>
                </div>

                <!-- Patreon Status Info -->
                <div class="tw-text-xs tw-text-slate-400 tw-pt-2 tw-border-t tw-border-slate-800/60">
                  <div :if={tier_info = patreon_tier_info(@user)}>
                    Tier: <strong class="text-white">{tier_info.title}</strong> | Ad Free: <strong class="text-white">{if tier_info.ad_free, do: "Yes", else: "No"}</strong>
                  </div>
                  <div :if={@user.patreon_id && !@user.patreon_tier_id}>
                    Tier: ? | Ad Free: ? <span class="tw-block tw-mt-1 tw-italic">If you're already supporting, this should update soon. If not, you can support the site at <Components.Socials.patreon link={~p"/patreon"} /></span>
                  </div>
                  <div :if={!@user.patreon_id}>
                    Tier: ? | Ad Free: ?
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Section: Misc -->
          <div class="tw-p-6 has-background-dark tw-border tw-border-slate-800 tw-rounded-xl tw-space-y-4">
            <h3 class="tw-text-lg tw-font-bold text-white tw-border-b tw-border-slate-800 tw-pb-2">Misc Settings</h3>
            <div class="tw-space-y-3">
              <.input type="select" name="current_collection_id" value={@user.current_collection_id} options={collection_options(@user)} label="Current Collection"  />
              <.input type="select" label="Which replays do you want to be public? (Only affects new replays)" value={@user.replay_preference} options={[{"All", :all}, {"Streamed", :streamed}, {"None", :none}]} name="replay_preference" />
              <.input label="Battlefy Slug (Open your profile, paste the URL, and I'll grab it)" name="battlefy_slug"  value={@user.battlefy_slug}/>
            </div>
          </div>

          <!-- Sticky or bottom Save Action Bar -->
          <div class="tw-pt-4 tw-flex tw-justify-end">
            <button type="submit" class="button is-link is-medium tw-px-8 tw-font-bold">Save Settings</button>
          </div>

        </.form>
      </div>

      <!-- Logged Out View -->
      <div :if={!@user} class="tw-p-6 tw-text-center tw-bg-slate-800/20 tw-border tw-border-slate-800 tw-rounded-xl">
        <p class="tw-text-slate-400">Not Logged In. You need to <a href={~p"/auth/bnet"} class="has-text-info tw-underline">log in</a> to change your settings.</p>
      </div>

    </div>
    """
  end

  def patreon_tier_info(%{patreon_tier: %{title: title, ad_free: ad_free}}),
    do: %{title: title, ad_free: ad_free}

  def patreon_tier_info(_), do: nil

  defp hue_options do
    [
      {"Default", nil},
      {"Blue", 220},
      {"Green", 120},
      {"Red", 0}
    ]
  end

  defp collection_options(user) do
    collection_options =
      Backend.CollectionManager.choosable_by_user(user)
      |> Enum.map(&{Collection.display(&1), &1.id})

    [{"None", nil} | collection_options]
  end

  def country_options do
    Enum.map(Countriex.all(), fn %{name: name, alpha2: code} ->
      {name, code}
    end)
    |> Enum.sort_by(&elem(&1, 0), :asc)
  end

  def pride_flag do
    <<0xF0, 0x9F, 0x8F, 0xB3, 0xEF, 0xB8, 0x8F, 0xE2, 0x80, 0x8D, 0xF0, 0x9F, 0x8C, 0x88>>
  end

  def peace_symbol do
    <<0xE2, 0x98, 0xAE>>
  end

  def twitch_username(%{twitch_id: nil}), do: nil

  def twitch_username(%{twitch_id: twitch_id}) do
    Streaming.twitch_id_to_display(twitch_id)
  end

  def handle_event(
        "toggle_custom_hues",
        _,
        %{assigns: %{custom_hues: custom_hues}} = socket
      ) do
    {:noreply, socket |> assign(:custom_hues, !custom_hues)}
  end

  def handle_event("disconnect_twitch", _, %{assigns: %{user: user}} = socket) do
    {:ok, updated} = UserManager.remove_twitch(user)
    {:noreply, socket |> assign(:user, updated)}
  end

  def handle_event("disconnect_patreon", _, %{assigns: %{user: user}} = socket) do
    {:ok, updated} = UserManager.remove_patreon(user)
    {:noreply, socket |> assign(:user, updated)}
  end

  def handle_event("submit", attrs_raw, %{assigns: %{user: user}} = socket) do
    attrs =
      attrs_raw
      |> parse_battlefy_slug()
      |> parse_decklist_options()
      |> parse_int(["positive_hue", "negative_hue"])

    updated =
      user
      |> UserManager.update_user(attrs)
      |> case do
        {:ok, u} -> u
        _ -> user
      end

    {:noreply, socket |> assign(:user, updated)}
  end

  def assign_custom_hues(%{assigns: %{user: user}} = socket) do
    values = hue_options() |> Enum.map(&elem(&1, 1))
    positive = User.positive_hue(user, nil)
    negative = User.negative_hue(user, nil)
    custom_hues = !(positive in values) or !(negative in values)
    assign(socket, custom_hues: custom_hues)
  end

  defp parse_int(attrs, keys) do
    Enum.reduce(keys, attrs, fn key, acc ->
      Map.update(acc, key, nil, &Util.to_int_or_orig/1)
    end)
  end

  def parse_battlefy_slug(%{"battlefy_slug" => <<"https://battlefy.com/users/"::binary, slug::binary>>} = attrs),
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
        "preferred_deckcode",
        DecklistOptions.default_preferred_deckcode()
      )
      |> parse_decklist_option(
        attrs,
        "fade_rotating_cards",
        DecklistOptions.default_fade_rotating_cards()
      )
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
