defmodule Components.DeckWinrate do
  @moduledoc "Shows deck winrate"
  use Surface.Component
  alias Hearthstone.DeckTracker

  prop(deck_id, :integer, required: true)
  prop(period, :atom, default: :past_week)
  prop(ranks, :atom, default: :diamond_to_legend)
  prop(min_sample_size, :integer, default: 100)

  def render(assigns) do
    ~F"""
      <div class="tag column" :if={s = winrate(@deck_id, @period, @ranks, @min_sample_size)}>
        Winrate: {Float.round((s.wins/ (s.losses + s.wins)) * 100, 1)}% ({s.wins} - {s.losses})
      </div>
    """
  end

  def winrate(deck_id, period, ranks, min_sample_size) do
    DeckTracker.deck_stats(deck_id, [period, ranks])
    |> case do
      [stats = %{wins: w, losses: l}] when w + l >= min_sample_size -> stats
      _ -> nil
    end
  end
end
