defmodule BackendWeb.DeckController do
  use BackendWeb, :controller

  require Logger

  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck

  def deck_info(conn, %{"deck" => code}) do
    code
    |> Enum.join("/")
    |> Deck.decode()
    |> case do
      {:ok, deck} ->
        body = Hearthstone.deck_info(deck)

        conn
        |> put_status(200)
        |> json(body)

      _ ->
        conn
        |> put_status(400)
        |> text("Invalid deck. Could not decode id")
    end
  end

  def deck_info(conn, %{"decks" => decks}) do
    body =
      for code <- decks, {result, deck} = Deck.decode(code), result == :ok, into: %{} do
        {code, Hearthstone.deck_info(deck)}
      end

    conn
    |> put_status(200)
    |> json(body)
  end
end
