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
     |> assign_defaults(p)}
  end

  def render(assigns) do
    deck = Deck.decode!(assigns[:deckcode])

    ~F"""
    <Context put={user: @user} >
      <Decklist deck={deck} show_cards={@show_cards} name={@name}>
        <#template slot="right_button">
          <span phx-click="show_cards" class="is-clickable" >
            <span class="icon">
              <i :if={!@show_cards} class="fas fa-eye"></i>
              <i :if={@show_cards} class="fas fa-eye-slash"></i>
            </span>
          </span>
        </#template>
      </Decklist>
    </Context>
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
