defmodule Backend.GameDtoTest do
  use Backend.DataCase

  describe "game_dto" do
    alias Hearthstone.DeckTracker.GameDto
    alias Hearthstone.DeckTracker.PlayerDto

    @valid_map %{
      "player" => %{
        "battletag" => "D0nkey#2470",
        "legend_rank" => 4,
        "rank" => 51,
        "deckcode" => "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
      },
      "opponent" => %{
        "battletag" => "BlaBla#14314",
        "rank" => 50,
        "legend_rank" => nil
      },
      "game_id" => "first_game",
      "game_type" => 7,
      "format" => 2,
      "result" => "WON",
      "region" => "KR"
    }

    @valid_map_with_played %{
      "player" => %{
        "battletag" => "D0nkey#2470",
        "legend_rank" => 4,
        "rank" => 51,
        "cardsWithCreatedBy" => [
          %{
            "cardId" => 74_097,
            "turn" => 1,
            "createdBy" => "test"
          }
        ],
        "deckcode" => "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
      },
      "opponent" => %{
        "battletag" => "BlaBla#14314",
        "rank" => 50,
        "cardsWithCreatedBy" => [
          %{
            "cardId" => 74_097,
            "turn" => 3,
            "createdBy" => "test"
          }
        ],
        "legend_rank" => nil
      },
      "game_id" => "first_game",
      "game_type" => 7,
      "format" => 2,
      "result" => "WON",
      "region" => "KR"
    }

    test "creates correct ecto attrs" do
      assert dto =
               %GameDto{player: %PlayerDto{}, opponent: %PlayerDto{}} =
               GameDto.from_raw_map(@valid_map, nil)

      assert %{"status" => :win, "region" => :AP} = GameDto.to_ecto_attrs(dto, &{:ok, &1}, fn _, _ -> {:error, nil} end)
    end

    test "creates_correct ecto attrs with played cards" do
      assert dto =
               %GameDto{player: %PlayerDto{}, opponent: %PlayerDto{}} =
               GameDto.from_raw_map(@valid_map_with_played, nil)

      assert %{
               "played_cards" => %{
                 "player_start_of_game" => [],
                 "opponent_start_of_game" => []
               }
             } = GameDto.to_ecto_attrs(dto, &{:ok, &1}, fn _, _ -> {:error, nil} end)
    end

    test "creates correct ecto attrs with start of game cards" do
      map_with_sog =
        @valid_map_with_played
        |> put_in(["player", "startOfGame"], [74_097, %{"cardId" => 74_097, "createdBy" => "created_effect"}])
        |> put_in(["opponent", "start_of_game"], [%{"card_id" => 74_097}, %{card_id: 74_097, created?: true}])

      assert dto = GameDto.from_raw_map(map_with_sog, nil)
      assert dto.player.start_of_game == [74_097, %{"cardId" => 74_097, "createdBy" => "created_effect"}]

      assert %{
               "played_cards" => %{
                 "player_start_of_game" => [74_097],
                 "opponent_start_of_game" => [74_097]
               }
             } = GameDto.to_ecto_attrs(dto, &{:ok, &1}, fn _, _ -> {:error, nil} end)
    end

    test "create_played_cards_ecto_attrs backwards compatibility (arity 5)" do
      assert {:ok, attrs} =
               GameDto.create_played_cards_ecto_attrs(
                 [%{card_id: 74_097, created?: false}],
                 [%{card_id: 74_097, created?: false}],
                 "PRIEST",
                 "PRIEST",
                 2
               )

      assert %{
               "player_cards" => [74_097],
               "opponent_cards" => [74_097],
               "player_start_of_game" => [],
               "opponent_start_of_game" => []
             } = attrs
    end
  end
end
