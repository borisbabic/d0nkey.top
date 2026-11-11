defmodule BackendWeb.CreatorSettingsLive do
  @moduledoc "Setup page for a content creator's public page"
  use BackendWeb, :surface_live_view
  alias Backend.Creators
  alias Backend.Creators.CreatorProfile
  alias Backend.UserManager

  data(user, :any)
  data(profile, :any)
  data(form, :any)
  data(youtube_channels, :list, default: [])
  data(twitch_login, :string, default: nil)
  data(recent_videos, :any)
  data(errors, :map, default: %{})

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()
     |> assign(page_title: "Creator Page Setup")
     |> assign_profile_data()}
  end

  defp assign_profile_data(%{assigns: %{user: %{id: _} = user}} = socket) do
    youtube_channels = UserManager.youtube_channels(user)
    channel_ids = Enum.map(youtube_channels, & &1.channel_id)

    socket
    |> assign(youtube_channels: youtube_channels, twitch_login: Creators.twitch_login(user))
    |> assign_profile(Creators.get_or_new_profile(user))
    |> assign_async(:recent_videos, fn -> {:ok, %{recent_videos: Creators.recent_videos(channel_ids)}} end)
  end

  defp assign_profile_data(socket), do: assign(socket, profile: nil)

  defp assign_profile(socket, profile) do
    assign(socket, profile: profile, form: to_form(CreatorProfile.settings_changeset(profile, %{})))
  end

  def render(assigns) do
    ~F"""
    <div class="tw-max-w-4xl tw-mx-auto tw-p-6 tw-space-y-8 tw-text-slate-300">
      <.page_header title="Creator Page"/>

      <div :if={!@user} id="creator-settings-logged-out" class="tw-p-6 tw-text-center tw-bg-slate-800/20 tw-border tw-border-slate-800 tw-rounded-xl">
        <p class="tw-text-slate-400">You need to <a href={~p"/auth/bnet"} class="has-text-info tw-underline">log in</a> to set up your creator page.</p>
      </div>

      <div :if={@profile} class="tw-space-y-6">
        {render_status(assigns)}
        {render_short_url(assigns)}
        <.form for={@form} id="creator-settings-form" phx-change="save" phx-submit="save" class="tw-space-y-6">
          {render_about(assigns)}
          {render_stream_and_profile(assigns)}
          {render_deck_settings(assigns)}
          {render_video_settings(assigns)}
        </.form>
        {render_deck_pin(assigns)}
        {render_video_pin(assigns)}
      </div>
    </div>
    """
  end

  defp section(assigns) do
    ~F"""
    <section id={@id} class="tw-p-6 has-background-dark tw-border tw-border-slate-800 tw-rounded-xl tw-space-y-4">
      <div class="tw-border-b tw-border-slate-800 tw-pb-2">
        <h3 class="tw-text-lg tw-font-bold text-white">{@title}</h3>
        <p :if={@subtitle} class="tw-text-xs tw-text-slate-400 tw-mt-0.5">{@subtitle}</p>
      </div>
      {render_slot(@inner_block)}
    </section>
    """
  end

  defp render_status(assigns) do
    ~F"""
    <.section id="creator-status" title="Your Page" subtitle="Turn it on when you're happy with how it looks. You can always preview it.">
      <div class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-gap-4">
        <div class="tw-flex tw-items-center tw-gap-3">
          <span class={[
            "tw-inline-flex tw-items-center tw-gap-1.5 tw-px-2.5 tw-py-1 tw-rounded-full tw-text-xs tw-font-semibold tw-border",
            if(@profile.enabled, do: "tw-bg-emerald-500/15 tw-text-emerald-300 tw-border-emerald-500/40", else: "tw-bg-slate-700/40 tw-text-slate-300 tw-border-slate-600")
          ]}>
            <span class={["tw-w-1.5 tw-h-1.5 tw-rounded-full", if(@profile.enabled, do: "tw-bg-emerald-400", else: "tw-bg-slate-400")]}></span>
            {if @profile.enabled, do: "Public", else: "Hidden"}
          </span>
          <button type="button" id="toggle-creator-enabled" :on-click="toggle_enabled" class={["button is-small", if(@profile.enabled, do: "is-danger is-outlined", else: "is-success")]}>
            {if @profile.enabled, do: "Hide page", else: "Make public"}
          </button>
        </div>
        <a :if={page_path(@profile)} id="view-creator-page" href={page_path(@profile)} class="button is-small is-link is-outlined">
          {if @profile.enabled, do: "View page", else: "Preview page"} →
        </a>
      </div>

      <div id="creator-urls" class="tw-space-y-1.5 tw-text-sm">
        <span class="tw-block tw-text-xs tw-uppercase tw-tracking-wider tw-text-slate-500">Your urls</span>
        <code :for={url <- page_urls(@profile, @twitch_login, @youtube_channels)} class="tw-block tw-text-slate-200 tw-bg-black/30 tw-rounded tw-px-2 tw-py-1 tw-w-fit">{url}</code>
        <p :if={Enum.empty?(page_urls(@profile, @twitch_login, @youtube_channels))} class="tw-text-amber-300 tw-text-sm">
          You don't have a url yet. <a href={~p"/profile/settings"} class="tw-underline">Connect Twitch or YouTube</a> or request a short url below.
        </p>
      </div>
    </.section>
    """
  end

  defp render_short_url(assigns) do
    ~F"""
    <.section id="creator-short-url" title="Short URL" subtitle="Request a short url like /creator/yourname. Short urls are reviewed by an admin. Ones exactly matching your connected Twitch login or YouTube handle are live right away.">
      <div :if={@profile.slug} id="creator-slug-status" class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-gap-3 tw-bg-black/20 tw-p-3 tw-rounded-lg">
        <div class="tw-flex tw-items-center tw-gap-3 tw-min-w-0">
          <code class="tw-text-slate-200 tw-truncate">/creator/{@profile.slug}</code>
          <span class={["tw-px-2 tw-py-0.5 tw-rounded-full tw-text-xs tw-font-semibold tw-border", slug_status_class(@profile.slug_status)]}>
            {slug_status_label(@profile.slug_status)}
          </span>
        </div>
        <button type="button" id="cancel-slug" :on-click="cancel_slug" class="button is-small is-danger is-outlined">
          {if @profile.slug_status == :rejected, do: "Clear", else: "Remove"}
        </button>
      </div>
      <.form :if={@profile.slug in [nil] or @profile.slug_status == :rejected} for={%{}} as={:slug} id="creator-slug-form" phx-submit="request_slug" class="tw-flex tw-flex-wrap tw-items-end tw-gap-3">
        <div class="tw-flex-1 tw-min-w-[200px]">
          <.input name="slug" id="creator-slug-input" value="" label="Short url" placeholder={@twitch_login || "yourname"} maxlength="30" errors={List.wrap(@errors[:slug])}/>
        </div>
        <button type="submit" class="button is-link tw-mb-4">Request</button>
      </.form>
    </.section>
    """
  end

  defp render_about(assigns) do
    ~F"""
    <.section id="creator-about" title="About & Links" subtitle="Everything here is optional.">
      <.input field={@form[:bio]} type="textarea" label={"Bio (max #{CreatorProfile.max_bio_length()} characters)"} maxlength={CreatorProfile.max_bio_length()} phx-debounce="600" placeholder="Legend climber, wild enjoyer, ..."/>
      <.input
        type="textarea"
        id="creator-links-input"
        name="creator_profile[links_text]"
        value={Enum.join(links_value(@form), "\n")}
        label={"Social links, one per line (max #{CreatorProfile.max_links()})"}
        placeholder={"https://x.com/you\nhttps://discord.gg/yourserver\nhttps://patreon.com/you"}
        phx-debounce="blur"
        errors={Enum.map(@form[:links].errors, &FunctionComponents.CoreComponents.translate_error/1)}/>
      <p class="tw-text-xs tw-text-slate-500 -tw-mt-2">Connected Twitch and YouTube channels are added automatically. Known sites (X, Bluesky, Discord, Patreon, TikTok, Kick, ...) get their own icons.</p>
    </.section>
    """
  end

  defp render_stream_and_profile(assigns) do
    ~F"""
    <.section id="creator-stream" title="Stream & Profile" subtitle={nil}>
      <.toggle field={@form[:show_stream]} id="creator-show-stream" label="Show a live badge linking to my stream when I'm live"/>
      <p :if={!@twitch_login && Enum.empty?(@youtube_channels)} class="tw-text-xs tw-text-amber-300 -tw-mt-2">
        <a href={~p"/profile/settings"} class="tw-underline">Connect Twitch or YouTube</a> for live detection.
      </p>
      <.toggle field={@form[:show_player_profile]} id="creator-show-player-profile" label="Link to my player profile"/>
      <p class="tw-text-xs tw-text-slate-500 -tw-mt-2">
        This will reveal your battletag
      </p>
    </.section>
    """
  end

  defp render_deck_settings(assigns) do
    ~F"""
    <.section id="creator-decks" title="Decks" subtitle="A pinned deck (below) is shown instead of the latest one.">
      <.input
        field={@form[:deck_source]}
        type="select"
        label="Featured deck"
        options={[{"Latest deck played on stream", :streamer}, {"Latest public deck (from your public replays)", :public}, {"Don't show decks", :none}]}/>
      <.toggle :if={Phoenix.HTML.Form.input_value(@form, :deck_source) not in [:none, "none"]} field={@form[:show_recent_decks]} id="creator-show-recent-decks" label="Also show a strip of recent decks (can reveal your battletag if using public decks)"/>
    </.section>
    """
  end

  defp render_video_settings(assigns) do
    ~F"""
    <.section id="creator-video" title="YouTube Video" subtitle={nil}>
      <p :if={Enum.empty?(@youtube_channels)} class="tw-text-sm tw-text-amber-300">
        <a href={~p"/profile/settings"} class="tw-underline">Connect your YouTube channel</a> to show videos.
      </p>
      <div :if={Enum.any?(@youtube_channels)} class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 tw-gap-4">
        <.input
          field={@form[:video_mode]}
          type="select"
          label="Video to show"
          options={[{"My latest upload", :latest}, {"A pinned video", :pinned}, {"Don't show a video", :none}]}/>
        <.input
          :if={Enum.count(@youtube_channels) > 1}
          field={@form[:youtube_channel_id]}
          type="select"
          label="Channel for the latest upload"
          options={Enum.map(@youtube_channels, &{&1.title || &1.handle || &1.channel_id, &1.channel_id})}/>
      </div>
    </.section>
    """
  end

  defp render_deck_pin(assigns) do
    ~F"""
    <.section id="creator-deck-pin" title="Pinned Deck" subtitle="Paste a deckcode to always feature that deck.">
      <div :if={@profile.pinned_deck} id="creator-pinned-deck" class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-gap-3 tw-bg-black/20 tw-p-3 tw-rounded-lg">
        <a href={~p"/deck/#{@profile.pinned_deck.id}"} class="tw-text-white hover:tw-underline">{Backend.Hearthstone.Deck.name(@profile.pinned_deck)}</a>
        <button type="button" id="unpin-deck" :on-click="unpin_deck" class="button is-small is-danger is-outlined">Unpin</button>
      </div>
      <.form for={%{}} as={:deck} id="creator-pin-deck-form" phx-submit="pin_deck" class="tw-flex tw-flex-wrap tw-items-end tw-gap-3">
        <div class="tw-flex-1 tw-min-w-[200px]">
          <.input name="deckcode" id="creator-deckcode-input" value="" label="Deckcode" placeholder="AAECAf0E..." errors={List.wrap(@errors[:deck])}/>
        </div>
        <button type="submit" class="button is-link tw-mb-4">{if @profile.pinned_deck, do: "Replace", else: "Pin"}</button>
      </.form>
    </.section>
    """
  end

  defp render_video_pin(assigns) do
    ~F"""
    <.section :if={Enum.any?(@youtube_channels)} id="creator-video-pin" title="Pinned Video" subtitle="Pick one of your recent uploads or paste a link to any video from your channels.">
      <div :if={@profile.pinned_video_id} id="creator-pinned-video" class="tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-gap-3 tw-bg-black/20 tw-p-3 tw-rounded-lg">
        <a href={"https://www.youtube.com/watch?v=#{@profile.pinned_video_id}"} target="_blank" rel="noopener noreferrer" class="tw-flex tw-items-center tw-gap-3 tw-text-white hover:tw-underline">
          <img src={"https://i.ytimg.com/vi/#{@profile.pinned_video_id}/mqdefault.jpg"} alt="" class="tw-w-24 tw-rounded"/>
          <span>Pinned video{if @profile.video_mode != :pinned, do: " (not shown, switch \"Video to show\" to pinned)"}</span>
        </a>
        <button type="button" id="unpin-video" :on-click="unpin_video" class="button is-small is-danger is-outlined">Unpin</button>
      </div>

      <.form for={%{}} as={:video} id="creator-pin-video-form" phx-submit="pin_video" class="tw-flex tw-flex-wrap tw-items-end tw-gap-3">
        <div class="tw-flex-1 tw-min-w-[200px]">
          <.input name="video" id="creator-video-input" value="" label="Video link" placeholder="https://www.youtube.com/watch?v=..." errors={List.wrap(@errors[:video])}/>
        </div>
        <button type="submit" class="button is-link tw-mb-4">Pin</button>
      </.form>

      <div id="creator-recent-videos" class="tw-space-y-2">
        <span class="tw-block tw-text-xs tw-uppercase tw-tracking-wider tw-text-slate-500">Recent uploads</span>
        <div :if={@recent_videos.loading} class="tw-grid tw-grid-cols-2 md:tw-grid-cols-4 tw-gap-3">
          <div :for={_ <- 1..4} class="tw-aspect-video tw-rounded-lg tw-bg-slate-800/50 tw-animate-pulse"></div>
        </div>
        <p :if={@recent_videos.ok? && Enum.empty?(@recent_videos.result)} class="tw-text-sm tw-text-slate-500">No recent uploads found.</p>
        <div :if={@recent_videos.ok?} class="tw-grid tw-grid-cols-2 md:tw-grid-cols-4 tw-gap-3">
          <button
            :for={video <- @recent_videos.result}
            type="button"
            id={"pin-recent-video-#{video.id}"}
            :on-click="pin_video"
            phx-value-video={video.id}
            title={"Pin \"#{video.title}\""}
            class={[
              "tw-group tw-text-left tw-rounded-lg tw-overflow-hidden tw-border tw-bg-black/20 tw-transition-all hover:tw-border-sky-500/60 hover:-tw-translate-y-0.5 focus:tw-outline-none focus-visible:tw-ring-2 focus-visible:tw-ring-sky-500",
              if(video.id == @profile.pinned_video_id, do: "tw-border-sky-500", else: "tw-border-slate-800")
            ]}>
            <img src={"https://i.ytimg.com/vi/#{video.id}/mqdefault.jpg"} alt="" loading="lazy" class="tw-w-full tw-aspect-video tw-object-cover"/>
            <span class="tw-block tw-p-2 tw-text-xs tw-text-slate-300 group-hover:tw-text-white tw-line-clamp-2">{video.title}</span>
          </button>
        </div>
      </div>
    </.section>
    """
  end

  # ---------------------------------------------------------------------------
  # Events
  # ---------------------------------------------------------------------------

  def handle_event("save", %{"creator_profile" => params}, %{assigns: %{user: user}} = socket) do
    attrs = parse_links(params)

    case Creators.update_settings(user, attrs) do
      {:ok, profile} -> {:noreply, assign_profile(socket, profile)}
      {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  def handle_event("toggle_enabled", _, %{assigns: %{user: user, profile: profile}} = socket) do
    user
    |> Creators.update_settings(%{enabled: !profile.enabled})
    |> handle_result(socket, nil)
  end

  def handle_event("request_slug", %{"slug" => slug}, %{assigns: %{user: user}} = socket) do
    user |> Creators.request_slug(slug) |> handle_result(socket, :slug)
  end

  def handle_event("cancel_slug", _, %{assigns: %{user: user}} = socket) do
    user |> Creators.cancel_slug() |> handle_result(socket, :slug)
  end

  def handle_event("pin_deck", %{"deckcode" => code}, %{assigns: %{user: user}} = socket) do
    user |> Creators.pin_deck(code) |> handle_result(socket, :deck)
  end

  def handle_event("unpin_deck", _, %{assigns: %{user: user}} = socket) do
    user |> Creators.unpin_deck() |> handle_result(socket, :deck)
  end

  def handle_event("pin_video", %{"video" => video}, %{assigns: %{user: user}} = socket) do
    user |> Creators.pin_video(video) |> handle_result(socket, :video)
  end

  def handle_event("unpin_video", _, %{assigns: %{user: user}} = socket) do
    user |> Creators.unpin_video() |> handle_result(socket, :video)
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  defp handle_result({:ok, profile}, socket, error_key) do
    {:noreply, socket |> assign_profile(profile) |> assign(errors: Map.delete(socket.assigns.errors, error_key))}
  end

  defp handle_result({:error, reason}, socket, error_key) do
    {:noreply, assign(socket, errors: Map.put(socket.assigns.errors, error_key, error_message(reason)))}
  end

  defp parse_links(%{"links_text" => text} = params) do
    params
    |> Map.delete("links_text")
    |> Map.put("links", String.split(text, ~r/[\r\n]+/, trim: true))
  end

  defp parse_links(params), do: params

  @doc false
  def error_message(:slug_taken), do: "That url is already taken"
  def error_message(:invalid_video), do: "That doesn't look like a YouTube video link"
  def error_message(:not_your_video), do: "That video isn't from one of your connected channels"
  def error_message(:video_not_found), do: "Couldn't find that video"
  def error_message(:no_youtube_channel), do: "Connect your YouTube channel first"
  def error_message(:youtube_unavailable), do: "Couldn't verify the video right now, try one of your recent uploads"
  def error_message(%Ecto.Changeset{} = cs), do: changeset_message(cs)
  def error_message(<<message::binary>>), do: message
  def error_message(_), do: "Something went wrong, please try again"

  defp changeset_message(cs) do
    Ecto.Changeset.traverse_errors(cs, &FunctionComponents.CoreComponents.translate_error/1)
    |> Enum.map_join(", ", fn {field, messages} -> "#{field} #{Enum.join(messages, ", ")}" end)
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp links_value(form) do
    case Phoenix.HTML.Form.input_value(form, :links) do
      links when is_list(links) -> links
      _ -> []
    end
  end

  defp page_path(%{id: nil}), do: nil
  defp page_path(profile), do: Creators.canonical_path(profile)

  defp page_urls(profile, twitch_login, youtube_channels) do
    slug = CreatorProfile.active_slug(profile) && "/creator/#{profile.slug}"
    twitch = twitch_login && "/creator/twitch/#{twitch_login}"
    youtube = Enum.map(youtube_channels, &youtube_url/1)

    [slug, twitch | youtube]
    |> Enum.filter(& &1)
    |> Enum.map(&(BackendWeb.Endpoint.url() <> &1))
  end

  defp youtube_url(%{handle: "@" <> handle}), do: "/creator/youtube/#{handle}"
  defp youtube_url(%{channel_id: channel_id}), do: "/creator/youtube/#{channel_id}"

  defp slug_status_label(:pending), do: "Awaiting review"
  defp slug_status_label(:preapproved), do: "Live"
  defp slug_status_label(:approved), do: "Live"
  defp slug_status_label(:rejected), do: "Rejected"
  defp slug_status_label(_), do: ""

  defp slug_status_class(status) when status in [:approved, :preapproved],
    do: "tw-bg-emerald-500/15 tw-text-emerald-300 tw-border-emerald-500/40"

  defp slug_status_class(:rejected), do: "tw-bg-rose-500/15 tw-text-rose-300 tw-border-rose-500/40"
  defp slug_status_class(_), do: "tw-bg-amber-500/15 tw-text-amber-300 tw-border-amber-500/40"
end
