defmodule BackendWeb.DeckController do
  use BackendWeb, :controller

  require Logger

  alias Backend.Hearthstone.Deck

  def archetype_decks(conn, %{"decks" => decks}) do
    body =
      for code <- decks, {:ok, deck} = Deck.decode(code), into: %{} do
        {
          code,
          %{
            "archetype" => Deck.archetype(deck),
            "name" => Deck.name(deck)
          }
        }
      end

    conn
    |> put_status(200)
    |> json(body)
  end
end
