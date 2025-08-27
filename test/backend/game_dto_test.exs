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
        "deckcode" =>
          "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
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
        "cardsWithCreatedBy" => [%{
          "cardId" => 74_097,
          "turn" => 1,
          "createdBy" => "test"
        }],
        "deckcode" =>
          "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
      },
      "opponent" => %{
        "battletag" => "BlaBla#14314",
        "rank" => 50,
        "cardsWithCreatedBy" => [%{
          "cardId" => 74_097,
          "turn" => 3,
          "createdBy" => "test"
        }],
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
      assert %{"played_cards" => _} = GameDto.to_ecto_attrs(dto, &{:ok, &1}, fn _, _ -> {:error, nil} end)
    end
  end
end
