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

    @with_known_card_stats %GameDto{
      player: %PlayerDto{
        battletag: "D0nkey#2470",
        rank: nil,
        legend_rank: nil,
        cards_in_hand_after_mulligan: [%{card_dbf_id: 74097, kept: false}],
        cards_drawn_from_initial_deck: [%{card_dbf_id: 74097, turn: 3}],
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
    @with_unknown_card_stats %GameDto{
      player: %PlayerDto{
        battletag: "D0nkey#2470",
        rank: nil,
        legend_rank: nil,
        cards_in_hand_after_mulligan: [%{card_id: "THIS DOEST NOT EXIST", kept: false}],
        cards_drawn_from_initial_deck: [%{card_id: "CORE_CFM_753", turn: 3}],
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
      assert {:ok, %Game{status: :in_progress, turns: nil, duration: nil}} =
               DeckTracker.handle_game(@valid_dto)

      update_dto = %{@valid_dto | result: "WON", turns: 7, duration: 480}
      assert {:ok, %{status: :win, turns: 7, duration: 480}} = DeckTracker.handle_game(update_dto)
    end

    test "handle_game/1 supports minimal info" do
      assert {:ok, %Game{status: :win, turns: nil, duration: nil, game_id: "bla bla car"}} =
               DeckTracker.handle_game(@minimal_dto)
    end

    test "handle_game/1 saves raw stats when card is not known" do
      assert {:ok, %Game{status: :win, turns: nil, duration: nil, game_id: "bla bla car"} = game} =
               DeckTracker.handle_game(@with_unknown_card_stats)

      preloaded = Backend.Repo.preload(game, :raw_player_card_stats)
      assert %{cards_in_hand_after_mulligan: _} = preloaded.raw_player_card_stats
    end

    test "handle_game/1 saves card_tallies when cards are known" do
      assert {:ok, %Game{status: :win, turns: nil, duration: nil, game_id: "bla bla car"} = game} =
               DeckTracker.handle_game(@with_known_card_stats)

      preloaded = Backend.Repo.preload(game, :card_tallies)
      assert %{card_tallies: [_ | _]} = preloaded
    end
  end
end
