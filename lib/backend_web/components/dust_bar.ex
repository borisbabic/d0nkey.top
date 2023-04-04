defmodule Components.DustBar do
  @moduledoc "Contains the bar with a decks dust total"
  use Surface.Component
  alias Backend.Hearthstone.Deck
  alias Components.DeckListingModal

  prop(deck, :map, required: true)
  prop(class, :css_class, required: true)

  def render(assigns) do
    ~F"""
      <Context get={user: user}>
        <div class={@class, "basic-black-text", "decklist-info", "dust-bar"}>
          <div class="dust-bar-inner">
            <DeckListingModal source="d0nkey.top" button_class="icon button" :if={user} id={Deck.deckcode(@deck)} deck={@deck} button_title={"+"} user={user}/>
            {Deck.cost(@deck)}
            <span class="icon">
              <img class="image" src="/images/dust_icon.webp" />
            </span>
          </div>
        </div>
      </Context>
    """
  end
end
