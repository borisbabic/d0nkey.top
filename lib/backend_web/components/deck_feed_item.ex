defmodule Components.DeckFeedItem do
  @moduledoc false
  use Surface.Component
  alias Components.Decklist
  alias Components.DeckStreamingInfo
  alias Components.DeckWinrate
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
      <div class="columns is-multiline is-mobile is-text-overflow" style="margin:7.5px">
        <DeckStreamingInfo deck_id={{ deck.id }}/>
      </div>
    </div>
    """
  end
end
