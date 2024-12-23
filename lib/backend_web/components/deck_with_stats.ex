defmodule Components.DeckWithStats do
  @moduledoc false
  use Surface.Component
  alias Components.DeckCard
  alias Components.Decklist
  alias Components.DeckStats
  alias Components.StreamingDeckNow
  prop(deck_with_stats, :map, required: true)
  prop(show_streaming_now, :boolean, default: true)
  prop(show_win_loss?, :boolean, default: false)
  data(deck, :boolean, default: true)
  data(total, :boolean, default: true)
  data(winrate, :boolean, default: true)
  data(win_loss, :any, default: nil)

  def render(%{deck: _, total: _total, winrate: _winrate} = assigns) do
    ~F"""
      <DeckCard>
        <Decklist deck={@deck} archetype_as_name={true} />
        <:after_deck>
          <DeckStats total={@total} winrate={@winrate} win_loss={@win_loss} />
          <StreamingDeckNow :if={@show_streaming_now && @deck && @deck.id} deck={@deck} />
        </:after_deck>
      </DeckCard>
    """
  end

  def render(assigns = %{deck_with_stats: deck_with_stats, show_win_loss?: show_wl?}) do
    deck = deck(deck_with_stats)

    win_loss =
      if show_wl? do
        %{wins: deck_with_stats.wins, losses: deck_with_stats.losses}
      end

    assigns
    |> assign(
      deck: deck,
      total: deck_with_stats.total,
      winrate: deck_with_stats.winrate,
      win_loss: win_loss
    )
    |> render()
  end

  # defp stats(%{deck_id: deck_id}), do: stats(deck_id)
  # defp stats(%{deck: %{id: id}}), do: stats(id)
  # defp stats(deck_id) when is_integer(deck_id) do
  # end
  defp deck(%{deck: deck}), do: deck
  defp deck(%{deck_id: deck_id}), do: Backend.Hearthstone.deck(deck_id)
end
