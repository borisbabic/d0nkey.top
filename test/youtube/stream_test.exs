defmodule Youtube.StreamTest do
  use ExUnit.Case, async: true
  doctest Youtube.Api

  @video %{
    "id" => "vid123",
    "snippet" => %{
      "channelId" => "UC_abc",
      "channelTitle" => "Some Streamer",
      "title" => "Legend climb! [std]",
      "description" => "Playing Hearthstone all day",
      "liveBroadcastContent" => "live",
      "defaultAudioLanguage" => "en-US",
      "thumbnails" => %{"medium" => %{"url" => "https://i.ytimg.com/vi/vid123/mq.jpg"}}
    },
    "liveStreamingDetails" => %{
      "actualStartTime" => "2026-10-30T10:00:00Z",
      "concurrentViewers" => "42"
    }
  }

  test "from_video/1 parses a live video" do
    stream = Youtube.Stream.from_video(@video)

    assert %{
             channel_id: "UC_abc",
             channel_title: "Some Streamer",
             viewer_count: 42,
             language: "en",
             started_at: ~N[2026-10-30 10:00:00],
             hearthstone?: true,
             link: "https://www.youtube.com/watch?v=vid123"
           } = stream
  end

  test "live?/1" do
    assert Youtube.Stream.live?(@video)
    refute Youtube.Stream.live?(put_in(@video, ["snippet", "liveBroadcastContent"], "none"))
  end

  test "hearthstone?/1 checks title, description and tags" do
    refute Youtube.Stream.hearthstone?(%{"title" => "Minecraft", "description" => nil})
    assert Youtube.Stream.hearthstone?(%{"title" => "x", "tags" => ["HEARTHSTONE"]})
    assert Youtube.Stream.hearthstone?(%{"title" => "炉石传说"})
  end

  test "parse_feed_video_ids/2" do
    feed = """
    <feed><entry><yt:videoId>a1</yt:videoId></entry><entry><yt:videoId>b2</yt:videoId></entry>
    <entry><yt:videoId>c3</yt:videoId></entry></feed>
    """

    assert ["a1", "b2"] == Youtube.Api.parse_feed_video_ids(feed, 2)
  end
end
