defmodule Backend.Api.StreamingTest do
  use ExUnit.Case, async: true

  alias Backend.Api.Streaming
  alias Hearthstone.Enums.BnetGameType

  test "filters and sorts current streams" do
    now = DateTime.utc_now()

    streams = [
      stream("first", 50, now, BnetGameType.ranked_standard(), "deckcode"),
      stream("second", 150, DateTime.add(now, -60), BnetGameType.ranked_wild(), nil)
    ]

    assert {:ok, %{streams: [result], total: 1}} =
             Streaming.live_streams(
               %{"mode" => "Standard", "has_deck" => "yes", "sort_by" => "most_viewers"},
               streams
             )

    assert result.display_name == "first"
    assert result.deckcode == "deckcode"
    assert result.mode == "Standard"
  end

  test "rejects unsupported streaming parameters" do
    assert {:error, {:invalid_parameter, "private", "is not supported"}} =
             Streaming.live_streams(%{"private" => "yes"}, [])
  end

  test "validates streamer deck list filters" do
    assert {:error, {:invalid_parameter, "include_cards", _message}} =
             Streaming.streamer_decks(%{"include_cards" => ["not-a-dbf-id"]})
  end

  defp stream(name, viewers, started_at, game_type, deckcode) do
    %{
      user_id: name,
      user_name: name,
      thumbnail_url: "https://example.com/#{name}.jpg",
      viewer_count: viewers,
      title: "Hearthstone",
      language: "en",
      started_at: started_at,
      legend_rank: 100,
      stream_id: name,
      deckcode: deckcode,
      game_type: game_type
    }
  end
end
