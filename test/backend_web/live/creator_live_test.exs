defmodule BackendWeb.CreatorLiveTest do
  use BackendWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Backend.Creators
  alias Backend.Streaming

  @deckcode "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"

  defp connect_twitch(user, login) do
    twitch_id = :rand.uniform(2_000_000_000)
    {:ok, _} = Streaming.create_streamer(twitch_id, %{twitch_login: login, twitch_display: login})
    {:ok, user} = Backend.UserManager.set_twitch(user, to_string(twitch_id))
    user
  end

  describe "public page" do
    test "unknown creator", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/creator/twitch/does_not_exist")
      assert has_element?(view, "#creator-not-found")
    end

    test "disabled page is hidden from others", %{conn: conn} do
      user = create_temp_user() |> connect_twitch("hidden_creator")
      {:ok, _} = Creators.update_settings(user, %{"enabled" => false})

      {:ok, view, _html} = live(conn, "/creator/twitch/hidden_creator")
      assert has_element?(view, "#creator-not-found")
    end

    test "shows an enabled page with only what the creator has", %{conn: conn} do
      user = create_temp_user() |> connect_twitch("shown_creator")

      {:ok, _} =
        Creators.update_settings(user, %{
          "enabled" => true,
          "bio" => "I play hearthstone",
          "links" => ["https://x.com/shown_creator"],
          "video_mode" => "none"
        })

      {:ok, _} = Creators.pin_deck(user, @deckcode)

      {:ok, view, _html} = live(conn, "/creator/twitch/shown_creator")
      assert has_element?(view, "#creator-header")
      assert has_element?(view, "#creator-bio")
      assert has_element?(view, "#creator-socials a[href='https://x.com/shown_creator']")
      assert has_element?(view, "#creator-featured-deck")
      refute has_element?(view, "#creator-video")
      refute has_element?(view, "#creator-live")
      refute has_element?(view, "#creator-player-profile")
      refute has_element?(view, "#creator-owner-bar")
    end

    test "links the player profile only when opted in", %{conn: conn} do
      user = create_temp_user() |> connect_twitch("profile_link")
      {:ok, _} = Creators.update_settings(user, %{"enabled" => true, "show_player_profile" => true})

      {:ok, view, _html} = live(conn, "/creator/twitch/profile_link")
      assert has_element?(view, "#creator-player-profile")
    end

    test "redirects to the short url", %{conn: conn} do
      user = create_temp_user() |> connect_twitch("redirect_me")
      {:ok, _} = Creators.update_settings(user, %{"enabled" => true})
      {:ok, _} = Creators.request_slug(user, "redirect_me")

      assert {:error, {:live_redirect, %{to: "/creator/redirect_me"}}} =
               live(conn, "/creator/twitch/redirect_me")

      {:ok, view, _html} = live(conn, "/creator/redirect_me")
      assert has_element?(view, "#creator-page")
    end

    test "a page with nothing set up still renders", %{conn: conn} do
      user = create_temp_user()
      {:ok, profile} = Creators.update_settings(user, %{"enabled" => true})
      {:ok, _} = Creators.request_slug(user, "bare_page")
      {:ok, _} = Creators.set_slug_status(profile.id, :approved)

      {:ok, view, _html} = live(conn, "/creator/bare_page")
      assert has_element?(view, "#creator-header")
      refute has_element?(view, "#creator-featured-deck")
      refute has_element?(view, "#creator-recent-decks")
    end

    @tag :authenticated
    test "owner can preview a disabled page", %{conn: conn, user: user} do
      user |> connect_twitch("owner_preview")
      {:ok, _} = Creators.update_settings(user, %{"enabled" => false})

      {:ok, view, _html} = live(conn, "/creator/twitch/owner_preview")
      assert has_element?(view, "#creator-owner-bar")
      assert has_element?(view, "#edit-creator-page")
    end
  end

  describe "settings page" do
    test "requires login", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/profile/creator")
      assert has_element?(view, "#creator-settings-logged-out")
    end

    @tag :authenticated
    test "saves settings", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/profile/creator")
      assert has_element?(view, "#creator-settings-form")
      # video pinning needs a connected youtube channel
      refute has_element?(view, "#creator-video-pin")
      refute has_element?(view, "#view-creator-page")

      view
      |> form("#creator-settings-form", %{
        "creator_profile" => %{
          "bio" => "Hello!",
          "links_text" => "x.com/me\nhttps://discord.gg/abc",
          "deck_source" => "public"
        }
      })
      |> render_change()

      profile = Creators.get_profile(user)
      assert profile.bio == "Hello!"
      assert profile.links == ["https://x.com/me", "https://discord.gg/abc"]
      assert profile.deck_source == :public
    end

    @tag :authenticated
    test "toggles the page on", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/profile/creator")
      view |> element("#toggle-creator-enabled") |> render_click()
      assert Creators.get_profile(user).enabled
    end

    @tag :authenticated
    test "requests a short url", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/profile/creator")
      view |> form("#creator-slug-form", %{"slug" => "my_short"}) |> render_submit()

      assert has_element?(view, "#creator-slug-status")
      refute has_element?(view, "#creator-slug-form")
      assert %{slug: "my_short", slug_status: :pending} = Creators.get_profile(user)

      view |> element("#cancel-slug") |> render_click()
      assert %{slug: nil} = Creators.get_profile(user)
    end

    @tag :authenticated
    test "shows slug errors", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/profile/creator")
      html = view |> form("#creator-slug-form", %{"slug" => "youtube"}) |> render_submit()
      assert html =~ "reserved"
    end

    @tag :authenticated
    test "pins a deck", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/profile/creator")
      view |> form("#creator-pin-deck-form", %{"deckcode" => @deckcode}) |> render_submit()

      assert has_element?(view, "#creator-pinned-deck")
      assert Creators.get_profile(user).pinned_deck_id

      view |> element("#unpin-deck") |> render_click()
      refute has_element?(view, "#creator-pinned-deck")
    end
  end

  describe "links from other pages" do
    test "player decks link the creator page only when opted in", %{conn: conn} do
      user = create_temp_user(%{battletag: "LinkMe#1234"}) |> connect_twitch("link_me")
      {:ok, _} = Creators.update_settings(user, %{"enabled" => true})

      {:ok, view, _html} = live(conn, "/player/LinkMe%231234/decks")
      refute has_element?(view, ".creator-page-link")

      {:ok, _} = Creators.update_settings(user, %{"show_player_profile" => true})
      {:ok, view, _html} = live(conn, "/player/LinkMe%231234/decks")
      assert has_element?(view, ".creator-page-link[href='/creator/twitch/link_me']")
    end
  end

  describe "admin" do
    test "approves and rejects slug requests" do
      admin = create_temp_user(%{admin_roles: ["super"]})
      conn = BackendWeb.ConnCase.build_conn_with_user(admin)
      requester = create_temp_user()
      {:ok, profile} = Creators.request_slug(requester, "needs_review")

      {:ok, view, _html} = live(conn, "/admin/creator-slugs")
      assert has_element?(view, "#creator-slug-#{profile.id}")

      view |> element("#approve-slug-#{profile.id}") |> render_click()
      assert %{slug_status: :approved} = Creators.get_profile(requester)
      assert has_element?(view, "#creator-slug-approved-table #creator-slug-#{profile.id}")

      view |> element("#reject-slug-#{profile.id}") |> render_click()
      assert %{slug_status: :rejected} = Creators.get_profile(requester)
    end

    test "non admins can't access the review page", %{conn: conn} do
      assert conn |> get("/admin/creator-slugs") |> response(403)
    end
  end
end
