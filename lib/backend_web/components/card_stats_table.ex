defmodule Components.CardStatsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.DecklistCard
  alias Components.LivePatchDropdown
  alias Components.DecksExplorer
  alias Hearthstone.DeckTracker
  alias Backend.Hearthstone.Deck

  prop(card_stats, :list)
  prop(filters, :map, default: %{})
  prop(criteria, :any, default: %{})
  prop(live_view, :module, required: true)
  prop(path_params, :any, default: nil)

  def render(assigns) do
    ~F"""
      <div>
        <LivePatchDropdown
          options={DeckTracker.period_filters(:public)}
          title={"Period"}
          param={"period"}
          url_params={Map.merge(@criteria, @filters)}
          path_params={@path_params}
          selected_params={@criteria}
          live_view={@live_view} />
        <LivePatchDropdown
          options={[0, 50, 100, 200, 400, 800, 1600, 3200, 6400]}
          title={"Min Mull Count"}
          param={"min_mull_count"}
          selected_as_title={false}
          url_params={Map.merge(@criteria, @filters)}
          path_params={@path_params}
          selected_params={@filters}
          live_view={@live_view} />
        <LivePatchDropdown
          options={[0, 50, 100, 200, 400, 800, 1600, 3200, 6400]}
          title={"Min Drawn Count"}
          param={"min_drawn_count"}
          selected_as_title={false}
          url_params={Map.merge(@criteria, @filters)}
          path_params={@path_params}
          selected_params={@filters}
          live_view={@live_view} />
        <LivePatchDropdown
          options={[{"yes", "Show Counts"}, {"no", "Don't Show Counts"}]}
          title={"Show Counts"}
          param={"show_counts"}
          selected_as_title={true}
          url_params={Map.merge(@criteria, @filters)}
          path_params={@path_params}
          selected_params={@filters}
          live_view={@live_view} />
        <LivePatchDropdown
          options={DecksExplorer.rank_options()}
          title={"Rank"}
          param={"rank"}
          url_params={Map.merge(@criteria, @filters)}
          path_params={@path_params}
          selected_params={@criteria}
          live_view={@live_view} />

        <LivePatchDropdown
          options={DecksExplorer.class_options("Any Class", "VS ")}
          title={"Opponent's Class"}
          param={"opponent_class"}
          url_params={Map.merge(@criteria, @filters)}
          path_params={@path_params}
          selected_params={@criteria}
          live_view={@live_view} />
        <table class="table is-fullwidth is-striped is-narrow">
          <thead>
            <th>
              <a :on-click="change_sort" phx-value-sort_by={"card"} phx-value-sort_direction={sort_direction(@filters, "card")}>
                {add_arrow("Card", "card", @filters)}
              </a>
            </th>

              <th>
              <a :on-click="change_sort" phx-value-sort_by={"mull_impact"} phx-value-sort_direction={sort_direction(@filters, "mull_impact")}>
                {add_arrow("Mulligan Impact", "mull_impact", @filters, true)}
              </a>
            </th>
              <th :if={show_counts(@filters)}>
              <a :on-click="change_sort" phx-value-sort_by={"mull_count"} phx-value-sort_direction={sort_direction(@filters, "mull_count")}>
                {add_arrow("Mulligan Count", "mull_count", @filters)}
              </a> 
              </th>

              <th>
              <a :on-click="change_sort" phx-value-sort_by={"kept_percent"} phx-value-sort_direction={sort_direction(@filters, "kept_percent")}>
                {add_arrow("Kept Percent", "kept_percent", @filters)}
              </a>
            </th>

              <th>
              <a :on-click="change_sort" phx-value-sort_by={"kept_impact"} phx-value-sort_direction={sort_direction(@filters, "kept_impact")}>
                {add_arrow("Kept Impact", "kept_impact", @filters)}
              </a>
            </th>

              <th :if={show_counts(@filters)}>
              <a :on-click="change_sort" phx-value-sort_by={"kept_count"} phx-value-sort_direction={sort_direction(@filters, "kept_count")}>
                {add_arrow("Kept Count", "kept_count", @filters)}
              </a> 
              </th>

              <th>
              <a :on-click="change_sort" phx-value-sort_by={"drawn_impact"} phx-value-sort_direction={sort_direction(@filters, "drawn_impact")}>
                {add_arrow("Drawn Impact", "drawn_impact", @filters)}
              </a>
            </th>
              <th :if={show_counts(@filters)}>
              <a :on-click="change_sort" phx-value-sort_by={"drawn_count"} phx-value-sort_direction={sort_direction(@filters, "drawn_count")}>
                {add_arrow("Drawn Count", "drawn_count", @filters)}
              </a>
            </th>

          </thead>
          <tbody>
            <tr :for={cs <- @card_stats |> map_filter(@filters) |> sort(@filters) |> filter_same_deck(@filters)}>
              <td>

              <div class="decklist_card_container">
                <DecklistCard deck_class="NEUTRAL" card={cs.card} count={count(cs, @filters)}/>
              </div>

                </td>
              <td>{to_percent(cs.mull_impact)}</td>
              <td :if={show_counts(@filters)}>{cs.mull_count}</td>

              <td>{to_percent(cs.kept_percent)}</td>

              <td>{to_percent(cs.kept_impact)}</td>
              <td :if={show_counts(@filters)}>{cs.kept_count}</td>

              <td>{to_percent(cs.drawn_impact)}</td>
              <td :if={show_counts(@filters)}>{cs.drawn_count}</td>
            </tr>
          </tbody>
        </table>
      </div>
    """
  end

  def add_arrow(base, column_sort_key, filters, default \\ false)

  def add_arrow(base, column_sort_key, %{"sort_by" => sort_key} = f, _default)
      when sort_key == column_sort_key do
    arrow =
      case get_direction(f) do
        :asc -> "↑"
        _ -> "↓"
      end

    "#{base}#{arrow}"
  end

  def add_arrow(base, column_sort_key, _, true),
    do: add_arrow(base, column_sort_key, %{"sort_by" => column_sort_key})

  def add_arrow(base, _, _, _), do: base

  defp sort_direction(%{"sort_by" => existing, "sort_direction" => s}, new) when new == existing,
    do: flip_direction(s)

  defp sort_direction(_, _), do: "desc"
  defp flip_direction(dir) when dir in [:desc, "desc"], do: "asc"
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
  def default_count_minimum(_), do: 200

  defp filter_same_deck(stats, filters) do
    with id when not is_nil(id) <- deck_id(filters),
         deck = %Deck{} <- Backend.Hearthstone.get_deck(id) do
      filter_cards(stats, Deck.unique_cards_with_sideboards(deck))
    else
      _ -> stats
    end
  end

  defp filter_cards(stats, cards) do
    canonical = Enum.map(cards, &Backend.Hearthstone.canonical_id/1)

    stats
    |> Enum.filter(&(&1.card_id && Backend.Hearthstone.canonical_id(&1.card_id) in canonical))
  end

  defp deck_id(%{"deck_id" => d}), do: d
  defp deck_id(%{"player_deck_id" => d}), do: d
  defp deck_id(_), do: nil

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
      "kept_percent" -> & &1.kept_percent
      "kept_impact" -> & &1.kept_impact
      "kept_count" -> & &1.kept_count
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
      "show_counts",
      "player_deck_id",
      "deck_id",
      "sort_by",
      "sort_direction"
    ])
    |> DecksExplorer.parse_int(["min_mull_count", "min_drawn_count", "min_count"])
  end

  def default_criteria() do
    %{
      "period" => DecksExplorer.default_period()
    }
  end

  def default_filters() do
    %{
      "show_counts" => "no"
    }
  end

  def with_default_filters(filters) do
    Map.merge(default_filters(), filters)
  end

  def handle_event(
        "change_sort",
        sort,
        %{
          assigns: %{
            filters: old_filters,
            criteria: criteria,
            path_params: path_params,
            live_view: lv
          }
        } = socket
      ) do
    new_filters = Map.merge(old_filters, sort)

    {:noreply,
     socket
     |> push_patch(
       to:
         LivePatchDropdown.link(
           BackendWeb.Endpoint,
           lv,
           @path_params,
           Map.merge(criteria, new_filters)
         )
     )}
  end

  def show_counts(filters) do
    show_counts =
      filters
      |> with_default_filters()
      |> Map.get("show_counts", "no")

    show_counts != "no"
  end
end
