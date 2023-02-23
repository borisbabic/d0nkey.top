defmodule Components.DustBar do
  @moduledoc "Contains the bar with a decks dust total"
  use Surface.Component
  alias Backend.Hearthstone.Deck

  prop(deck, :map, required: true)
  prop(class, :css_class, required: true)

  def render(assigns) do
    ~F"""
    <div class={@class, "basic-black-text", "decklist-info", "dust-bar"}>
      <div class="dust-bar-inner">
        {Deck.cost(@deck)}

        <span class="icon">
          <img class="image" src="/images/dust_icon.webp" />
        </span>
      </div>
    </div>
    """
  end
end
