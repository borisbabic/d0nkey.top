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

  describe "auto_label? on individual site components" do
    test "twitch extracts channel from link" do
      html = render_component(&Socials.twitch/1, %{link: "https://www.twitch.tv/playhearthstone", auto_label?: true})
      assert html =~ "playhearthstone"
      refute html =~ ">Twitch<"

      # default auto_label? is false
      html_default = render_component(&Socials.twitch/1, %{link: "https://www.twitch.tv/playhearthstone"})
      assert html_default =~ "Twitch"

      # explicit label is preserved
      html_custom =
        render_component(&Socials.twitch/1, %{
          link: "https://www.twitch.tv/playhearthstone",
          label: "My Stream",
          auto_label?: true
        })

      assert html_custom =~ "My Stream"
    end

    test "youtube extracts channel or handle from link" do
      html = render_component(&Socials.youtube/1, %{link: "https://www.youtube.com/@Hearthstone", auto_label?: true})
      assert html =~ "@Hearthstone"

      html_c =
        render_component(&Socials.youtube/1, %{
          link: "https://www.youtube.com/c/HearthstoneEsports",
          auto_label?: true
        })

      assert html_c =~ "HearthstoneEsports"

      html_custom =
        render_component(&Socials.youtube/1, %{
          link: "https://www.youtube.com/@Hearthstone",
          label: "Custom YT",
          auto_label?: true
        })

      assert html_custom =~ "Custom YT"
    end

    test "x and twitter extract tag from link" do
      html_x = render_component(&Socials.x/1, %{link: "https://x.com/D0nkeyHS", auto_label?: true})
      assert html_x =~ "@D0nkeyHS"

      html_tw = render_component(&Socials.twitter/1, %{link: "https://twitter.com/D0nkeyHS", auto_label?: true})
      assert html_tw =~ "@D0nkeyHS"
    end

    test "bluesky extracts handle from link" do
      html = render_component(&Socials.bluesky/1, %{link: "https://bsky.app/profile/d0nkey.top", auto_label?: true})
      assert html =~ "@d0nkey.top"
    end

    test "discord extracts server code from link" do
      html = render_component(&Socials.discord/1, %{link: "https://discord.gg/6gVXMQsPxa", auto_label?: true})
      assert html =~ "6gVXMQsPxa"

      html_invite =
        render_component(&Socials.discord/1, %{link: "https://discord.com/invite/6gVXMQsPxa", auto_label?: true})

      assert html_invite =~ "6gVXMQsPxa"
    end

    test "patreon extracts creator from link" do
      html = render_component(&Socials.patreon/1, %{link: "https://www.patreon.com/d0nkey", auto_label?: true})
      assert html =~ "d0nkey"
    end

    test "paypal extracts user from link" do
      html = render_component(&Socials.paypal/1, %{link: "https://paypal.me/d0nkey", auto_label?: true})
      assert html =~ "d0nkey"
    end

    test "tiktok extracts channel from link" do
      html = render_component(&Socials.tiktok/1, %{link: "https://www.tiktok.com/@hearthstone", auto_label?: true})
      assert html =~ "@hearthstone"
    end

    test "kick extracts channel from link" do
      html = render_component(&Socials.kick/1, %{link: "https://kick.com/hearthstone", auto_label?: true})
      assert html =~ "hearthstone"
    end

    test "instagram extracts channel from link" do
      html = render_component(&Socials.instagram/1, %{link: "https://www.instagram.com/hearthstone", auto_label?: true})
      assert html =~ "@hearthstone"
    end

    test "reddit extracts subreddit and user from link" do
      html_sub = render_component(&Socials.reddit/1, %{link: "https://www.reddit.com/r/hearthstone", auto_label?: true})
      assert html_sub =~ "r/hearthstone"

      html_user = render_component(&Socials.reddit/1, %{link: "https://www.reddit.com/user/d0nkey", auto_label?: true})
      assert html_user =~ "u/d0nkey"
    end

    test "github extracts repo and user from link" do
      html_repo =
        render_component(&Socials.github/1, %{
          link: "https://github.com/borisbabic/hearthstone",
          auto_label?: true
        })

      assert html_repo =~ "borisbabic/hearthstone"

      html_user = render_component(&Socials.github/1, %{link: "https://github.com/borisbabic", auto_label?: true})
      assert html_user =~ "borisbabic"
    end

    test "facebook extracts page from link" do
      html = render_component(&Socials.facebook/1, %{link: "https://www.facebook.com/Hearthstone", auto_label?: true})
      assert html =~ "Hearthstone"
    end

    test "threads extracts handle from link" do
      html = render_component(&Socials.threads/1, %{link: "https://www.threads.net/@hearthstone", auto_label?: true})
      assert html =~ "@hearthstone"
    end
  end

  describe "website/1 fallback" do
    test "renders sensible fallback button with default label" do
      html = render_component(&Socials.website/1, %{link: "https://example.com"})

      assert html =~ "Website"
      assert html =~ "https://example.com"
      assert html =~ "tw-bg-slate-800/60"
      assert html =~ "viewBox=\"0 0 24 24\""
    end

    test "renders custom label when provided" do
      html = render_component(&Socials.website/1, %{link: "https://example.com", label: "My Blog"})

      assert html =~ "My Blog"
      assert html =~ "https://example.com"
    end

    test "renders auto_label? domain" do
      html =
        render_component(&Socials.website/1, %{
          link: "https://news.ycombinator.com/item?id=123",
          auto_label?: true
        })

      assert html =~ "news.ycombinator.com"
    end
  end

  describe "social/1 and social_link/1" do
    test "determines twitch component" do
      html = render_component(&Socials.social/1, %{link: "https://www.twitch.tv/playhearthstone"})
      assert html =~ "tw-bg-[#9146ff]/15"
      assert html =~ "Twitch"

      html_auto =
        render_component(&Socials.social/1, %{
          link: "https://www.twitch.tv/playhearthstone",
          auto_label?: true
        })

      assert html_auto =~ "playhearthstone"
    end

    test "determines youtube component" do
      html = render_component(&Socials.social/1, %{link: "https://www.youtube.com/@Hearthstone"})
      assert html =~ "tw-bg-red-950/40"
      assert html =~ "YouTube"

      html_auto =
        render_component(&Socials.social/1, %{
          link: "https://www.youtube.com/@Hearthstone",
          auto_label?: true
        })

      assert html_auto =~ "@Hearthstone"
    end

    test "determines x / twitter component" do
      html_x = render_component(&Socials.social/1, %{link: "https://x.com/D0nkeyHS", auto_label?: true})
      assert html_x =~ "@D0nkeyHS"

      html_tw = render_component(&Socials.social/1, %{link: "https://twitter.com/D0nkeyHS", auto_label?: true})
      assert html_tw =~ "@D0nkeyHS"
    end

    test "determines bluesky component" do
      html = render_component(&Socials.social/1, %{link: "https://bsky.app/profile/d0nkey.top", auto_label?: true})
      assert html =~ "@d0nkey.top"
      assert html =~ "tw-bg-[#0285ff]/15"
    end

    test "determines discord component" do
      html = render_component(&Socials.social/1, %{link: "https://discord.gg/invite_code", auto_label?: true})
      assert html =~ "invite_code"
      assert html =~ "tw-bg-[#5865F2]/15"

      html_internal = render_component(&Socials.social/1, %{link: "/discord"})
      assert html_internal =~ "Discord"
      assert html_internal =~ "tw-bg-[#5865F2]/15"
    end

    test "determines patreon component" do
      html = render_component(&Socials.social/1, %{link: "https://www.patreon.com/d0nkey", auto_label?: true})
      assert html =~ "d0nkey"
      assert html =~ "tw-bg-[#ff424d]/15"

      html_internal = render_component(&Socials.social/1, %{link: "/patreon"})
      assert html_internal =~ "Patreon"
    end

    test "determines paypal component" do
      html = render_component(&Socials.paypal/1, %{link: "https://paypal.me/d0nkey", auto_label?: true})
      assert html =~ "d0nkey"
      assert html =~ "tw-bg-[#0079c1]/15"

      html_internal = render_component(&Socials.social/1, %{link: "/paypal"})
      assert html_internal =~ "PayPal"
    end

    test "determines other social platforms (tiktok, kick, instagram, reddit, github, facebook, threads)" do
      assert render_component(&Socials.social/1, %{link: "https://tiktok.com/@foo", auto_label?: true}) =~ "@foo"
      assert render_component(&Socials.social/1, %{link: "https://kick.com/foo", auto_label?: true}) =~ "foo"
      assert render_component(&Socials.social/1, %{link: "https://instagram.com/foo", auto_label?: true}) =~ "@foo"

      assert render_component(&Socials.social/1, %{link: "https://reddit.com/r/hearthstone", auto_label?: true}) =~
               "r/hearthstone"

      assert render_component(&Socials.social/1, %{
               link: "https://github.com/borisbabic/hearthstone",
               auto_label?: true
             }) =~ "borisbabic/hearthstone"

      assert render_component(&Socials.social/1, %{link: "https://facebook.com/Hearthstone", auto_label?: true}) =~
               "Hearthstone"

      assert render_component(&Socials.social/1, %{link: "https://threads.net/@foo", auto_label?: true}) =~ "@foo"
    end

    test "falls back sensibly when no website matches" do
      html =
        render_component(&Socials.social/1, %{
          link: "https://hearthstone.blizzard.com/en-us",
          auto_label?: true
        })

      assert html =~ "hearthstone.blizzard.com"
      assert html =~ "https://hearthstone.blizzard.com/en-us"
      assert html =~ "tw-bg-slate-800/60"

      html_default = render_component(&Socials.social/1, %{link: "https://example.com"})
      assert html_default =~ "Website"

      html_custom = render_component(&Socials.social/1, %{link: "https://example.com", label: "My Custom Website"})
      assert html_custom =~ "My Custom Website"
    end

    test "social_link alias behaves identically" do
      html = render_component(&Socials.social_link/1, %{link: "https://x.com/D0nkeyHS", auto_label?: true})
      assert html =~ "@D0nkeyHS"
    end

    test "respects explicit label over auto_label?" do
      html =
        render_component(&Socials.social/1, %{
          link: "https://x.com/D0nkeyHS",
          label: "Twitter Profile",
          auto_label?: true
        })

      assert html =~ "Twitter Profile"
      refute html =~ "@D0nkeyHS"
    end

    test "handles schemeless URLs" do
      html_twitch = render_component(&Socials.social/1, %{link: "twitch.tv/playhearthstone", auto_label?: true})
      assert html_twitch =~ "playhearthstone"
      assert html_twitch =~ "tw-bg-[#9146ff]/15"

      html_x = render_component(&Socials.social/1, %{link: "x.com/D0nkeyHS", auto_label?: true})
      assert html_x =~ "@D0nkeyHS"

      html_fallback = render_component(&Socials.social/1, %{link: "example.com/test", auto_label?: true})
      assert html_fallback =~ "example.com"
      assert html_fallback =~ "tw-bg-slate-800/60"
    end

    test "handles nil and empty links without crashing" do
      html_nil = render_component(&Socials.social/1, %{link: nil})
      assert html_nil =~ "Website"

      html_empty = render_component(&Socials.social/1, %{link: ""})
      assert html_empty =~ "Website"

      html_nil_custom = render_component(&Socials.social/1, %{link: nil, label: "Empty Link"})
      assert html_nil_custom =~ "Empty Link"
    end
  end
end
