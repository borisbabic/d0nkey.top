defmodule Components.CardStatsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.DecklistCard

  prop(card_stats, :list)
  prop(limit, :integer, default: 40)
  prop(filters, :map, default: %{})
  prop(live_view, :module, required: true)

  def render(assigns) do
    ~F"""
      <div>
        <table class="table is-fullwidth is-striped">
          <thead>
            <th>
              <a :on-click="change_sort" phx-value-sort_by={"card"} phx-value-sort_direction={sort_direction(@filters, "card")}>
                {add_arrow("Card", "card", @filters)}
              </a>
            </th>
              <th>
              <a :on-click="change_sort" phx-value-sort_by={"mull_impact"} phx-value-sort_direction={sort_direction(@filters, "mull_impact")}>
                {add_arrow("Mulligan Impact", "mull_impact", @filters)}
              </a>
            </th>
              <th>
              <a :on-click="change_sort" phx-value-sort_by={"mull_count"} phx-value-sort_direction={sort_direction(@filters, "mull_count")}>
                {add_arrow("Mulligan Count", "mull_count", @filters)}
              </a> 
            </th>
              <th>
              <a :on-click="change_sort" phx-value-sort_by={"drawn_impact"} phx-value-sort_direction={sort_direction(@filters, "drawn_impact")}>
                {add_arrow("Drawn Impact", "drawn_impact", @filters)}
              </a>
            </th>
              <th>
              <a :on-click="change_sort" phx-value-sort_by={"drawn_count"} phx-value-sort_direction={sort_direction(@filters, "drawn_count")}>
                {add_arrow("Drawn Count", "drawn_count", @filters)}
              </a>
            </th>
          </thead>
          <tbody>
            <tr :for={cs <- @card_stats |> map_filter(@filters) |> sort(@filters)}>
              <td>

              <div class="decklist_card_container">
                <DecklistCard deck_class="NEUTRAL" card={cs.card} count={count(cs, @filters)}/>
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

  def add_arrow(base, column_sort_key, %{"sort_by" => sort_key} = f)
      when sort_key == column_sort_key do
    arrow =
      case get_direction(f) do
        :asc -> "↑"
        _ -> "↓"
      end

    "#{base}#{arrow}"
  end

  def add_arrow(base, _, _), do: base

  defp sort_direction(%{"sort_by" => existing, "sort_direction" => s}, new) when new == existing,
    do: flip_direction(s)

  defp sort_direction(_, _), do: "desc"
  defp flip_direction("desc"), do: "asc"
  defp flip_direction(_), do: "desc"

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

  def map_filter(stats, filters) do
    default_min = default_count_minimum(filters)
    mull_min = Map.get(filters, "min_mull_count", default_min)
    drawn_min = Map.get(filters, "min_drawn_count", default_min)

    for %{mull_count: mull, drawn_count: drawn, card_id: card_id} = cs <- stats,
        mull > mull_min,
        drawn > drawn_min,
        card = card(card_id),
        card != nil do
      Map.put(cs, :card, card)
    end
  end

  def card(card_id), do: Backend.Hearthstone.CardBag.card(card_id)

  def card_name(card_id) do
    card(card_id)
    |> Map.get(:name)
  end

  def to_percent(int) when is_integer(int), do: int / 1
  def to_percent(num), do: "#{Float.round(num * 100, 2)}%"

  def sort(stats, %{"sort_by" => "card"} = filters) do
    direction = get_direction(filters)
    Backend.Hearthstone.sort_cards(stats, &extract_card/1, direction)
  end

  def sort(stats, filters) do
    sorter = Map.get(filters, "sort_by", "mull_impact") |> get_sorter()
    direction = get_direction(filters)
    Enum.sort_by(stats, sorter, direction)
  end

  defp get_direction(%{} = filters) do
    Map.get(filters, "sort_direction", "desc") |> get_direction()
  end

  defp get_direction("asc"), do: :asc
  defp get_direction(_), do: :desc

  defp get_sorter(by) do
    case to_string(by) do
      "card" -> & &1.card.name
      "mull_count" -> & &1.mull_count
      "drawn_impact" -> & &1.drawn_impact
      "drawn_count" -> & &1.drawn_count
      _ -> & &1.mull_impact
    end
  end

  defp extract_card(%{card: card}), do: card

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

  def handle_event("change_sort", sort, %{assigns: %{filters: old_filters}} = socket) do
    new_filters = Map.merge(old_filters, sort)
    {:noreply, socket |> assign(filters: new_filters)}
  end
end
