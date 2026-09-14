defmodule BackendWeb.Components.FeedItemsTest do
  use BackendWeb.ConnCase, async: true
  use Surface.LiveViewTest

  alias Components.DeckCard
  alias Components.StreamingDeckNow
  alias Components.Feed.HSArticle
  alias Components.Feed.LatestHSArticles
  alias Components.Feed.TierList
  alias Components.Feed.Tweet
  alias Components.Feed.Bluesky
  alias Components.Feed.RevealStreamItem

  describe "Components.DeckCard" do
    test "renders modern dark-slate card container" do
      html =
        render_surface do
          ~F"""
          <DeckCard>
            Deck Content
            <:after_deck>
              After Deck Content
            </:after_deck>
          </DeckCard>
          """
        end

      assert html =~ "tw-bg-[#232a2a]"
      assert html =~ "tw-border-slate-700/80"
      assert html =~ "tw-rounded-xl"
      assert html =~ "Deck Content"
      assert html =~ "After Deck Content"
    end
  end

  describe "Components.StreamingDeckNow" do
    test "renders modern purple Twitch badge when count > 0" do
      html =
        render_surface do
          ~F"""
          <StreamingDeckNow count={3} link="/streaming-now?deckcode=abc" />
          """
        end

      assert html =~ "Live: 3"
      assert html =~ "tw-bg-[#9146ff]/20"
      assert html =~ "tw-text-[#bf94ff]"
      assert html =~ "tw-animate-pulse"
    end
  end

  describe "Components.Feed.HSArticle" do
    test "renders featured article mode with hero image and badge" do
      html =
        render_surface do
          ~F"""
          <HSArticle
            article={%{
              "blogId" => 12345,
              "title" => "Patch 30.4 Launch Details",
              "thumbnail" => %{
                "mimeType" => "image/jpeg",
                "url" => "https://example.com/thumb.jpg"
              }
            }}
            featured={true}
          />
          """
        end

      assert html =~ "Patch 30.4 Launch Details"
      assert html =~ "Latest"
      assert html =~ "tw-aspect-[2/1]"
      assert html =~ "/hs/article/12345"
      assert html =~ "https://example.com/thumb.jpg"
    end

    test "renders list mode with compact row" do
      html =
        render_surface do
          ~F"""
          <HSArticle
            article={%{
              "blogId" => 12345,
              "title" => "Patch 30.4 Launch Details",
              "thumbnail" => %{
                "mimeType" => "image/jpeg",
                "url" => "https://example.com/thumb.jpg"
              }
            }}
            featured={false}
          />
          """
        end

      assert html =~ "Patch 30.4 Launch Details"
      assert html =~ "tw-w-16"
      assert html =~ "/hs/article/12345"
    end
  end

  describe "Components.Feed.LatestHSArticles" do
    test "renders news card container and header with articles" do
      html =
        render_surface do
          ~F"""
          <LatestHSArticles
            articles={[
              %{
                "blogId" => 12345,
                "title" => "Patch 30.4 Details",
                "thumbnail" => %{"mimeType" => "image/jpeg", "url" => "https://example.com/1.jpg"}
              },
              %{
                "blogId" => 67890,
                "title" => "New Expansion Announced",
                "thumbnail" => %{"mimeType" => "image/jpeg", "url" => "https://example.com/2.jpg"}
              }
            ]}
          />
          """
        end

      assert html =~ "tw-bg-[#232a2a]"
      assert html =~ "Hearthstone News"
      assert html =~ "Official"
      assert html =~ "Patch 30.4 Details"
      assert html =~ "New Expansion Announced"
    end
  end

  describe "Components.Feed.TierList" do
    test "renders meta tier list card container, header, and table" do
      html =
        render_surface do
          ~F"""
          <TierList
            stats={[
              %{archetype: "Plague Death Knight", winrate: 0.542, total: 1000},
              %{archetype: "Elemental Mage", winrate: 0.528, total: 800}
            ]}
          />
          """
        end

      assert html =~ "tw-bg-[#232a2a]"
      assert html =~ "Top Archetypes"
      assert html =~ "Diamond–Legend • Last 2 Days"
      assert html =~ "Meta"
      assert html =~ "Plague Death Knight"
      assert html =~ "Elemental Mage"
      assert html =~ "54.2"
      assert html =~ "id=\"feed_tier_list_table\""
    end
  end

  describe "Components.Feed.Tweet" do
    test "renders tweet card with X post header" do
      html =
        render_surface do
          ~F"""
          <Tweet item={%{value: "https://x.com/PlayHearthstone/status/123"}} />
          """
        end

      assert html =~ "tw-bg-[#232a2a]"
      assert html =~ "Community Post"
      assert html =~ "View on X"
      assert html =~ "https://x.com/PlayHearthstone/status/123"
      assert html =~ "twitter-tweet"
    end
  end

  describe "Components.Feed.Bluesky" do
    test "renders bluesky card with Bluesky post header and embed from web URL with DID" do
      html =
        render_surface do
          ~F"""
          <Bluesky item={%{value: "https://bsky.app/profile/did:plc:12345/post/3lb123"}} />
          """
        end

      assert html =~ "tw-bg-[#232a2a]"
      assert html =~ "Community Post"
      assert html =~ "View on Bluesky"
      assert html =~ "https://bsky.app/profile/did:plc:12345/post/3lb123"
      assert html =~ "at://did:plc:12345/app.bsky.feed.post/3lb123"
      assert html =~ "bluesky-embed"
      assert html =~ "embed.bsky.app/static/embed.js"
    end

    test "resolves handle using cached or resolved DID" do
      Backend.Bluesky.ensure_cache_table()
      :ets.insert(:bluesky_did_cache, {"hearthstone.blizzard.com", "did:plc:xdeve7fn6refpcqie5jfsjbs"})

      html =
        render_surface do
          ~F"""
          <Bluesky item={%{value: "https://bsky.app/profile/hearthstone.blizzard.com/post/3mveaepzrkg2d"}} />
          """
        end

      assert html =~ "tw-bg-[#232a2a]"
      assert html =~ "Community Post"
      assert html =~ "View on Bluesky"
      assert html =~ "https://bsky.app/profile/hearthstone.blizzard.com/post/3mveaepzrkg2d"
      assert html =~ "at://did:plc:xdeve7fn6refpcqie5jfsjbs/app.bsky.feed.post/3mveaepzrkg2d"
      assert html =~ "bluesky-embed"
    end

    test "renders bluesky card from at-uri" do
      html =
        render_surface do
          ~F"""
          <Bluesky item={%{value: "at://did:plc:12345/app.bsky.feed.post/67890"}} />
          """
        end

      assert html =~ "tw-bg-[#232a2a]"
      assert html =~ "Community Post"
      assert html =~ "View on Bluesky"
      assert html =~ "https://bsky.app/profile/did:plc:12345/post/67890"
      assert html =~ "at://did:plc:12345/app.bsky.feed.post/67890"
      assert html =~ "bluesky-embed"
      assert html =~ "embed.bsky.app/static/embed.js"
    end

    test "renders nothing when item value is nil" do
      html =
        render_surface do
          ~F"""
          <Bluesky item={%{value: nil}} />
          """
        end

      refute html =~ "bluesky-embed"
    end

    @tag :external
    test "resolves custom domain handle via live API" do
      aturi = Backend.Bluesky.to_aturi("https://bsky.app/profile/hearthstone.blizzard.com/post/3mveaepzrkg2d")
      assert aturi == "at://did:plc:xdeve7fn6refpcqie5jfsjbs/app.bsky.feed.post/3mveaepzrkg2d"
    end
  end

  describe "Components.Feed.RevealStreamItem" do
    test "renders empty span when reveal stream item does not exist" do
      html =
        render_surface do
          ~F"""
          <RevealStreamItem item={%{value: "non_existent_stream"}} />
          """
        end

      assert html =~ "<span"
    end
  end
end
