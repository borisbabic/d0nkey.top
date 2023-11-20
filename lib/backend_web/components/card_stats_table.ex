defmodule Components.CardStatsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.DecklistCard
  alias Components.LivePatchDropdown
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.FormatDropdown
  alias Components.DecksExplorer
  alias Hearthstone.DeckTracker
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone

  prop(card_stats, :list)
  prop(filters, :map, default: %{})
  prop(criteria, :any, default: %{})
  prop(filter_context, :atom, default: :public)
  prop(live_view, :module, required: true)
  prop(path_params, :any, default: nil)
  prop(user, :map, from_context: :user)

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        Map.merge(assigns.criteria, assigns.filters),
        assigns.path_params,
        Map.merge(assigns.criteria, assigns.filters)
      )
    }
  end

  def render(assigns) do
    ~F"""
      <div>
        <PeriodDropdown id="period_dropdown" filter_context={@filter_context}/>
        <FormatDropdown id="format_dropdown" filter_context={@filter_context} />
        <LivePatchDropdown
          options={[0, 25, 50, 100, 200, 400, 800, 1600, 3200, 6400]}
          title={"Min Mull Count"}
          param={"min_mull_count"}
          normalizer={&Util.to_int_or_orig/1}
          selected_as_title={false}/>
        <LivePatchDropdown
          options={[0, 25, 50, 100, 200, 400, 800, 1600, 3200, 6400]}
          title={"Min Drawn Count"}
          param={"min_drawn_count"}
          normalizer={&Util.to_int_or_orig/1}
          selected_as_title={false} />
        <LivePatchDropdown
          options={[{"yes", "Show Counts"}, {"no", "Don't Show Counts"}]}
          title={"Show Counts"}
          param={"show_counts"}
          selected_as_title={true} />
        <RankDropdown id="rank_dropdown" fitler_context={@filter_context}/>

        <LivePatchDropdown
          options={DecksExplorer.class_options("Any Class", "VS ")}
          title={"Opponent's Class"}
          param={"opponent_class"} />
        <table class="table is-fullwidth is-striped is-gapless">
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
              <a :on-click="change_sort" phx-value-sort_by={"drawn_impact"} phx-value-sort_direction={sort_direction(@filters, "drawn_impact")}>
                {add_arrow("Drawn Impact", "drawn_impact", @filters)}
              </a>
            </th>
              <th :if={show_counts(@filters)}>
              <a :on-click="change_sort" phx-value-sort_by={"drawn_count"} phx-value-sort_direction={sort_direction(@filters, "drawn_count")}>
                {add_arrow("Drawn Count", "drawn_count", @filters)}
              </a>
            </th>

              <th class="is-hidden-mobile">
              <a :on-click="change_sort" phx-value-sort_by={"kept_impact"} phx-value-sort_direction={sort_direction(@filters, "kept_impact")}>
                {add_arrow("Kept Impact", "kept_impact", @filters)}
              </a>
            </th>

              <th :if={show_counts(@filters)} class="is-hidden-mobile">
              <a :on-click="change_sort" phx-value-sort_by={"kept_count"} phx-value-sort_direction={sort_direction(@filters, "kept_count")}>
                {add_arrow("Kept Count", "kept_count", @filters)}
              </a>
              </th>

          </thead>
          <tbody>
            <tr :for={cs <- @card_stats |> map_filter(@filters) |> sort(@filters) |> filter_same_deck(@filters)}>
              <td>

              <div class="decklist_card_container">
                <DecklistCard deck_class="NEUTRAL" card={Util.get(cs, :card)} count={count(cs, @filters)} decklist_options={Backend.UserManager.User.decklist_options(@user)}/>
              </div>

                </td>
              <td>{to_percent(Util.get(cs, :mull_impact))}</td>
              <td :if={show_counts(@filters)}>{Util.get(cs, :mull_total) }</td>

              <td>{to_percent(Util.get(cs, :drawn_impact))}</td>
              <td :if={show_counts(@filters)}>{Util.get(cs, :drawn_total)}</td>

              <td class="is-hidden-mobile">{to_percent(Util.get(cs, :kept_impact))}</td>
              <td :if={show_counts(@filters)} class="is-hidden-mobile">{Util.get(cs, :kept_total)}</td>
            </tr>
          </tbody>
        </table>
      </div>
    """
  end

  def add_arrow(base, column_sort_key, filters, is_default \\ false) do
    arrow =
      case get_direction(filters) do
        :asc -> "↑"
        _ -> "↓"
      end

    from_filters = Map.get(filters, "sort_by")

    cond do
      from_filters == column_sort_key -> "#{base}#{arrow}"
      from_filters == nil and is_default -> "#{base}#{arrow}"
      true -> "#{base}"
    end
  end

  defp sort_direction(%{"sort_by" => existing, "sort_direction" => s}, new) when new == existing,
    do: flip_direction(s)

  defp sort_direction(_, _), do: "desc"
  defp flip_direction(dir) when dir in [:desc, "desc"], do: "asc"
  defp flip_direction(_), do: "desc"

  def count(cs, filters) do
    mi = Util.get(cs, :mull_impact)
    di = Util.get(cs, :drawn_impact)
    ki = Util.get(cs, :kept_impact)

    sort_filters = Map.get(filters, "sort_by", "mull_impact")

    num =
      cond do
        sort_filters =~ "drawn_" -> di
        sort_filters =~ "kept_" -> ki
        true -> mi
      end

    cond do
      num > 0 -> "↑"
      num < 0 -> "↓"
      true -> ""
    end
  end

  @default_min_mull_count 50
  @default_min_drawn_count 200
  def default_minimum_counts(%{"deck_id" => _}),
    do: %{"min_mull_count" => 0, "min_drawn_count" => 0}

  def default_minimum_counts(%{"player_deck_id" => _}),
    do: %{"min_mull_count" => 0, "min_drawn_count" => 0}

  def default_minimum_counts(%{"min_count" => min_count}),
    do: %{"min_mull_count" => 0, "min_drawn_count" => 0}

  def default_minimum_counts(_),
    do: %{
      "min_mull_count" => @default_min_mull_count,
      "min_drawn_count" => @default_min_drawn_count
    }

  defp filter_same_deck(stats, filters) do
    with id when not is_nil(id) <- deck_id(filters),
         deck = %Deck{} <- Hearthstone.get_deck(id) do
      filter_cards(stats, Deck.unique_cards_with_sideboards(deck))
    else
      _ -> stats
    end
  end

  defp filter_cards(stats, cards) do
    canonical = Enum.map(cards, &Hearthstone.canonical_id/1)

    stats
    |> Enum.filter(fn cs ->
      card_id = Util.get(cs, :card_id)
      card_id && Hearthstone.canonical_id(card_id) in canonical
    end)
  end

  defp deck_id(%{"deck_id" => d}), do: d
  defp deck_id(%{"player_deck_id" => d}), do: d
  defp deck_id(_), do: nil

  def map_filter(stats, filters) do
    %{"min_mull_count" => default_mull_min, "min_drawn_count" => default_drawn_min} =
      default_minimum_counts(filters)

    mull_min = Map.get(filters, "min_mull_count", default_mull_min)
    drawn_min = Map.get(filters, "min_drawn_count", default_drawn_min)

    Enum.flat_map(stats, fn cs ->
      mull = Util.get(cs, :mull_total)
      drawn = Util.get(cs, :drawn_total)
      card = card(Util.get(cs, :card_id))

      if mull > mull_min and drawn > drawn_min and card != nil do
        [Map.put(cs, :card, card)]
      else
        []
      end
    end)
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
      "card" -> &Util.get(&1.card, :name)
      "mull_count" -> &Util.get(&1, :mull_total)
      "drawn_impact" -> &Util.get(&1, :drawn_impact)
      "drawn_count" -> &Util.get(&1, :drawn_total)
      "kept_percent" -> &Util.get(&1, :kept_percent)
      "kept_impact" -> &Util.get(&1, :kept_impact)
      "kept_count" -> &Util.get(&1, :kept_total)
      _ -> &Util.get(&1, :mull_impact)
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

  def default_criteria(context) do
    %{
      "period" => PeriodDropdown.default(context),
      "rank" => RankDropdown.default(context),
      "opponent_class" => "any",
      "format" => FormatDropdown.default(context)
    }
  end

  def default_filters() do
    %{
      "show_counts" => "no"
    }
  end

  def with_default_filters(filters) do
    default_filters()
    |> Map.merge(default_minimum_counts(filters))
    |> Map.merge(filters)
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
