defmodule Backend.StreamingTest do
  use Backend.DataCase

  alias Backend.Streaming

  describe "streamer_decks" do
    alias Hearthstone.DeckTracker.GameDto
    alias Hearthstone.DeckTracker.PlayerDto

    def dt_game_fixture() do
      game_dto = %GameDto{
        player: %PlayerDto{
          battletag: "D0nkey#2470",
          rank: 51,
          legend_rank: 512,
          deckcode:
            "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
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
  end
end
