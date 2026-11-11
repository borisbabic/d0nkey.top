defmodule BackendWeb.CreatorLive do
  @moduledoc "A content creator's public page: socials, stream, decks and videos"
  use BackendWeb, :surface_live_view
  alias Backend.Creators
  alias Backend.UserManager
  alias Backend.UserManager.YoutubeChannel
  alias Components.ExpandableDecklist
  alias Components.Socials

  data(user, :any)
  data(profile, :any)
  data(page, :map)
  data(video, :any)

  def mount(_params, session, socket) do
    {:ok, socket |> assign_defaults(session) |> put_user_in_context()}
  end

  def handle_params(params, uri, %{assigns: %{user: viewer}} = socket) do
    profile = find_profile(socket.assigns.live_action, params)

    if Creators.visible?(profile, viewer) do
      show_or_redirect(socket, profile, URI.parse(uri).path)
    else
      {:noreply, assign(socket, profile: nil, page: nil, page_title: "Creator not found")}
    end
  end

  defp find_profile(:slug, %{"slug" => slug}), do: Creators.by_slug(slug)
  defp find_profile(:twitch, %{"login" => login}), do: Creators.by_twitch_login(login)
  defp find_profile(:youtube, %{"handle" => handle}), do: Creators.by_youtube(handle)
  defp find_profile(_, _), do: nil

  # every page has one url so links and search results aren't split
  defp show_or_redirect(socket, profile, current_path) do
    case Creators.canonical_path(profile) do
      path when path in [nil, current_path] -> {:noreply, assign_page(socket, profile)}
      canonical -> {:noreply, push_navigate(socket, to: canonical, replace: true)}
    end
  end

  defp assign_page(socket, profile) do
    page = build_page(profile)

    socket
    |> assign(profile: profile, page: page, page_title: page.name)
    |> assign_async(:video, fn -> {:ok, %{video: Creators.featured_video(profile)}} end)
  end

  defp build_page(%{user: user} = profile) do
    youtube_channels = UserManager.youtube_channels(user)
    {featured_deck, recent_decks} = Creators.decks(profile)
    twitch_login = Creators.twitch_login(user)

    %{
      name: display_name(profile, youtube_channels),
      avatar: youtube_channels |> Enum.find_value(& &1.thumbnail_url),
      twitch_login: twitch_login,
      youtube_channels: youtube_channels,
      live: profile.show_stream && Creators.live_info(profile),
      featured_deck: featured_deck,
      recent_decks: recent_decks,
      player_profile_link: player_profile_link(profile)
    }
  end

  defp display_name(%{user: user}, youtube_channels) do
    Creators.twitch_display(user) ||
      Enum.find_value(youtube_channels, & &1.title) ||
      Backend.UserManager.User.display_name(user)
  end

  defp player_profile_link(%{show_player_profile: true, user: %{battletag: <<btag::binary>>}}),
    do: ~p"/player-profile/#{btag}"

  defp player_profile_link(_), do: nil

  def render(assigns) do
    ~F"""
    <div class="tw-max-w-6xl tw-mx-auto tw-px-4 tw-py-6 tw-space-y-6 tw-text-slate-300">
      <div :if={!@page} id="creator-not-found" class="tw-p-10 tw-text-center tw-rounded-2xl tw-border tw-border-slate-800 tw-bg-slate-900/40">
        <h1 class="tw-text-2xl tw-font-bold tw-text-white">Creator not found</h1>
        <p class="tw-mt-2 tw-text-slate-400">This creator page doesn't exist or isn't public yet.</p>
        <a href={~p"/profile/creator"} class="tw-inline-block tw-mt-4 has-text-info tw-underline">Set up your own creator page</a>
      </div>

      <div :if={@page} id="creator-page" class="tw-space-y-6">
        {render_owner_bar(assigns)}
        {render_header(assigns)}
        <FunctionComponents.Ads.below_title/>
        {render_main(assigns)}
        {render_recent_decks(assigns)}
      </div>
    </div>
    """
  end

  defp render_owner_bar(assigns) do
    ~F"""
    <div :if={owner?(@profile, @user)} id="creator-owner-bar" class={[
      "tw-flex tw-flex-wrap tw-items-center tw-justify-between tw-gap-3 tw-px-4 tw-py-3 tw-rounded-xl tw-border tw-text-sm",
      if(@profile.enabled, do: "tw-border-slate-700 tw-bg-slate-800/40", else: "tw-border-amber-600/50 tw-bg-amber-900/20 tw-text-amber-200")
    ]}>
      <span :if={@profile.enabled}>This is your creator page.</span>
      <span :if={!@profile.enabled}>Preview: your page is not public. Only you can see it.</span>
      <a id="edit-creator-page" href={~p"/profile/creator"} class="button is-small is-link">Edit page</a>
    </div>
    """
  end

  defp render_header(assigns) do
    ~F"""
    <header id="creator-header" class="tw-relative tw-overflow-hidden tw-rounded-2xl tw-border tw-border-slate-800 tw-bg-gradient-to-br tw-from-slate-900 tw-via-slate-900 tw-to-indigo-950/60 tw-p-6 md:tw-p-8">
      <div class="tw-flex tw-flex-col sm:tw-flex-row tw-gap-5 sm:tw-items-center">
        <img :if={@page.avatar} src={@page.avatar} alt="" referrerpolicy="no-referrer"
          class="tw-w-20 tw-h-20 tw-rounded-full tw-ring-2 tw-ring-slate-700 tw-shrink-0"/>
        <div :if={!@page.avatar} class="tw-w-20 tw-h-20 tw-rounded-full tw-ring-2 tw-ring-slate-700 tw-shrink-0 tw-bg-slate-800 tw-flex tw-items-center tw-justify-center tw-text-3xl tw-font-bold tw-text-slate-400">
          {String.first(@page.name || "?")}
        </div>
        <div class="tw-min-w-0 tw-space-y-2">
          <div class="tw-flex tw-flex-wrap tw-items-center tw-gap-3">
            <h1 class="tw-text-3xl tw-font-extrabold tw-text-white tw-truncate">{@page.name}</h1>
            {render_live_badge(assigns)}
          </div>
          <p :if={@profile.bio not in [nil, ""]} id="creator-bio" class="tw-text-slate-300 tw-whitespace-pre-line tw-max-w-2xl">{@profile.bio}</p>
        </div>
      </div>
      {render_socials(assigns)}
    </header>
    """
  end

  defp render_live_badge(assigns) do
    ~F"""
    <a :if={@page.live} id="creator-live" href={@page.live.link} target="_blank" rel="noopener noreferrer" title={@page.live.title}
      class="tw-group tw-inline-flex tw-items-center tw-gap-2 tw-px-3 tw-py-1 tw-rounded-full tw-bg-red-500/15 tw-border tw-border-red-500/50 tw-text-red-300 tw-text-sm tw-font-semibold hover:tw-bg-red-500/25 tw-transition-colors">
      <span class="tw-relative tw-flex tw-h-2 tw-w-2">
        <span class="tw-animate-ping tw-absolute tw-inline-flex tw-h-full tw-w-full tw-rounded-full tw-bg-red-400 tw-opacity-75"></span>
        <span class="tw-relative tw-inline-flex tw-rounded-full tw-h-2 tw-w-2 tw-bg-red-500"></span>
      </span>
      Live on {platform_name(@page.live.platform)}
      <span class="tw-transition-transform group-hover:tw-translate-x-0.5" aria-hidden="true">→</span>
    </a>
    """
  end

  defp render_socials(assigns) do
    ~F"""
    <nav id="creator-socials" aria-label="Socials" class="tw-flex tw-flex-wrap tw-gap-2 tw-mt-5">
      <Socials.twitch :if={@page.twitch_login} channel={@page.twitch_login} live?={false}/>
      <Socials.youtube :for={channel <- @page.youtube_channels} link={YoutubeChannel.url(channel)} label={channel.title || channel.handle}/>
      <Socials.social :for={link <- @profile.links} link={link} auto_label?={true}/>
      <a :if={@page.player_profile_link} id="creator-player-profile" href={@page.player_profile_link}
        class="tw-inline-flex tw-items-center tw-gap-1.5 tw-px-3 tw-py-1.5 tw-rounded-lg tw-text-xs tw-font-semibold tw-border tw-transition-all tw-duration-150 tw-bg-amber-900/20 hover:tw-bg-amber-800/30 tw-text-amber-200 tw-border-amber-700/50 hover:tw-border-amber-600/60">
        <HeroIcons.user size="small"/> Player Profile
      </a>
    </nav>
    """
  end

  defp render_main(assigns) do
    ~F"""
    <div class="tw-grid tw-grid-cols-1 lg:tw-grid-cols-[auto_1fr] tw-gap-6 tw-items-start">
      <section :if={@page.featured_deck} id="creator-featured-deck" class="tw-space-y-2">
        <h2 class="tw-text-sm tw-font-bold tw-uppercase tw-tracking-wider tw-text-slate-400">
          {featured_deck_title(@page.featured_deck, @profile)}
        </h2>
        <ExpandableDecklist id="creator_featured_deck" deck={@page.featured_deck.deck} show_cards={true}/>
        <p :if={@page.featured_deck[:last_played]} class="tw-text-xs tw-text-slate-500">
          Last played {Util.human_diff(NaiveDateTime.utc_now(), @page.featured_deck.last_played)} ago
        </p>
      </section>
      {render_video(assigns)}
    </div>
    """
  end

  defp render_video(assigns) do
    ~F"""
    <section :if={@profile.video_mode != :none} id="creator-video" class="tw-space-y-2 tw-min-w-0">
      <div :if={@video.loading} class="tw-aspect-video tw-w-full tw-rounded-xl tw-bg-slate-800/50 tw-animate-pulse"></div>
      <div :if={@video.ok? && @video.result} class="tw-space-y-2">
        <h2 class="tw-text-sm tw-font-bold tw-uppercase tw-tracking-wider tw-text-slate-400">
          {if @video.result.pinned?, do: "Featured Video", else: "Latest Video"}
        </h2>
        <div class="tw-aspect-video tw-w-full tw-overflow-hidden tw-rounded-xl tw-border tw-border-slate-800 tw-shadow-2xl tw-bg-black">
          <iframe
            id="creator-video-embed"
            class="tw-w-full tw-h-full"
            src={"https://www.youtube-nocookie.com/embed/#{@video.result.id}"}
            title={@video.result.title || "YouTube video"}
            loading="lazy"
            referrerpolicy="strict-origin-when-cross-origin"
            allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
            allowfullscreen></iframe>
        </div>
        <p :if={@video.result.title} class="tw-font-semibold tw-text-white">{@video.result.title}</p>
      </div>
    </section>
    """
  end

  defp render_recent_decks(assigns) do
    ~F"""
    <section :if={Enum.any?(@page.recent_decks)} id="creator-recent-decks" class="tw-space-y-3">
      <div class="tw-flex tw-items-baseline tw-justify-between tw-gap-3">
        <h2 class="tw-text-sm tw-font-bold tw-uppercase tw-tracking-wider tw-text-slate-400">Recent Decks</h2>
        <a :if={more_decks_link(@profile, @page)} href={more_decks_link(@profile, @page)} class="tw-text-sm has-text-info hover:tw-underline">See all</a>
      </div>
      <div class="tw-flex tw-flex-wrap tw-gap-4">
        <div :for={{recent, index} <- Enum.with_index(@page.recent_decks)} id={"creator-recent-deck-#{index}"} class="tw-transition-transform hover:-tw-translate-y-0.5">
          <ExpandableDecklist id={"creator_recent_deck_#{index}"} deck={recent.deck} show_cards={false}/>
        </div>
      </div>
    </section>
    """
  end

  defp featured_deck_title(%{pinned?: true}, _), do: "Featured Deck"
  defp featured_deck_title(_, %{deck_source: :public}), do: "Latest Deck"
  defp featured_deck_title(_, _), do: "Latest Stream Deck"

  defp more_decks_link(%{deck_source: :streamer}, %{twitch_login: <<login::binary>>}),
    do: ~p"/streamer-decks?#{%{"twitch_login" => login}}"

  defp more_decks_link(%{deck_source: :public, show_player_profile: true, user: %{battletag: <<btag::binary>>}}, _),
    do: ~p"/player/#{btag}/decks"

  defp more_decks_link(_, _), do: nil

  defp platform_name(:twitch), do: "Twitch"
  defp platform_name(:youtube), do: "YouTube"

  defp owner?(%{user_id: user_id}, %{id: user_id}), do: true
  defp owner?(_, _), do: false

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}
end
