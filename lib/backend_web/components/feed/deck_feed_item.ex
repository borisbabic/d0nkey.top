defmodule Components.Feed.DeckFeedItem do
  @moduledoc false
  use Surface.Component
  alias Components.Decklist
  alias Components.DeckCard
  alias Components.DeckStreamingInfo
  prop(item, :map, required: true)

  def render(%{item: %{value: _deck_id}} = assigns) do
    ~F"""
    <span>
    <DeckCard :if={deck = deck(@item.value)} after_deck_class={"tw-flex tw-flex-wrap tw-items-center tw-gap-1.5 tw-p-1"}>
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
