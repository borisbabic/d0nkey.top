defmodule BackendWeb.ChatBotCommandHookController do
  use BackendWeb, :controller
  @moduledoc "for use with ${customapi} (streamelements)) and $(urlfetch) (nightbot)"
  alias Hearthstone.DeckcodeExtractor

  def deck_url(conn, %{"channel" => _, "deckcode" => deckcode_raw}) do
    deckcode = if is_list(deckcode_raw) do
      Enum.join(deckcode_raw, "/")
    else
      deckcode_raw
    end
    with [deck] <- DeckcodeExtractor.performant_extract_from_text(deckcode),
         {:ok, %{id: id}} <- Backend.Hearthstone.create_or_get_deck(deck) do
      conn |> text("https://www.hsguru.com/deck/#{id}")
    else
      _ -> conn |> put_status(400)
    end
  end

  def deck_url(conn, _params) do
    conn
    |> put_status(400)
  end
end
