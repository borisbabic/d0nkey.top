defmodule Components.ClassStatsTable do
  @moduledoc false
  use BackendWeb, :surface_component

  alias Components.WinrateTag
  import Components.ArchetypeStatsTable, only: [archetype_cell: 1]

  prop(stats, :list, required: true)
  prop(show_class_percent?, :boolean, default: true)
  prop(show_win_loss?, :boolean, default: false)
  data(total_stats, :any)
  data(filtered_stats, :list)

  def render(%{filtered_stats: _, total_stats: _} = assigns) do
    ~F"""
      <.table id="class_stats_table">
        <.thead>
          <.trh>
            <.th>Class</.th>
            <.th>Winrate</.th>
            <.th>Total Games</.th>
          </.trh>
        </.thead>
        <.tbody>
          <.trb :for={stat <- @filtered_stats}>
            <.archetype_cell archetype={class_name(stat)} />
            <.td>
              <WinrateTag winrate={stat.winrate} win_loss={win_loss(stat, @show_win_loss?)}/>
            </.td>
            <.td>{total(stat, @total_stats, @show_class_percent?)}</.td>
          </.trb>
          <.trb :if={@total_stats}>
            <.td>Total</.td>
            <.td>
              <WinrateTag winrate={@total_stats.winrate} win_loss={win_loss(@total_stats, @show_win_loss?) } />
            </.td>
            <.td>{@total_stats.total}</.td>
          </.trb>
        </.tbody>
      </.table>
    """
  end

  def render(%{stats: stats} = assigns) do
    filtered_stats = filter_weird_classes(stats) |> order_by_class()
    total_stats = Hearthstone.DeckTracker.sum_stats(filtered_stats)

    assigns
    |> assign(filtered_stats: filtered_stats, total_stats: total_stats)
    |> render()
  end

  defp win_loss(%{wins: wins, losses: losses}, true), do: %{wins: wins, losses: losses}
  defp win_loss(_stats, _show_win_losss?), do: nil

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
