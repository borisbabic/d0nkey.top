defmodule BackendWeb.DeckOnlyLive do
  @moduledoc false
  alias Components.Decklist
  alias Backend.Hearthstone.Deck
  alias Backend.DeckInteractionTracker, as: Tracker
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

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
