defmodule Youtube.ApiTest do
  use ExUnit.Case, async: true

  @feed """
  <?xml version="1.0" encoding="UTF-8"?>
  <feed xmlns:yt="http://www.youtube.com/xml/schemas/2015" xmlns="http://www.w3.org/2005/Atom">
    <title>Some Channel</title>
    <entry>
      <id>yt:video:aaaaaaaaaaa</id>
      <yt:videoId>aaaaaaaaaaa</yt:videoId>
      <yt:channelId>UC_abc</yt:channelId>
      <title>Mage &amp; Rogue to legend</title>
      <published>2026-11-10T10:00:00+00:00</published>
    </entry>
    <entry>
      <id>yt:video:bbbbbbbbbbb</id>
      <yt:videoId>bbbbbbbbbbb</yt:videoId>
      <yt:channelId>UC_abc</yt:channelId>
      <title>Older video</title>
      <published>2026-11-01T10:00:00+00:00</published>
    </entry>
  </feed>
  """

  test "parse_feed_videos/2 parses entries" do
    assert [first, second] = Youtube.Api.parse_feed_videos(@feed, 5)
    assert %{id: "aaaaaaaaaaa", channel_id: "UC_abc", title: "Mage & Rogue to legend"} = first
    assert first.published_at == ~U[2026-11-10 10:00:00Z]
    assert second.id == "bbbbbbbbbbb"
  end

  test "parse_feed_videos/2 respects the limit" do
    assert [%{id: "aaaaaaaaaaa"}] = Youtube.Api.parse_feed_videos(@feed, 1)
  end
end
