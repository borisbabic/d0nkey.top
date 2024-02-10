defmodule BackendWeb.ExpandableDeckLive do
  @moduledoc false
  use BackendWeb, :surface_live_view_no_layout
  alias Components.Decklist
  alias Backend.Hearthstone.Deck
  alias Backend.DeckInteractionTracker, as: Tracker
  data(deckcode, :string)
  data(name, :string)
  data(show_cards, :boolean)

  def mount(_params, p = %{"code" => code}, socket) do
    {:ok,
     socket
     |> assign(deckcode: code, show_cards: !!p["show_cards"], name: p["name"])
     |> assign_defaults(p)
     |> put_user_in_context()}
  end

  def render(assigns) do
    deck = Deck.decode!(assigns[:deckcode])

    ~F"""
      <Decklist deck={deck} show_cards={@show_cards} name={@name}>
        <:right_button>
          <span phx-click="show_cards" class="is-clickable" >
            <HeroIcons.eye size="small" :if={!@show_cards}/>
            <HeroIcons.eye_slash size="small" :if={@show_cards}/>
          </span>
        </:right_button>
      </Decklist>
    """
  end

  def handle_event("show_cards", _, socket = %{assigns: %{show_cards: old, deckcode: code}}) do
    if !old, do: Tracker.inc_expanded(code)

    {
      :noreply,
      socket
      |> assign(show_cards: !old)
    }
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
