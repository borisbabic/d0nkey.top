defmodule Backend.DeckTrackerTest do
  use Backend.DataCase
  alias Hearthstone.DeckTracker

  describe "games" do
    alias Hearthstone.DeckTracker.Game
    alias Hearthstone.DeckTracker.GameDto
    alias Hearthstone.DeckTracker.PlayerDto

    @valid_dto %GameDto{
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
      format: 2,
      region: "KR"
    }
    @minimal_dto %GameDto{
      player: %PlayerDto{
        battletag: "D0nkey#2470",
        rank: nil,
        legend_rank: nil,
        deckcode:
          "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
      },
      opponent: %PlayerDto{
        battletag: nil,
        rank: nil,
        legend_rank: nil
      },
      result: "WON",
      game_id: "bla bla car",
      game_type: 7,
      format: 2
    }

    test "handle_game/1 returns new game and updates it" do
      assert {:ok, game = %Game{status: :in_progress, turns: nil, duration: nil}} =
               DeckTracker.handle_game(@valid_dto)

      update_dto = %{@valid_dto | result: "WON", turns: 7, duration: 480}
      assert {:ok, %{status: :win, turns: 7, duration: 480}} = DeckTracker.handle_game(update_dto)
    end

    test "handle_game/1 supports minimal info" do
      assert {:ok, %Game{status: :win, turns: nil, duration: nil, game_id: "bla bla car"}} =
               DeckTracker.handle_game(@minimal_dto)
    end
  end
end
