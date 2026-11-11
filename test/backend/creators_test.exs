defmodule Backend.CreatorsTest do
  use Backend.DataCase
  import Backend.UserFixtures
  alias Backend.Creators
  alias Backend.Creators.CreatorProfile
  alias Backend.Streaming
  alias Backend.UserManager

  @deckcode "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"

  defp twitch_user(login, attrs \\ %{}) do
    twitch_id = :rand.uniform(2_000_000_000)
    {:ok, _} = Streaming.create_streamer(twitch_id, %{twitch_login: login, twitch_display: String.upcase(login)})
    user_fixture(Map.put(attrs, :twitch_id, to_string(twitch_id)))
  end

  defp youtube_user(handle, channel_id) do
    user = user_fixture()

    {[_], []} =
      UserManager.add_youtube_channels(user, [%{channel_id: channel_id, title: "YT #{handle}", handle: handle}])

    user
  end

  describe "settings" do
    test "saves settings and cleans links" do
      user = user_fixture()

      assert {:ok, profile} =
               Creators.update_settings(user, %{
                 "bio" => "  Hi there  ",
                 "links" => ["x.com/someone", "", "https://bsky.app/profile/someone.bsky.social"],
                 "deck_source" => "public"
               })

      assert profile.bio == "Hi there"
      assert profile.links == ["https://x.com/someone", "https://bsky.app/profile/someone.bsky.social"]
      assert profile.deck_source == :public
      refute profile.enabled
    end

    test "rejects invalid links and long bios" do
      user = user_fixture()
      assert {:error, cs} = Creators.update_settings(user, %{"links" => ["javascript:alert(1)"]})
      assert %{links: [_ | _]} = errors_on(cs)

      assert {:error, cs} = Creators.update_settings(user, %{"bio" => String.duplicate("a", 281)})
      assert %{bio: [_]} = errors_on(cs)
    end
  end

  describe "slugs" do
    test "slug matching own twitch login is preapproved" do
      user = twitch_user("nl_kripp_test")
      assert {:ok, %{slug: "nl_kripp_test", slug_status: :preapproved}} = Creators.request_slug(user, "NL_Kripp_Test")
    end

    test "slug matching own youtube handle is preapproved" do
      user = youtube_user("@kripparrian_test", "UC_kripp_test")
      assert {:ok, %{slug_status: :preapproved}} = Creators.request_slug(user, "@kripparrian_test")
    end

    test "other slugs need approval" do
      user = twitch_user("nl_kripp_test2")
      assert {:ok, %{slug: "kripp", slug_status: :pending}} = Creators.request_slug(user, "kripp")
      assert [%{slug: "kripp"}] = Enum.filter(Creators.slug_requests(), &(&1.user_id == user.id))
    end

    test "reserved and invalid slugs are rejected" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Creators.request_slug(user, "twitch")
      assert {:error, %Ecto.Changeset{}} = Creators.request_slug(user, "a b")
      assert {:error, %Ecto.Changeset{}} = Creators.request_slug(user, "ab")
    end

    test "live slugs can't be requested by others, pending ones can" do
      owner = twitch_user("taken_slug")
      other = user_fixture()
      {:ok, _} = Creators.request_slug(owner, "taken_slug")
      assert {:error, :slug_taken} = Creators.request_slug(other, "taken_slug")

      {:ok, _} = Creators.request_slug(other, "pending_slug")
      assert {:ok, %{slug_status: :pending}} = Creators.request_slug(owner, "pending_slug")
    end

    test "approving a slug someone else holds fails" do
      owner = twitch_user("held_slug")
      other = user_fixture()
      {:ok, _} = Creators.request_slug(other, "held_slug")
      {:ok, _} = Creators.request_slug(owner, "held_slug")
      other_profile = Creators.get_profile(other)

      assert {:error, %Ecto.Changeset{}} = Creators.set_slug_status(other_profile.id, :approved)
      assert {:ok, %{slug_status: :rejected}} = Creators.set_slug_status(other_profile.id, :rejected)
    end

    test "disconnecting twitch sends a preapproved slug back to review" do
      user = twitch_user("disconnecting")
      {:ok, _} = Creators.request_slug(user, "disconnecting")
      {:ok, _} = UserManager.remove_twitch(user)
      assert %{slug_status: :pending} = Creators.get_profile(user)
    end

    test "approved slugs survive disconnecting" do
      user = twitch_user("approved_disc")
      {:ok, profile} = Creators.request_slug(user, "approved_disc")
      {:ok, _} = Creators.set_slug_status(profile.id, :approved)
      {:ok, _} = UserManager.remove_twitch(user)
      assert %{slug_status: :approved} = Creators.get_profile(user)
    end
  end

  describe "resolving" do
    test "by twitch login, youtube handle and slug" do
      twitch = twitch_user("resolve_me")
      {:ok, twitch_profile} = Creators.update_settings(twitch, %{"enabled" => true})
      assert Creators.by_twitch_login("Resolve_Me").id == twitch_profile.id

      yt = youtube_user("@resolve_yt", "UC_resolve_yt")
      {:ok, yt_profile} = Creators.update_settings(yt, %{"enabled" => true})
      assert Creators.by_youtube("resolve_yt").id == yt_profile.id
      assert Creators.by_youtube("UC_resolve_yt").id == yt_profile.id

      {:ok, _} = Creators.request_slug(twitch, "resolve_me")
      assert Creators.by_slug("resolve_me").id == twitch_profile.id
      assert Creators.by_slug("nope_nope") == nil
    end

    test "pending slugs don't resolve" do
      user = user_fixture()
      {:ok, _} = Creators.request_slug(user, "not_yet")
      assert Creators.by_slug("not_yet") == nil
    end

    test "canonical path prefers slug, then twitch, then youtube" do
      user = twitch_user("canon")
      {[_], []} = UserManager.add_youtube_channels(user, [%{channel_id: "UC_canon", handle: "@canon_yt"}])
      {:ok, profile} = Creators.update_settings(user, %{})
      assert Creators.canonical_path(profile) == "/creator/twitch/canon"

      {:ok, profile} = Creators.request_slug(user, "canon")
      assert Creators.canonical_path(profile) == "/creator/canon"

      yt = youtube_user("@only_yt", "UC_only_yt")
      {:ok, yt_profile} = Creators.update_settings(yt, %{})
      assert Creators.canonical_path(yt_profile) == "/creator/youtube/only_yt"

      assert Creators.canonical_path(Creators.get_or_new_profile(user_fixture())) == nil
    end

    test "visibility" do
      user = user_fixture()
      {:ok, profile} = Creators.update_settings(user, %{})
      refute Creators.visible?(profile, nil)
      refute Creators.visible?(profile, user_fixture())
      assert Creators.visible?(profile, user)
      {:ok, profile} = Creators.update_settings(user, %{"enabled" => true})
      assert Creators.visible?(profile, nil)
    end

    test "battletag links only when opted in" do
      user = twitch_user("btag_link")
      {:ok, _} = Creators.update_settings(user, %{"enabled" => true})
      assert Creators.path_for_battletag(user.battletag) == nil

      {:ok, _} = Creators.update_settings(user, %{"show_player_profile" => true})
      assert Creators.path_for_battletag(user.battletag) == "/creator/twitch/btag_link"
    end

    test "paths for streamers" do
      user = twitch_user("streamer_path")
      {:ok, _} = Creators.update_settings(user, %{"enabled" => true})
      streamer = Streaming.get_streamer_by_twitch_id(Util.to_int(user.twitch_id, nil))
      other = Streaming.create_streamer(:rand.uniform(2_000_000_000), %{twitch_login: "nobody"}) |> elem(1)

      assert Creators.paths_for_streamers([streamer, other]) == %{streamer.id => "/creator/twitch/streamer_path"}
    end
  end

  describe "pins" do
    test "pins and unpins a deck" do
      user = user_fixture()
      assert {:ok, %{pinned_deck: %{id: _}}} = Creators.pin_deck(user, @deckcode)
      {featured, _} = user |> Creators.get_profile() |> Creators.decks()
      assert featured.pinned?

      assert {:ok, %{pinned_deck_id: nil}} = Creators.unpin_deck(user)
      assert {:error, _} = Creators.pin_deck(user, "not a deck")
    end

    test "video pins require a youtube channel and a valid link" do
      user = user_fixture()
      assert {:error, :invalid_video} = Creators.pin_video(user, "https://example.com")
      assert {:error, :no_youtube_channel} = Creators.pin_video(user, "https://youtu.be/dQw4w9WgXcQ")
    end

    test "pinned video is featured" do
      profile = %CreatorProfile{video_mode: :pinned, pinned_video_id: "dQw4w9WgXcQ"}
      assert %{id: "dQw4w9WgXcQ", pinned?: true} = Creators.featured_video(profile)
      assert Creators.featured_video(%CreatorProfile{video_mode: :none}) == nil
    end
  end

  describe "decks" do
    test "no decks when nothing is played" do
      user = user_fixture()
      {:ok, profile} = Creators.update_settings(user, %{})
      assert {nil, []} = Creators.decks(profile)
      {:ok, profile} = Creators.update_settings(user, %{"deck_source" => "public"})
      assert {nil, []} = Creators.decks(profile)
    end
  end
end
