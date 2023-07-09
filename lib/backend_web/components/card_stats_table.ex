defmodule Components.CardStatsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.DecklistCard

  prop(card_stats, :list)
  prop(limit, :integer, default: 40)
  prop(filters, :map, default: %{})

  def render(assigns) do
    ~F"""
      <div>
        <table class="table is-fullwidth is-striped">
          <thead>
            <th>Card Name</th>
            <th>Mulligan Impact</th>
            <th>Mulligan Count</th> 
            <th>Drawn Impact</th>
            <th>Drawn Count</th>
          </thead>
          <tbody>
            <tr :for={cs <- @card_stats |> filter(@filters) |> sort(@filters)}>
              <td>

              <div class="decklist_card_container">
                <DecklistCard deck_class="NEUTRAL" card={card(cs.card_id)} count={count(cs, @filters)}/>
              </div>

                </td>
              <td>{to_percent(cs.mull_impact)}</td>
              <td>{cs.mull_count}</td>
              <td>{to_percent(cs.drawn_impact)}</td>
              <td>{cs.drawn_count}</td>
            </tr>
          </tbody>
        </table>
      </div>
    """
  end

  def count(%{mull_impact: mi, drawn_impact: di}, filters) do
    num = if Map.get(filters, "sort_by") in [nil, "mull_impact", "mull_count"], do: mi, else: di

    cond do
      num > 0 -> "↑"
      num < 0 -> "↓"
      true -> ""
    end
  end

  def default_count_minimum(%{"deck_id" => _}), do: 0
  def default_count_minimum(%{"player_deck_id" => _}), do: 0

  def default_count_minimum(%{"min_count" => min_count}), do: min_count
  def default_count_minimum(_), do: 50

  def filter(stats, filters) do
    default_min = default_count_minimum(filters)
    mull_min = Map.get(filters, "min_mull_count", default_min)
    drawn_min = Map.get(filters, "min_drawn_count", default_min)

    Enum.filter(stats, fn %{mull_count: mull, drawn_count: dc} ->
      mull > mull_min and dc > drawn_min
    end)
  end

  def card(card_id), do: Backend.Hearthstone.CardBag.card(card_id)

  def card_name(card_id) do
    card(card_id)
    |> Map.get(:name)
  end

  def to_percent(int) when is_integer(int), do: Float.from()
  def to_percent(num), do: "#{Float.round(num * 100, 2)}%"

  def sort(stats, filters) do
    sorter = Map.get(filters, "sort_by", "mull_impact") |> get_sorter()
    direction = Map.get(filters, "sort_direction", "desc") |> get_direction()
    Enum.sort_by(stats, sorter, direction)
  end

  defp get_direction("asc"), do: :asc
  defp get_direction(_), do: :desc

  defp get_sorter(by) do
    case to_string(by) do
      "card_name" -> &card_name(&1.card_id)
      "mull_count" -> & &1.mull_count
      "drawn_impact" -> & &1.drawn_impact
      "drawn_count" -> & &1.count
      _ -> & &1.mull_impact
    end
  end

  def filter_relevant(filters) do
    filters
    |> Map.take([
      "min_mull_count",
      "min_drawn_count",
      "min_count",
      "player_deck_id",
      "deck_id",
      "sort_by",
      "direction"
    ])
    |> Components.DecksExplorer.parse_int(["min_mull_count", "min_drawn_count", "min_count"])
  end
end
