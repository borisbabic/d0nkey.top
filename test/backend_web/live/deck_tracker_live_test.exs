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

  @tag :authenticated
  test "quick-tap result and opponent class buttons make the Save button enabled", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/deck-tracker/#{@standard_deckcode}")

    assert has_element?(view, "button[type=submit][disabled]", "Save Game")
    refute has_element?(view, "#result_WIN[aria-pressed=true]")

    view |> element("#result_WIN") |> render_click()

    assert has_element?(view, "#result_WIN[aria-pressed=true]")
    assert has_element?(view, "button[type=submit][disabled]", "Save Game")

    view |> element("#opponent_class_MAGE") |> render_click()

    assert has_element?(view, "#opponent_class_MAGE[aria-pressed=true]")
    refute has_element?(view, "button[type=submit][disabled]", "Save Game")
  end

  @tag :authenticated
  test "extra details toggle reveals coin/turns/rank fields", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/deck-tracker/#{@standard_deckcode}")

    refute has_element?(view, "#coin")

    view |> element("button", "Add extra details") |> render_click()

    assert has_element?(view, "#coin")
    assert has_element?(view, "#turns")
  end

  @tag :authenticated
  test "renders a friendly message instead of crashing when no deck can be resolved", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/deck-tracker/not-a-real-deckcode")
    assert html =~ "No deck found"
  end
end
