defmodule BackendWeb.Live.DeckTrackerLiveTest do
  use BackendWeb.ConnCase
  import Phoenix.LiveViewTest

  @standard_deckcode "AAECAQcAAAAA"

  test "renders auth message when not logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/deck-tracker/#{@standard_deckcode}")
    assert html =~ "Please login to Track your decks"
  end

  @tag :authenticated
  test "Standard deck maintains standard format after validation and saves correctly", %{conn: conn} do
    {:ok, view, html} = live(conn, "/deck-tracker/#{@standard_deckcode}")

    assert html =~ ~r/<option[^>]*value="2"[^>]*selected/

    game_id = Ecto.UUID.generate()

    payload = %{
      "format" => "2",
      "game_type" => "7",
      "opponent_class" => "PRIEST",
      "result" => "WIN",
      "game_id" => game_id
    }

    html_after =
      render_change(view, "validate", %{
        "game" => payload
      })

    assert html_after =~ ~r/<option[^>]*value="2"[^>]*selected/
    refute html_after =~ ~r/<option[^>]*value="1"[^>]*selected/

    render_submit(view, "submit", %{
      "game" => payload
    })

    game = Hearthstone.DeckTracker.get_game_by_game_id(game_id)
    assert game.format == 2
  end
end
