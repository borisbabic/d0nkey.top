defmodule Components.Feed.DeckFeedItem do
  @moduledoc false
  use Surface.Component
  alias Components.Decklist
  alias Components.DeckCard
  alias Components.DeckStreamingInfo
  prop(item, :map, required: true)

  def render(assigns = %{item: %{value: deck_id}}) do
    ~F"""
    <span>
    <DeckCard :if={deck = deck(deck_id)}>
      <Decklist deck={deck} archetype_as_name={true} />
      <:after_deck>
        <DeckStreamingInfo deck_id={deck.id}/>
      </:after_deck>
    </DeckCard>
    </span>
    """
  end

  def deck(deck_id), do: Backend.Hearthstone.deck(deck_id)
end
