defmodule BackendWeb.DeckOnlyLive do
  @moduledoc false
  use BackendWeb, :surface_live_view_no_layout

  alias Components.Decklist
  alias Backend.Hearthstone.Deck
  alias Backend.DeckInteractionTracker, as: Tracker

  data(deck, :any)
  data(user, :any)

  def mount(_params, session = %{"code" => code}, socket) do
    {:ok,
     socket
     |> assign(deck: Deck.decode!(code))
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <Decklist deck={@deck} />
    """
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
