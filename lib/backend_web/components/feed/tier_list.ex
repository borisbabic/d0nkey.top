defmodule Components.Feed.TierList do
  @moduledoc "Tier list for the front page"
  use BackendWeb, :surface_component

  alias Components.WinrateTag

  def render(assigns) do
    ~F"""
    <div class="card" style="width: calc(2*(var(--decklist-width) - 15px));">
      <.table id="feed_tier_list_table">
        <.thead>
          <.trh>
            <.th>Archetype</.th>
            <.th>Winrate</.th>
          </.trh>
        </.thead>
        <.tbody>
          <.trb :for={stat <- get_tier_list()}>
            <.td>{stat.archetype}</.td>
            <.td><WinrateTag winrate={stat.winrate} /></.td>
          </.trb>
        </.tbody>

      </.table>
    </div>

    """
  end

  defp get_tier_list do
    Hearthstone.DeckTracker.archetype_stats([
      {"period", Components.Filter.PeriodDropdown.default(:public, 2)},
      :diamond_to_legend,
      {"format", 2}
    ])
    |> Enum.sort_by(& &1.total, :desc)
    |> Enum.take(25)
    |> Enum.sort_by(& &1.winrate, :desc)
  end
end
