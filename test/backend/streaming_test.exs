defmodule Backend.StreamingTest do
  use Backend.DataCase

  alias Backend.Streaming

  describe "streamer_decks" do
    alias Hearthstone.DeckTracker.GameDto
    alias Hearthstone.DeckTracker.PlayerDto

    def dt_game_fixture do
      game_dto = %GameDto{
        player: %PlayerDto{
          battletag: "D0nkey#2470",
          rank: 51,
          legend_rank: 512,
          deckcode: "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
        },
        opponent: %PlayerDto{
          battletag: "BlaBla#14314",
          rank: 50,
          legend_rank: nil
        },
        game_id: "first_game",
        game_type: 7,
        result: "WON",
        format: 2,
        region: "KR"
      }

      {:ok, game} = Hearthstone.DeckTracker.handle_game(game_dto)
      game
    end

    test "log_won_game_increases_wins" do
      game = dt_game_fixture()
      twitch_id = DateTime.utc_now() |> DateTime.to_unix() |> to_string()
      {:ok, streamer_deck} = Streaming.log_streamer_game(twitch_id, game)
      assert streamer_deck.wins == 1
    end

    test "logs games for youtube streamers" do
      game = dt_game_fixture()
      {:ok, streamer} = Streaming.get_or_create_youtube_streamer("UC_log_test")
      {:ok, streamer_deck} = Streaming.log_streamer_game(streamer, game)
      assert streamer_deck.wins == 1

      assert [%{streamer: %{youtube_channel_id: "UC_log_test"}}] =
               Streaming.streamer_decks([{"youtube_channel_id", "UC_log_test"}])
    end

    test "filtering by youtube channel doesn't include twitch streamers" do
      game = dt_game_fixture()
      {:ok, _} = Streaming.log_streamer_game("1234567", game)
      {:ok, yt} = Streaming.get_or_create_youtube_streamer("UC_filter_test")
      {:ok, _} = Streaming.log_streamer_game(yt, game)

      assert [%{streamer: %{twitch_id: 1_234_567}}] =
               Streaming.streamer_decks([{"twitch_id", "1234567"}])

      assert [%{streamer: %{youtube_channel_id: "UC_filter_test"}}] =
               Streaming.streamer_decks([{"youtube_channel_id", "UC_filter_test"}])
    end
  end

  describe "youtube streamers" do
    alias Backend.Streaming.Streamer

    test "upsert_youtube_streamer creates then updates" do
      {:ok, created} = Streaming.upsert_youtube_streamer("UC_upsert", %{youtube_display: "Old"})
      {:ok, updated} = Streaming.upsert_youtube_streamer("UC_upsert", %{youtube_display: "New"})
      assert created.id == updated.id
      assert Streamer.display_name(updated) == "New"
      assert Streamer.platform(updated) == :youtube
    end

    test "a streamer needs a twitch or youtube channel" do
      refute Streamer.changeset(%Streamer{}, %{twitch_display: "nope"}).valid?
    end

    test "search finds both twitch and youtube streamers" do
      {:ok, _} = Streaming.create_streamer(98_765, %{twitch_login: "searchtwitchguy"})

      {:ok, _} =
        Streaming.upsert_youtube_streamer("UC_search", %{
          youtube_display: "Search Youtube Guy",
          youtube_handle: "@searchyt"
        })

      found = Streaming.streamers([{"search", "search"}]) |> Enum.map(&Streamer.display_name/1)
      assert "Search Youtube Guy" in found
      assert Enum.count(found) == 2

      assert [%{youtube_channel_id: "UC_search"}] =
               Streaming.streamers([{"search", "@searchyt"}, {"order_by", "search_similarity_@searchyt"}])
    end
  end
end
