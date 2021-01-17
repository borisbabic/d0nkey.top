defmodule BackendWeb.DeckOnlyLive do
  @moduledoc false
  alias Components.Decklist
  alias Backend.Hearthstone.Deck
  use Surface.LiveView
  data(deckcode, :string)

  def mount(_params, %{"code" => code}, socket) do
    {:ok, socket |> assign(deckcode: code)}
  end

  def render(assigns) do
    deck = Deck.decode!(assigns[:deckcode])

    ~H"""
    <Decklist deck={{deck}} />
    """
  end
end