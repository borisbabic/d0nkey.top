defmodule BackendWeb.DeckTrackerControllerTest do
  use BackendWeb.ConnCase

  alias Hearthstone.DeckTracker.GameDto
  alias Hearthstone.DeckTracker.PlayerDto

  def valid_fs_request() do
    game_id = Ecto.UUID.generate()

    request = %{
      "player" => %{
        "battletag" => "D0nkey#2470",
        "rank" => 51,
        "legend_rank" => 512,
        "deckcode" =>
          "AAECAa0GCJu6A8i+A5vYA/voA9TtA6bvA8jvA4WfBAuTugOvugPezAPXzgP+0QPi3gP44wOW6AOa6wOe6wOU7wMA"
      },
      "opponent" => %{
        "battletag" => Ecto.UUID.generate(),
        "rank" => 50,
        "legend_rank" => nil
      },
      "game_id" => game_id,
      "game_type" => 7,
      "format" => 2,
      "region" => "KR"
    }

    {game_id, request}
  end

  def valid_hdt_request(attrs \\ %{}) do
    game_id = Ecto.UUID.generate()
    version = Ecto.UUID.generate()

    request = %{
      "Duration" => 9,
      "Format" => 2,
      "GameId" => game_id,
      "GameType" => 1,
      "Mode" => 7,
      "Opponent" => %{
        "Battletag" => Ecto.UUID.generate(),
        "Class" => "Shaman",
        "Deckcode" => nil,
        "LegendRank" => 0,
        "Rank" => 0
      },
      "Player" => %{
        "Battletag" => "D0nkey#2470",
        "Class" => "Priest",
        "Deckcode" =>
          "AAECAa0GHh6XAskGigf2B9MK65sD/KMDmakDn6kD8qwDha0DgbEDjrEDkbEDk7oDm7oDr7oDyL4DyMAD3swDlc0Dy80D184D49ED+9ED/tEDndgD4t4D+OMDAAA=",
        "LegendRank" => 0,
        "Rank" => 0
      },
      "Result" => "LOSS",
      "Source" => "hdt-plugin",
      "SourceVersion" => version,
      "Coin" => true,
      "Turns" => 0
    }

    %{
      game_id: game_id,
      request: request,
      source_version: version
    }
  end

  describe "put game" do
    @describetag :api_user
    test "400 when missing game_id", %{conn: conn} do
      conn = put(conn, Routes.deck_tracker_path(conn, :put_game))
      assert text_response(conn, 400) =~ "Missing game_id"
    end

    test "create new game", %{conn: conn} do
      {game_id, request} = valid_fs_request()
      conn = put(conn, Routes.deck_tracker_path(conn, :put_game), request)
      assert json_response(conn, 200)
      assert %{game_id: ^game_id} = Hearthstone.DeckTracker.get_game_by_game_id(game_id)
    end

    test "create hdt game", %{conn: conn} do
      %{
        game_id: game_id,
        request: request
      } = valid_hdt_request()

      conn = put(conn, Routes.deck_tracker_path(conn, :put_game), request)

      assert %{
               "player_deck" => %{
                 "archetype" => "Highlander Priest",
                 "name" => "Highlander Priest"
               }
             } = json_response(conn, 200)

      coin = request["Coin"]

      assert %{game_id: ^game_id, player_has_coin: ^coin} =
               Hearthstone.DeckTracker.get_game_by_game_id(game_id)
    end

    test "same game with different id isn't duplicated", %{conn: conn} do
      %{
        game_id: first_game_id,
        request: first_request
      } = valid_hdt_request()

      conn = put(conn, Routes.deck_tracker_path(conn, :put_game), first_request)
      assert json_response(conn, 200)

      assert %{game_id: ^first_game_id} =
               Hearthstone.DeckTracker.get_game_by_game_id(first_game_id)

      second_game_id = Ecto.UUID.generate()
      second_request = Map.put(first_request, "GameId", second_game_id)
      conn = put(conn, Routes.deck_tracker_path(conn, :put_game), second_request)
      assert json_response(conn, 200)
      refute Hearthstone.DeckTracker.get_game_by_game_id(second_game_id)
    end

    test "new source is created", %{conn: conn} do
      %{
        game_id: game_id,
        request: request,
        source_version: source_version
      } = valid_hdt_request()

      refute Hearthstone.DeckTracker.get_source(request["Source"], request["SourceVersion"])
      conn = put(conn, Routes.deck_tracker_path(conn, :put_game), request)
      assert json_response(conn, 200)

      assert %{version: ^source_version} =
               Hearthstone.DeckTracker.get_source(request["Source"], request["SourceVersion"])

      assert %{source: %{version: ^source_version}} =
               Hearthstone.DeckTracker.get_game_by_game_id(game_id)
    end
  end
end
