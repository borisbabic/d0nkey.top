defmodule Components.DustBar do
  @moduledoc "Contains the bar with a decks dust total"
  use Surface.Component
  alias Backend.Hearthstone.Deck
  alias Components.DeckListingModal

  prop(deck, :map, required: true)
  prop(class, :css_class, required: true)
  prop(user, :map, from_context: :user)
  prop(card_map, :map, default: %{})

  def render(assigns) do
    ~F"""
      <div class={@class, "basic-black-text", "decklist-info", "dust-bar"}>
        <div class="dust-bar-inner">
          <DeckListingModal source="hsguru" button_class="icon button" :if={@user} id={Ecto.UUID.generate() <> Deck.deckcode(@deck)} deck={@deck} button_title={"+"} user={@user}/>
          {Deck.cost(@deck, @card_map)}
          <span class="icon">
            <img class="image" src="/images/dust_icon.webp" />
          </span>
        </div>
      </div>
    """
  end
end
