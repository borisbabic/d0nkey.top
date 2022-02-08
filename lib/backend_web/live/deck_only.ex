defmodule BackendWeb.DeckOnlyLive do
  @moduledoc false
  import BackendWeb.LiveHelpers
  alias Components.Decklist
  alias Backend.Hearthstone.Deck
  use BackendWeb, :surface_live_view_no_layout
  data(deckcode, :string)
  data(user, :any)

  def mount(_params, session = %{"code" => code}, socket) do
    {:ok, socket |> assign(deckcode: code) |> assign_defaults(session)}
  end

  def render(assigns) do
    deck = Deck.decode!(assigns[:deckcode])

    ~F"""
    <Context put={user: @user} >
      <Decklist deck={deck} />
    </Context>
    """
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
