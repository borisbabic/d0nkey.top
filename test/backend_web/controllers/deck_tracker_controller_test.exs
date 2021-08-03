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
  describe "put game" do
    @describetag :api_user
    test "400 when missing game_id", %{conn: conn} do
      conn = put(conn, Routes.deck_tracker_path(conn, :put_game))
      assert text_response(conn, 400) =~ "Missing game_id"
    end

    test "create new game", %{conn: conn} do
      conn = put(conn, Routes.deck_tracker_path(conn, :put_game), @valid_request)
      assert text_response(conn, 200) =~ "Success"
    end
  end
end
