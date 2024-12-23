defmodule Components.ClassStatsTable do
  @moduledoc false
  use Surface.Component

  alias Components.WinrateTag

  prop(stats, :list, required: true)
  prop(show_class_percent?, :boolean, default: true)
  prop(show_win_loss?, :boolean, default: false)
  data(total_stats, :any)
  data(filtered_stats, :list)

  def render(%{filtered_stats: _, total_stats: _} = assigns) do
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
          <tr :for={stat <- @filtered_stats}>
            <td><span class={"tag","player-name", extract_class(stat) |> String.downcase()}><span class={"basic-black-text"}>{class_name(stat)}</span></span></td>
            <td>
              <WinrateTag winrate={stat.winrate}/>
              <span :if={@show_win_loss?}>({stat.wins} - {stat.losses})</span>
            </td>
            <td>{total(stat, @total_stats, @show_class_percent?)}</td>
          </tr>
          <tr :if={@total_stats}>
            <td>Total</td>
            <td>
              <WinrateTag winrate={@total_stats.winrate} />
              <span :if={@show_win_loss?}>({@total_stats.wins} - {@total_stats.losses})</span>
            </td>
            <td>{@total_stats.total}</td>
          </tr>
        </tbody>
      </table>
    """
  end

  def render(%{stats: stats} = assigns) do
    filtered_stats = filter_weird_classes(stats) |> order_by_class()
    total_stats = Hearthstone.DeckTracker.sum_stats(filtered_stats)

    assigns
    |> assign(filtered_stats: filtered_stats, total_stats: total_stats)
    |> render()
  end

  defp total(%{total: class_total}, %{total: overall_total}, true) do
    percent = Util.percent(class_total, overall_total) |> Float.round(1)
    "#{class_total} (#{percent}%)"
  end

  defp total(%{total: class_total}, _total_stats, _), do: class_total
  defp total(_class_stats, _total_stats, _), do: nil

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
