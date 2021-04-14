defmodule Components.DeckFeedItem do
  @moduledoc false
  use Surface.Component
  alias Components.Decklist
  alias Components.DeckStreamingInfo
  prop(item, :map, required: true)

  def render(assigns = %{item: %{value: deck_id}}) do
    deck = Backend.Hearthstone.deck(deck_id)

    name =
      with id when not is_nil(id) <- deck.hsreplay_archetype,
           %{name: name} <- Backend.HSReplay.get_archetype(id) do
        name
      else
        _ -> nil
      end

    ~H"""
    <div :if={{ deck }} class="card" style="width: calc(var(--decklist-width) + 15px);">
      <div class="card-image" style="margin:7.5px;">
        <Decklist deck={{ deck }} name={{ name }} />
      </div>
      <DeckStreamingInfo deck_id={{ deck.id }}/>
    </div>
    """
  end
end
