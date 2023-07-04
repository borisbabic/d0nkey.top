defmodule BackendWeb.DeckOnlyLive do
  @moduledoc false
  use BackendWeb, :surface_live_view_no_layout

  alias Components.Decklist
  alias Backend.Hearthstone.Deck
  alias Backend.DeckInteractionTracker, as: Tracker

  data(deckcode, :string)
  data(user, :any)

  def mount(_params, session = %{"code" => code}, socket) do
    {:ok, socket |> assign(deckcode: code) |> assign_defaults(session) |> put_user_in_context()}
  end

  def render(assigns) do
    deck = Deck.decode!(assigns[:deckcode])

    ~F"""
      <Decklist deck={deck} />
    """
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
