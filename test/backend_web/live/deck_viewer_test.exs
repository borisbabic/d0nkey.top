defmodule BackendWeb.Live.DeckViewerTest do
  use BackendWeb.ConnCase
  import Plug.Conn
  import Phoenix.LiveViewTest
  alias Backend.Hearthstone.Deck

  test "renders", %{conn: conn} do
    {:ok, view, html} = live(conn, "/deckviewer")
    assert html =~ "Paste deckcode"
  end

  test "Renders three decks", %{conn: conn} do
    decks = [
      "AAECAea5Awb39gOL9wOw+QPQ+QOHiwSEsAQM1tEDzNIDzdID3dMD+dUD8+MDlegD/e0DivcDyIAEs6AEtKAEAA==",
      "AAECAZICAvzoA9mfBA6bzgO50gOV4AOM5AOt7APJ9QPs9QOB9wOE9wOsgASvgASwgATnpAS4vgQA",
      "AAECAR8E5NQDj+MD/fgDu4oEDbnQA43kA4/kA9zqA5/sA9vtA/f4A6mfBKqfBOOfBLugBL+sBMGsBAA="
    ]

    code = Enum.join(decks, ",")
    query = URI.encode_query(%{code: code})
    {:ok, _view, html} = live(conn, "/deckviewer?#{query}")

    for d <- decks do
      assert html =~ d
    end
  end

  test "Add deckcode through form", %{conn: conn} do
    deckcode =
      "AAECAea5Awb39gOL9wOw+QPQ+QOHiwSEsAQM1tEDzNIDzdID3dMD+dUD8+MDlegD/e0DivcDyIAEs6AEtKAEAA=="

    {:ok, view, html} = live(conn, "/deckviewer")
    refute html =~ deckcode

    assert view
           |> form("#add_deck_form", %{new_deck: %{new_code: deckcode}})
           |> render_submit() =~ deckcode
  end

  test "Add urls through form", %{conn: conn} do
    deckcode =
      "AAECAea5Awb39gOL9wOw+QPQ+QOHiwSEsAQM1tEDzNIDzdID3dMD+dUD8+MDlegD/e0DivcDyIAEs6AEtKAEAA=="

    urls = [
      "https://www.yaytears.com/conquest/AAECAea5Awb39gOL9wOw%2BQPQ%2BQOHiwSEsAQM1tEDzNIDzdID3dMD%2BdUD8%2BMDlegD%2Fe0DivcDyIAEs6AEtKAEAA%3D%3D",
      "https://www.d0nkey.top/deckviewer?code=AAECAea5Awb39gOL9wOw%2BQPQ%2BQOHiwSEsAQM1tEDzNIDzdID3dMD%2BdUD8%2BMDlegD%2Fe0DivcDyIAEs6AEtKAEAA%3D%3D&compare_decks=false&rotation=false",
      "https://hsdeckviewer.github.io/?deckstring=AAECAea5Awb39gOL9wOw%2BQPQ%2BQOHiwSEsAQM1tEDzNIDzdID3dMD%2BdUD8%2BMDlegD%2Fe0DivcDyIAEs6AEtKAEAA%3D%3D",
      "https://hsdeckviewer.com/?deckstring=AAECAea5Awb39gOL9wOw%2BQPQ%2BQOHiwSEsAQM1tEDzNIDzdID3dMD%2BdUD8%2BMDlegD%2Fe0DivcDyIAEs6AEtKAEAA%3D%3D"
    ]

    {:ok, view, html} = live(conn, "/deckviewer")

    refute html =~ deckcode

    for url <- urls do
      assert view
             |> form("#add_deck_form", %{new_deck: %{new_code: url}})
             |> render_submit() =~ deckcode
    end
  end

  test "Deckcode with invalid card is still displayed", %{conn: conn} do
    cards = [-120, -144, -214, 64709, 69513, 69513, 69539, 69539, 69550, 69550, 70320, 70320]
    deckcode = Deck.deckcode(cards, 2, 274)
    query = URI.encode_query(%{code: deckcode})
    {:ok, _view, html} = live(conn, "/deckviewer?#{query}")
    assert html =~ deckcode
  end
end
