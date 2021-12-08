defmodule Components.ClassStatsTable do
  @moduledoc false
  use Surface.Component

  prop(stats, :list, required: true)
  def render(assigns) do

    ~F"""
      <table class="table is-fullwidth is-striped">
        <thead>
          <tr>
            <th>Class</th>
            <th>Winrate</th>
            <th>Total Games</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={stat <- @stats}>
            <td><span class={"tag","player-name", extract_class(stat) |> String.downcase()}><span class={"basic-black-text"}>{class_name(stat)}</span></span></td>
            <td><span class="tag" style={Components.DeckStats.winrate_style(stat.winrate)}><span class={"basic-black-text"}>{Float.round(stat.winrate * 100, 1)}</span></span></td>
            <td>{stat.total}</td>
          </tr>
          <tr :if={total_stats = Hearthstone.DeckTracker.sum_stats(@stats)}>
            <td>Total</td>
            <td><span class="tag" style={Components.DeckStats.winrate_style(total_stats.winrate)}><span class={"basic-black-text"}>{Float.round(total_stats.winrate * 100, 1)}</span></span></td>
            <td>{total_stats.total}</td>
          </tr>
        </tbody>
      </table>
    """
  end

  def class_name(stat) do
    stat
    |> extract_class()
    |> Backend.Hearthstone.Deck.class_name()
  end
  def extract_class(%{player_class: class}), do: class
  def extract_class(%{opponent_class: class}), do: class
  def extract_class(%{class: class}), do: class

end
