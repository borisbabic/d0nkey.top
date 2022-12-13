defmodule Components.ClassStatsTable do
  @moduledoc false
  use Surface.Component

  alias Components.WinrateTag

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
          <tr :for={stat <- filter_weird_classes(@stats) |> order_by_class()}>
            <td><span class={"tag","player-name", extract_class(stat) |> String.downcase()}><span class={"basic-black-text"}>{class_name(stat)}</span></span></td>
            <td><WinrateTag winrate={stat.winrate} /></td>
            <td>{stat.total}</td>
          </tr>
          <tr :if={total_stats = Hearthstone.DeckTracker.sum_stats(@stats)}>
            <td>Total</td>
            <td><WinrateTag winrate={total_stats.winrate} /></td>
            <td>{total_stats.total}</td>
          </tr>
        </tbody>
      </table>
    """
  end

  def filter_weird_classes(stats) do
    Enum.filter(stats, fn stat ->
      class = extract_class(stat)
      class in Backend.Hearthstone.Deck.classes()
    end)
  end

  def order_by_class(stats) do
    Enum.sort_by(stats, &extract_class/1, :asc)
  end

  def class_name(stat) do
    stat
    |> extract_class()
    |> Backend.Hearthstone.Deck.class_name()
  end

  def extract_class(%{player_class: class}) when is_binary(class), do: class
  def extract_class(%{opponent_class: class}) when is_binary(class), do: class
  def extract_class(%{class: class}) when is_binary(class), do: class
  def extract_class(_), do: nil
end
