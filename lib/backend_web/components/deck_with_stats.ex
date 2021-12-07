defmodule Components.DeckWithStats do
  @moduledoc false
  use Surface.Component
  alias Components.DeckCard
  alias Components.Decklist
  alias Components.DeckStats
  alias Components.StreamingDeckNow
  prop(deck_with_stats, :map, required: true)
  prop(show_streaming_now, :boolean, default: true)
  def render(assigns = %{deck_with_stats: deck_with_stats}) do
    deck = deck(deck_with_stats)
    {total, winrate} = stats(deck_with_stats)
    ~F"""
      <DeckCard>
        <Decklist deck={deck} archetype_as_name={true} />
        <:after_deck>
          <DeckStats total={total} winrate={winrate} />
          <StreamingDeckNow :if={@show_streaming_now && deck && deck.id} deck={deck} />
        </:after_deck>
      </DeckCard>
    """
  end

  defp stats(%{total: total, winrate: winrate}), do: {total, winrate}
  # defp stats(%{deck_id: deck_id}), do: stats(deck_id)
  # defp stats(%{deck: %{id: id}}), do: stats(id)
  # defp stats(deck_id) when is_integer(deck_id) do
  # end
  defp deck(%{deck: deck}), do: deck
  defp deck(%{deck_id: deck_id}), do: Backend.Hearthstone.deck(deck_id)
end
