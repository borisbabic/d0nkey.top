defmodule Components.ExpandableDecklist do
  @moduledoc false
  alias Components.Decklist
  use Surface.LiveComponent

  prop(deck, :map, required: true)
  prop(name, :string, default: nil)
  prop(show_cards, :boolean, default: false)
  prop(on_card_click, :event, default: nil)
  prop(toggle_cards, :event, default: "toggle_cards")

  def render(assigns) do

    ~F"""
      <div>
      <Decklist deck={@deck} show_cards={@show_cards} name={name(@name, @deck)} on_card_click={@on_card_click}>
        <:right_button>
          <span :on-click={@toggle_cards} class="is-clickable" >
            <HeroIcons.eye size="small" :if={!@show_cards}/>
            <HeroIcons.eye_slash size="small" :if={@show_cards}/>
          </span>
        </:right_button>
      </Decklist>
      </div>
    """
  end

  def name(name, deck) do
    with nil <- name do
      Backend.Hearthstone.Deck.name(deck)
    end
  end
  def handle_event("toggle_cards", _, socket) do
    {:noreply, socket |> assign(show_cards: !socket.assigns.show_cards)}
  end
end
