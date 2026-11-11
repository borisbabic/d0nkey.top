defmodule Backend.Creators do
  @moduledoc """
  Content creator pages.

  Creators get pages based on their connected channels, ie /creator/twitch/nl_kripp or /creator/youtube/kripparrian.
  They can also request a short slug, ie /creator/kripp. Short slugs need admin approval,
  except slugs exactly matching one of the creator's own connected twitch logins/youtube handles,
  which are preapproved (live immediately) but still show up for admins to verify.
  """
  import Ecto.Query
  require Logger
  alias Backend.Repo
  alias Backend.Creators.CreatorProfile
  alias Backend.Hearthstone
  alias Elixir.Hearthstone.DeckTracker
  alias Backend.Streaming
  alias Backend.Streaming.Streamer
  alias Backend.Streaming.StreamerDeck
  alias Backend.UserManager
  alias Backend.UserManager.User
  alias Backend.UserManager.YoutubeChannel

  @feed_cache_ms 60 * 60 * 1000
  @recent_videos_limit 10

  # ---------------------------------------------------------------------------
  # Profiles
  # ---------------------------------------------------------------------------

  @spec get_profile(User.t() | nil) :: CreatorProfile.t() | nil
  def get_profile(%{id: user_id}) do
    CreatorProfile
    |> Repo.get_by(user_id: user_id)
    |> Repo.preload([:pinned_deck, :user])
  end

  def get_profile(_), do: nil

  @doc "The user's profile, or a new unsaved one with the defaults"
  @spec get_or_new_profile(User.t()) :: CreatorProfile.t()
  def get_or_new_profile(%User{id: user_id} = user) do
    get_profile(user) || %CreatorProfile{user_id: user_id, user: user, pinned_deck: nil}
  end

  @spec update_settings(User.t(), map()) :: {:ok, CreatorProfile.t()} | {:error, Ecto.Changeset.t()}
  def update_settings(user, attrs) do
    user
    |> get_or_new_profile()
    |> CreatorProfile.settings_changeset(attrs)
    |> save()
  end

  defp save(changeset) do
    with {:ok, profile} <- Repo.insert_or_update(changeset) do
      {:ok, Repo.preload(profile, [:pinned_deck, :user], force: true)}
    end
  end

  # ---------------------------------------------------------------------------
  # Pins
  # ---------------------------------------------------------------------------

  @doc "Pins a deck from a deckcode. Any valid deck can be pinned"
  @spec pin_deck(User.t(), String.t()) :: {:ok, CreatorProfile.t()} | {:error, any()}
  def pin_deck(user, deckcode) do
    with {:ok, deck} <- Hearthstone.create_or_get_deck(String.trim(deckcode || "")) do
      user
      |> get_or_new_profile()
      |> CreatorProfile.pin_changeset(%{pinned_deck_id: deck.id})
      |> save()
    end
  end

  @spec unpin_deck(User.t()) :: {:ok, CreatorProfile.t()} | {:error, any()}
  def unpin_deck(user) do
    user |> get_or_new_profile() |> CreatorProfile.pin_changeset(%{pinned_deck_id: nil}) |> save()
  end

  @doc """
  Pins a video from a link or id. The video must be from one of the user's connected channels.
  Recent uploads are verified from the rss feed, older videos with the youtube api
  """
  @spec pin_video(User.t(), String.t()) :: {:ok, CreatorProfile.t()} | {:error, any()}
  def pin_video(user, link_or_id) do
    with <<video_id::binary>> <- Youtube.Api.extract_video_id(link_or_id) || {:error, :invalid_video},
         :ok <- verify_video_owner(user, video_id) do
      user
      |> get_or_new_profile()
      |> CreatorProfile.pin_changeset(%{pinned_video_id: video_id, video_mode: :pinned})
      |> save()
    end
  end

  @spec unpin_video(User.t()) :: {:ok, CreatorProfile.t()} | {:error, any()}
  def unpin_video(user) do
    user
    |> get_or_new_profile()
    |> CreatorProfile.pin_changeset(%{pinned_video_id: nil, video_mode: :latest})
    |> save()
  end

  defp verify_video_owner(user, video_id) do
    channel_ids = UserManager.youtube_channel_ids(user)

    cond do
      Enum.empty?(channel_ids) -> {:error, :no_youtube_channel}
      Enum.any?(recent_videos(channel_ids), &(&1.id == video_id)) -> :ok
      true -> verify_video_owner_with_api(video_id, channel_ids)
    end
  end

  defp verify_video_owner_with_api(video_id, channel_ids) do
    with <<api_key::binary>> <- youtube_api_key() || {:error, :youtube_unavailable},
         {:ok, channel_id} <- Youtube.Api.video_channel_id(video_id, api_key) do
      if channel_id in channel_ids, do: :ok, else: {:error, :not_your_video}
    end
  end

  # ---------------------------------------------------------------------------
  # Slugs
  # ---------------------------------------------------------------------------

  @doc "Requests a short slug. Preapproved if it matches the user's own twitch login or youtube handle"
  @spec request_slug(User.t(), String.t()) :: {:ok, CreatorProfile.t()} | {:error, any()}
  def request_slug(user, slug) do
    normalized = CreatorProfile.normalize_slug(slug)
    profile = get_or_new_profile(user)

    if slug_taken?(normalized, user) do
      {:error, :slug_taken}
    else
      profile
      |> CreatorProfile.slug_changeset(normalized, initial_slug_status(user, normalized))
      |> save()
    end
  end

  @spec cancel_slug(User.t()) :: {:ok, CreatorProfile.t()} | {:error, any()}
  def cancel_slug(user) do
    user |> get_or_new_profile() |> CreatorProfile.clear_slug_changeset() |> save()
  end

  defp initial_slug_status(user, slug) do
    if slug in own_channel_slugs(user), do: :preapproved, else: :pending
  end

  @doc "Slugs the user provably owns via their connected accounts"
  @spec own_channel_slugs(User.t()) :: [String.t()]
  def own_channel_slugs(user) do
    youtube_handles = user |> UserManager.youtube_channels() |> Enum.map(& &1.handle)

    [twitch_login(user) | youtube_handles]
    |> Enum.filter(&is_binary/1)
    |> Enum.map(&CreatorProfile.normalize_slug/1)
  end

  defp slug_taken?(nil, _user), do: false

  defp slug_taken?(slug, %{id: user_id}) do
    from(p in CreatorProfile,
      where: fragment("lower(?)", p.slug) == ^slug,
      where: p.slug_status in [:approved, :preapproved],
      where: p.user_id != ^user_id
    )
    |> Repo.exists?()
  end

  @doc """
  Preapproved slugs are only valid while the user owns the matching channel.
  Call after the user disconnects an account so the slug goes back to the review queue
  """
  @spec recheck_preapproval(User.t()) :: :ok
  def recheck_preapproval(user) do
    with %{slug_status: :preapproved, slug: slug} = profile <- get_profile(user),
         false <- slug in own_channel_slugs(user) do
      profile |> CreatorProfile.slug_status_changeset(:pending) |> Repo.update()
    end

    :ok
  end

  @review_statuses [:pending, :preapproved]

  @doc "Slug requests awaiting admin action: pending requests and preapproved slugs to verify"
  @spec slug_requests() :: [CreatorProfile.t()]
  def slug_requests do
    from(p in CreatorProfile,
      where: p.slug_status in ^@review_statuses,
      order_by: [asc: p.slug_requested_at],
      preload: [:user]
    )
    |> Repo.all()
  end

  @doc "Number of slug requests awaiting admin action, see `slug_requests/0`"
  @spec slug_requests_count() :: integer()
  def slug_requests_count do
    from(p in CreatorProfile, where: p.slug_status in ^@review_statuses)
    |> Repo.aggregate(:count)
  end

  @doc "If the user can review slug requests. Matches the /admin scope which requires super admins"
  @spec can_review_slugs?(User.t() | nil) :: boolean()
  def can_review_slugs?(user), do: User.super_admin?(user || %{admin_roles: []})

  @doc "Slug requests the user should review, 0 for users who can't review them"
  @spec slug_requests_to_review(User.t() | nil) :: integer()
  def slug_requests_to_review(user) do
    if can_review_slugs?(user), do: slug_requests_count(), else: 0
  end

  @spec approved_slugs(integer()) :: [CreatorProfile.t()]
  def approved_slugs(limit \\ 100) do
    from(p in CreatorProfile,
      where: p.slug_status == :approved,
      order_by: [desc: p.updated_at],
      limit: ^limit,
      preload: [:user]
    )
    |> Repo.all()
  end

  @spec set_slug_status(integer() | String.t(), :approved | :rejected) ::
          {:ok, CreatorProfile.t()} | {:error, any()}
  def set_slug_status(profile_id, status) when status in [:approved, :rejected] do
    case Repo.get(CreatorProfile, profile_id) do
      nil ->
        {:error, :not_found}

      profile ->
        profile
        |> CreatorProfile.slug_status_changeset(status)
        |> Ecto.Changeset.unique_constraint(:slug, name: :creator_profiles_active_slug_index)
        |> Repo.update()
    end
  end

  # ---------------------------------------------------------------------------
  # Resolving pages
  # ---------------------------------------------------------------------------

  @spec by_slug(String.t()) :: CreatorProfile.t() | nil
  def by_slug(slug) do
    normalized = CreatorProfile.normalize_slug(slug)

    from(p in CreatorProfile,
      where: fragment("lower(?)", p.slug) == ^normalized,
      where: p.slug_status in [:approved, :preapproved]
    )
    |> one_profile()
  end

  @spec by_twitch_login(String.t()) :: CreatorProfile.t() | nil
  def by_twitch_login(login) do
    login = String.downcase(login)

    from(p in CreatorProfile,
      join: u in assoc(p, :user),
      join: s in Streamer,
      on: fragment("?::text", s.twitch_id) == u.twitch_id,
      where:
        fragment("lower(?)", s.twitch_login) == ^login or
          fragment("lower(?)", s.hsreplay_twitch_login) == ^login
    )
    |> one_profile()
  end

  @spec by_youtube(String.t()) :: CreatorProfile.t() | nil
  def by_youtube(handle_or_channel_id) do
    handle = "@" <> String.downcase(String.trim_leading(handle_or_channel_id, "@"))

    from(p in CreatorProfile,
      join: yc in YoutubeChannel,
      on: yc.user_id == p.user_id,
      where: fragment("lower(?)", yc.handle) == ^handle or yc.channel_id == ^handle_or_channel_id
    )
    |> one_profile()
  end

  defp one_profile(query) do
    query
    |> limit(1)
    |> preload([:pinned_deck, :user])
    |> Repo.one()
  end

  @doc "If the page is visible to the viewer. Disabled pages are only visible to their owner as a preview"
  @spec visible?(CreatorProfile.t() | nil, User.t() | nil) :: boolean()
  def visible?(%{enabled: true}, _viewer), do: true
  def visible?(%{user_id: user_id}, %{id: user_id}), do: true
  def visible?(_, _), do: false

  @doc "The preferred url of the page: short slug > twitch > youtube"
  @spec canonical_path(CreatorProfile.t()) :: String.t() | nil
  def canonical_path(%CreatorProfile{user: user} = profile) do
    cond do
      slug = CreatorProfile.active_slug(profile) -> "/creator/#{slug}"
      login = twitch_login(user) -> "/creator/twitch/#{login}"
      channel = primary_youtube_channel(profile) -> youtube_path(channel)
      true -> nil
    end
  end

  defp youtube_path(%{handle: "@" <> handle}), do: "/creator/youtube/#{handle}"
  defp youtube_path(%{channel_id: channel_id}), do: "/creator/youtube/#{channel_id}"

  @doc "Creator page paths of the streamers that have an enabled creator page, keyed by streamer id"
  @spec paths_for_streamers([Streamer.t()]) :: %{integer() => String.t()}
  def paths_for_streamers(streamers) do
    twitch_ids = for %{twitch_id: id} <- streamers, id, do: to_string(id)
    channel_ids = for %{youtube_channel_id: id} <- streamers, id, do: id
    paths = paths_for_channels(twitch_ids, channel_ids)

    for s <- streamers, path = streamer_path(paths, s), into: %{}, do: {s.id, path}
  end

  defp streamer_path(paths, %{twitch_id: twitch_id, youtube_channel_id: channel_id}) do
    Map.get(paths, {:twitch, to_string(twitch_id)}) || Map.get(paths, {:youtube, channel_id})
  end

  @doc """
  Creator page paths of enabled pages for the twitch ids/youtube channel ids,
  keyed by `{:twitch, twitch_id}` or `{:youtube, channel_id}`
  """
  @spec paths_for_channels([String.t()], [String.t()]) :: %{{:twitch | :youtube, String.t()} => String.t()}
  def paths_for_channels([], []), do: %{}

  def paths_for_channels(twitch_ids, channel_ids) do
    from(p in CreatorProfile,
      join: u in assoc(p, :user),
      left_join: yc in YoutubeChannel,
      on: yc.user_id == u.id,
      where: p.enabled,
      where: u.twitch_id in ^twitch_ids or yc.channel_id in ^channel_ids,
      distinct: p.id,
      preload: [user: u]
    )
    |> Repo.all()
    |> Enum.flat_map(&channel_path_entries/1)
    |> Map.new()
  end

  defp channel_path_entries(%{user: user} = profile) do
    path = canonical_path(profile)
    youtube = for id <- UserManager.youtube_channel_ids(user), do: {{:youtube, id}, path}
    twitch = if user.twitch_id, do: [{{:twitch, user.twitch_id}, path}], else: []
    twitch ++ youtube
  end

  @doc """
  The creator page of the battletag, only if the creator opted into linking their player profile.
  Otherwise we'd reveal which battletag belongs to the creator
  """
  @spec path_for_battletag(String.t() | nil) :: String.t() | nil
  def path_for_battletag(<<battletag::binary>>) do
    from(p in CreatorProfile,
      join: u in assoc(p, :user),
      where: u.battletag == ^battletag and p.enabled and p.show_player_profile,
      preload: [user: u]
    )
    |> Repo.one()
    |> case do
      nil -> nil
      profile -> canonical_path(profile)
    end
  end

  def path_for_battletag(_), do: nil

  # ---------------------------------------------------------------------------
  # Page content
  # ---------------------------------------------------------------------------

  @spec twitch_login(User.t() | nil) :: String.t() | nil
  def twitch_login(%{twitch_id: <<twitch_id::binary>>}) do
    case Streaming.get_streamer_by_twitch_id(Util.to_int_or_orig(twitch_id)) do
      %Streamer{} = s -> Streamer.twitch_login(s)
      _ -> nil
    end
  end

  def twitch_login(_), do: nil

  @spec twitch_display(User.t() | nil) :: String.t() | nil
  def twitch_display(%{twitch_id: <<twitch_id::binary>>}) do
    case Streaming.get_streamer_by_twitch_id(Util.to_int_or_orig(twitch_id)) do
      %Streamer{} = s -> Streamer.twitch_display(s)
      _ -> nil
    end
  end

  def twitch_display(_), do: nil

  @doc "The channel used for the latest video, the selected one if it's still connected, otherwise the first"
  @spec primary_youtube_channel(CreatorProfile.t()) :: YoutubeChannel.t() | nil
  def primary_youtube_channel(%{user: user, youtube_channel_id: selected}) do
    channels = UserManager.youtube_channels(user)
    Enum.find(channels, List.first(channels), &(&1.channel_id == selected))
  end

  @type live_info :: %{platform: :twitch | :youtube, link: String.t(), title: String.t() | nil}
  @spec live_info(CreatorProfile.t()) :: live_info() | nil
  def live_info(%{user: user}) do
    twitch_live_info(user) || youtube_live_info(user)
  end

  defp twitch_live_info(%{twitch_id: <<twitch_id::binary>>}) do
    case Enum.find(Twitch.HearthstoneLive.streams(), &(to_string(&1.user_id) == twitch_id)) do
      nil ->
        nil

      stream ->
        login = Twitch.Stream.login(stream)
        %{platform: :twitch, link: Backend.Twitch.create_channel_link(login), title: stream.title}
    end
  end

  defp twitch_live_info(_), do: nil

  defp youtube_live_info(user) do
    channel_ids = UserManager.youtube_channel_ids(user)

    case Enum.find(Youtube.HearthstoneLive.live_streams(), &(&1.channel_id in channel_ids)) do
      nil -> nil
      stream -> %{platform: :youtube, link: stream.link, title: stream.title}
    end
  end

  @doc "The featured deck and the recent decks, based on the creator's settings"
  @spec decks(CreatorProfile.t(), integer()) :: {featured :: map() | nil, recent :: [map()]}
  def decks(%{deck_source: source, pinned_deck: pinned} = profile, recent_limit \\ 6) do
    latest = latest_decks(source, profile.user, recent_limit + 1)
    featured = featured_deck(pinned, latest)
    recent = if profile.show_recent_decks, do: recent_decks(latest, featured, recent_limit), else: []
    {featured, recent}
  end

  defp featured_deck(%Hearthstone.Deck{} = pinned, _latest), do: %{deck: pinned, pinned?: true}
  defp featured_deck(_, [latest | _]), do: latest
  defp featured_deck(_, []), do: nil

  defp recent_decks(latest, featured, limit) do
    featured_id = featured && featured.deck.id
    latest |> Enum.reject(&(&1.deck.id == featured_id)) |> Enum.take(limit)
  end

  @spec latest_decks(:streamer | :public | :none, User.t(), integer()) :: [map()]
  def latest_decks(:streamer, user, limit), do: latest_streamer_decks(user, limit)
  def latest_decks(:public, user, limit), do: latest_public_decks(user, limit)
  def latest_decks(_, _user, _limit), do: []

  defp latest_streamer_decks(user, limit) do
    case streamer_ids(user) do
      [] ->
        []

      ids ->
        from(sd in StreamerDeck,
          where: sd.streamer_id in ^ids,
          order_by: [desc: sd.last_played],
          limit: ^(limit * 2),
          preload: [:deck]
        )
        |> Repo.all()
        |> Enum.uniq_by(& &1.deck_id)
        |> Enum.take(limit)
        |> Enum.map(&%{deck: &1.deck, last_played: &1.last_played, pinned?: false})
    end
  end

  defp streamer_ids(user) do
    twitch_ids = user.twitch_id |> Util.to_int(nil) |> List.wrap()
    channel_ids = UserManager.youtube_channel_ids(user)

    from(s in Streamer,
      where: s.twitch_id in ^twitch_ids or s.youtube_channel_id in ^channel_ids,
      select: s.id
    )
    |> Repo.all()
  end

  defp latest_public_decks(%{battletag: <<btag::binary>>}, limit) do
    [{"player_btag", btag}, {"public", true}, {"order_by", "latest"}, {"limit", limit * 5}]
    |> DeckTracker.games()
    |> Enum.filter(& &1.player_deck)
    |> Enum.uniq_by(& &1.player_deck_id)
    |> Enum.take(limit)
    |> Enum.map(&%{deck: &1.player_deck, last_played: &1.inserted_at, pinned?: false})
  end

  defp latest_public_decks(_, _), do: []

  @doc "The video to show, based on the creator's settings"
  @spec featured_video(CreatorProfile.t()) :: map() | nil
  def featured_video(%{video_mode: :pinned, pinned_video_id: <<id::binary>>}),
    do: %{id: id, title: nil, pinned?: true}

  def featured_video(%{video_mode: :none}), do: nil

  def featured_video(profile) do
    case primary_youtube_channel(profile) do
      nil -> nil
      channel -> channel.channel_id |> List.wrap() |> recent_videos() |> List.first()
    end
  end

  @doc "Recent videos of the channels, newest first. Cached since it's fetched on page views"
  @spec recent_videos([String.t()]) :: [map()]
  def recent_videos(channel_ids) do
    channel_ids
    |> Enum.flat_map(&cached_feed_videos/1)
    |> Enum.sort_by(& &1.published_at, {:desc, DateTime})
  end

  defp cached_feed_videos(channel_id) do
    key = {:creator_youtube_feed, channel_id}
    now = System.monotonic_time(:millisecond)

    case safe_cache_get(key) do
      {fetched_at, videos} when now - fetched_at < @feed_cache_ms -> videos
      _ -> fetch_and_cache_feed(key, channel_id, now)
    end
  end

  defp fetch_and_cache_feed(key, channel_id, now) do
    case Youtube.Api.feed_videos(channel_id, @recent_videos_limit) do
      {:ok, videos} ->
        videos = Enum.map(videos, &Map.put(&1, :pinned?, false))
        Backend.Infrastructure.ApiCache.set(key, {now, videos})
        videos

      {:error, reason} ->
        Logger.warning("Couldn't fetch youtube feed for #{channel_id}: #{inspect(reason)}")
        []
    end
  end

  defp safe_cache_get(key) do
    Backend.Infrastructure.ApiCache.get(key)
  catch
    :exit, _ -> nil
  end

  defp youtube_api_key, do: Application.get_env(:backend, :youtube_api_key)
end
