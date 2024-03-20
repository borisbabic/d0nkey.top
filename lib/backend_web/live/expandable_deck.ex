defmodule BackendWeb.ExpandableDeckLive do
  @moduledoc false
  use BackendWeb, :surface_live_view_no_layout
  alias Components.Decklist
  alias Backend.Hearthstone.Deck
  alias Backend.DeckInteractionTracker, as: Tracker
  data(deckcode, :string)
  data(name, :string)
  data(show_cards, :boolean)

  def mount(_params, p, socket) do
    deck = extract_deck(p)

    {:ok,
     socket
     |> assign(
       deck: deck,
       deckcode: Deck.deckcode(deck),
       show_cards: !!p["show_cards"],
       name: p["name"]
     )
     |> assign_defaults(p)
     |> put_user_in_context()}
  end

  def extract_deck(session = %{"deck" => %Deck{id: id} = deck}) when is_integer(id), do: deck

  def extract_deck(session = %{"deck" => %Deck{}}) do
    do_extract_deck(session, "deck")
  end

  def extract_deck(session = %{"deck_id" => id}) when is_integer(id) do
    do_extract_deck(session, "deck_id")
  end

  def extract_deck(session = %{"code" => c}) when is_binary(c) do
    do_extract_deck(session, "code")
  end

  def extract_deck(session = %{"deckcode" => c}) when is_binary(c) do
    do_extract_deck(session, "deckcode")
  end

  def extract_deck(_) do
    nil
  end

  def do_extract_deck(session, key) do
    case Backend.Hearthstone.deck(Map.get(session, key)) do
      %Deck{} = deck -> deck
      _ -> session |> Map.drop(key) |> extract_deck()
    end
  end

  def render(assigns) do
    ~F"""
      <Decklist deck={@deck} show_cards={@show_cards} name={@name}>
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
