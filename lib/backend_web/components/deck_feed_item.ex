defmodule Components.DeckFeedItem do
  @moduledoc false
  use Surface.Component
  alias Components.Decklist
  alias Components.DeckStreamingInfo
  prop(item, :map, required: true)

  def render(assigns = %{item: %{value: deck_id}}) do
    deck = Backend.Hearthstone.deck(deck_id)

    ~H"""
    <div :if={{ deck }} class="card" style="width: 215px;">
      <div class="card-image" style="margin:7.5px;">
        <Decklist deck={{ deck }} />
      </div>
      <DeckStreamingInfo deck_id={{ deck.id }}/>
    </div>
    """
  end
end
