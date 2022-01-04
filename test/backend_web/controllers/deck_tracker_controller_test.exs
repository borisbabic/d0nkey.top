defmodule BackendWeb.DeckTrackerControllerTest do
  use BackendWeb.ConnCase

  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.PlayerDto

  @valid_request %{
    player: %{
      battletag: "D0nkey#2470",
      rank: 51,
      legend_rank: 512,
      deckcode:
        "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
    },
    opponent: %{
      battletag: "BlaBla#14314",
      rank: 50,
      legend_rank: nil
    },
    game_id: "first_game",
    game_type: 7,
    format: 2,
    region: "KR"
  }

  @valid_hdt_request %{
    "Duration" => 9,
    "Format" => 2,
    "GameId" => "d287762e-3cf7-4741-a02c-29ae5fa3290e",
    "GameType" => 1,
    "Mode" => 7,
    "Opponent" => %{
      "Battletag" => "The Innkeeper",
      "Class" => "Shaman",
      "Deckcode" => nil,
      "LegendRank" => 0,
      "Rank" => 0
    },
    "Player" => %{
      "Battletag" => "D0nkey#2470",
      "Class" => "Priest",
      "Deckcode" => "AAECAa0GHh6XAskGigf2B9MK65sD/KMDmakDn6kD8qwDha0DgbEDjrEDkbEDk7oDm7oDr7oDyL4DyMAD3swDlc0Dy80D184D49ED+9ED/tEDndgD4t4D+OMDAAA=",
      "LegendRank" => 0,
      "Rank" => 0
    },
    "Result" => "LOSS",
    "Turns" => 0
  }
  describe "put game" do
    @describetag :api_user
    test "400 when missing game_id", %{conn: conn} do
      conn = put(conn, Routes.deck_tracker_path(conn, :put_game))
      assert text_response(conn, 400) =~ "Missing game_id"
    end

    test "create new game", %{conn: conn} do
      game_id = Ecto.UUID.generate()
      request = Map.put(@valid_request, :game_id, game_id)
      conn = put(conn, Routes.deck_tracker_path(conn, :put_game), request)
      assert text_response(conn, 200) =~ "Success"
      assert %{game_id: ^game_id} = Hearthstone.DeckTracker.get_game_by_game_id(game_id)
    end

    test "create hdt game", %{conn: conn} do
      game_id = Ecto.UUID.generate()
      request = Map.put(@valid_hdt_request, "GameId", game_id)
      conn = put(conn, Routes.deck_tracker_path(conn, :put_game), request)
      assert text_response(conn, 200) =~ "Success"
      assert %{game_id: ^game_id} = Hearthstone.DeckTracker.get_game_by_game_id(game_id)
    end
  end
end
