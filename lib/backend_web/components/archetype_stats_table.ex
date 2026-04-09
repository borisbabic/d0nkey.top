defmodule Components.ArchetypeStatsTable do
  @moduledoc false
  use BackendWeb, :surface_component

  alias Components.WinrateTag
  alias Backend.Hearthstone.Deck
  import Components.MatchupsTable, only: [archetype_sort_key: 1]

  prop(stats, :list, required: true)
  prop(show_class_percent?, :boolean, default: true)
  prop(show_win_loss?, :boolean, default: false)
  prop(minimum_games, :number, default: 1)
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
            <.archetype_cell archetype={archetype(stat)} />
            <td>
              <WinrateTag winrate={stat.winrate} win_loss={win_loss(stat, @show_win_loss?)}/>
            </td>
            <td>{total(stat, @total_stats, @show_class_percent?)}</td>
          </tr>
          <tr :if={@total_stats}>
            <td>Total</td>
            <td>
              <WinrateTag winrate={@total_stats.winrate} win_loss={win_loss(@total_stats, @show_win_loss?) } />
            </td>
            <td>{@total_stats.total}</td>
          </tr>
        </tbody>
      </table>
    """
  end

  attr :archetype, :string
  attr :params, :map, default: %{}

  def archetype_cell(assigns) do
    ~H"""
    <td class={"decklist-info #{Deck.extract_class(@archetype) |> String.downcase()}"}>
      <a class="basic-black-text deck-title" href={~p"/archetype/#{@archetype}?#{add_games_filters(@params)}"}>
        {@archetype}
      </a>
    </td>
    """
  end

  def render(%{stats: stats, minimum_games: min_games} = assigns) do
    filtered_stats =
      stats |> Enum.filter(&(&1.wins + &1.losses > min_games)) |> order_by_archetype()

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

  def order_by_archetype(stats) do
    Enum.sort_by(stats, &(archetype(&1) |> archetype_sort_key()), :asc)
  end

  defp archetype(%{opponent_archetype: a}), do: a
  defp archetype(%{player_archetype: a}), do: a
  defp archetype(%{archetype: a}), do: a
  defp archetype(_), do: nil
end
