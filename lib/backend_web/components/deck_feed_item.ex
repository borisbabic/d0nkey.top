defmodule Components.DeckFeedItem do
  @moduledoc false
  use Surface.Component
  alias Components.Decklist
  alias Components.DeckCard
  alias Components.DeckStreamingInfo
  prop(item, :map, required: true)

  def render(assigns = %{item: %{value: deck_id}}) do
    deck = Backend.Hearthstone.deck(deck_id)

    ~F"""
    <DeckCard>
      <Decklist deck={deck} archetype_as_name={true} />
      <:after_deck>
        <DeckStreamingInfo deck_id={deck.id}/>
      </:after_deck>
    </DeckCard>
    """
  end
end
