defmodule BackendWeb.Components.SocialsTest do
  use BackendWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Components.Socials

  describe "twitch/1" do
    test "renders twitch badge with default text" do
      html = render_component(&Socials.twitch/1, %{})

      assert html =~ "Twitch"
      assert html =~ "https://www.twitch.tv/"
      assert html =~ "tw-bg-[#9146ff]/15"
      refute html =~ "Live"
    end

    test "renders twitch badge with channel" do
      html = render_component(&Socials.twitch/1, %{channel: "playhearthstone"})

      assert html =~ "playhearthstone"
      assert html =~ "https://www.twitch.tv/playhearthstone"
      assert html =~ "tw-border-[#9146ff]/40"
    end

    test "renders twitch with string argument" do
      html = rendered_to_string(Socials.twitch("playhearthstone"))

      assert html =~ "playhearthstone"
      assert html =~ "https://www.twitch.tv/playhearthstone"
    end

    test "renders twitch live indicator when live? is true" do
      html = render_component(&Socials.twitch/1, %{channel: "playhearthstone", live?: true})

      assert html =~ "Live"
      assert html =~ "tw-animate-ping"
      assert html =~ "tw-bg-red-500/20"
      refute html =~ "is-size-7"
      refute html =~ "has-text-info"
    end

    test "does not render live indicator when live? is false" do
      html = render_component(&Socials.twitch/1, %{channel: "playhearthstone", live?: false})

      refute html =~ "tw-animate-ping"
      refute html =~ "is-size-7"
    end
  end

  describe "youtube/1" do
    test "renders youtube badge" do
      html = render_component(&Socials.youtube/1, %{channel: "Hearthstone"})

      assert html =~ "Hearthstone"
      assert html =~ "https://www.youtube.com/Hearthstone"
      assert html =~ "tw-bg-red-950/40"
      refute html =~ "Live"
    end

    test "renders live indicator when live? is true" do
      html = render_component(&Socials.youtube/1, %{channel: "Hearthstone", live?: true})

      assert html =~ "Live"
      assert html =~ "tw-animate-ping"
      assert html =~ "tw-bg-red-500/20"
    end
  end

  describe "bluesky/1" do
    test "renders bluesky badge with handle" do
      html = render_component(&Socials.bluesky/1, %{handle: "d0nkey.top"})

      assert html =~ "@d0nkey.top"
      assert html =~ "https://bsky.app/profile/d0nkey.top"
      assert html =~ "tw-bg-[#0285ff]/15"
      assert html =~ "viewBox=\"0 0 568 501\""
    end

    test "renders default bluesky link without handle" do
      html = render_component(&Socials.bluesky/1, %{})

      assert html =~ "Bluesky"
      assert html =~ "https://bsky.app"
    end
  end

  describe "discord/1" do
    test "renders discord badge with link" do
      html = render_component(&Socials.discord/1, %{link: "/discord"})

      assert html =~ "Discord"
      assert html =~ "tw-bg-[#5865F2]/15"
      assert html =~ "viewBox=\"0 0 448 512\""
    end
  end

  describe "patreon/1" do
    test "renders patreon badge with link" do
      html = render_component(&Socials.patreon/1, %{link: "/patreon"})

      assert html =~ "Patreon"
      assert html =~ "tw-bg-[#ff424d]/15"
      assert html =~ "viewBox=\"0 0 512 512\""
    end

    test "patreon_image is preserved" do
      html = render_component(&Socials.patreon_image/1, %{})

      assert html =~ "patreon_wordmark_fierycoral.png"
    end
  end

  describe "paypal/1" do
    test "renders paypal badge with link" do
      html = render_component(&Socials.paypal/1, %{link: "/paypal"})

      assert html =~ "PayPal"
      assert html =~ "tw-bg-[#0079c1]/15"
      assert html =~ "viewBox=\"0 0 384 512\""
    end
  end

  describe "x/1 and twitter/1" do
    test "renders x badge with tag" do
      html = render_component(&Socials.x/1, %{tag: "D0nkeyHS"})

      assert html =~ "@D0nkeyHS"
      assert html =~ "https://x.com/D0nkeyHS"
      assert html =~ "tw-bg-slate-800/60"
    end

    test "twitter alias works identically" do
      html = render_component(&Socials.twitter/1, %{tag: "D0nkeyHS"})

      assert html =~ "@D0nkeyHS"
      assert html =~ "https://x.com/D0nkeyHS"
    end
  end

  describe "streaming socials with live? support" do
    test "tiktok renders badge and live indicator" do
      html_offline = render_component(&Socials.tiktok/1, %{channel: "hearthstone"})

      assert html_offline =~ "@hearthstone"
      assert html_offline =~ "https://www.tiktok.com/@hearthstone"
      assert html_offline =~ "tw-bg-[#fe2c55]/15"
      refute html_offline =~ "Live"

      html_live = render_component(&Socials.tiktok/1, %{channel: "hearthstone", live?: true})

      assert html_live =~ "Live"
      assert html_live =~ "tw-animate-ping"
    end

    test "kick renders badge and live indicator" do
      html_offline = render_component(&Socials.kick/1, %{channel: "hearthstone"})

      assert html_offline =~ "hearthstone"
      assert html_offline =~ "https://kick.com/hearthstone"
      assert html_offline =~ "tw-bg-[#53FC18]/15"
      refute html_offline =~ "Live"

      html_live = render_component(&Socials.kick/1, %{channel: "hearthstone", live?: true})

      assert html_live =~ "Live"
      assert html_live =~ "tw-animate-ping"
    end

    test "instagram renders badge and live indicator" do
      html_offline = render_component(&Socials.instagram/1, %{channel: "hearthstone"})

      assert html_offline =~ "@hearthstone"
      assert html_offline =~ "https://www.instagram.com/hearthstone"
      assert html_offline =~ "tw-bg-[#e4405f]/15"
      refute html_offline =~ "Live"

      html_live = render_component(&Socials.instagram/1, %{channel: "hearthstone", live?: true})

      assert html_live =~ "Live"
      assert html_live =~ "tw-animate-ping"
    end

    test "facebook renders badge and live indicator" do
      html_offline = render_component(&Socials.facebook/1, %{page: "Hearthstone"})

      assert html_offline =~ "Hearthstone"
      assert html_offline =~ "https://www.facebook.com/Hearthstone"
      assert html_offline =~ "tw-bg-[#1877f2]/15"
      refute html_offline =~ "Live"

      html_live = render_component(&Socials.facebook/1, %{page: "Hearthstone", live?: true})

      assert html_live =~ "Live"
      assert html_live =~ "tw-animate-ping"
    end
  end

  describe "additional socials" do
    test "reddit renders subreddit or user" do
      html_sub = render_component(&Socials.reddit/1, %{subreddit: "hearthstone"})

      assert html_sub =~ "r/hearthstone"
      assert html_sub =~ "https://www.reddit.com/r/hearthstone"
      assert html_sub =~ "tw-bg-[#ff4500]/15"

      html_user = render_component(&Socials.reddit/1, %{user: "d0nkey"})

      assert html_user =~ "u/d0nkey"
      assert html_user =~ "https://www.reddit.com/u/d0nkey"
    end

    test "github renders repo or user" do
      html = render_component(&Socials.github/1, %{repo: "borisbabic/hearthstone"})

      assert html =~ "borisbabic/hearthstone"
      assert html =~ "https://github.com/borisbabic/hearthstone"
      assert html =~ "tw-bg-slate-800/60"
    end

    test "threads renders handle" do
      html = render_component(&Socials.threads/1, %{handle: "hearthstone"})

      assert html =~ "@hearthstone"
      assert html =~ "https://www.threads.net/@hearthstone"
      assert html =~ "tw-bg-slate-800/60"
    end
  end
end
