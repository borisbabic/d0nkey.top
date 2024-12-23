defmodule Components.CardStatsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.DecklistCard
  alias Components.LivePatchDropdown
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.FormatDropdown
  alias Components.Filter.ForceFreshDropdown
  alias Components.Filter.ClassDropdown
  alias Components.Filter.PlayableCardSelect
  alias Components.Filter.PlayerHasCoinDropdown
  alias Components.DecksExplorer
  alias Components.WinrateTag
  alias Hearthstone.DeckTracker
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone

  prop(card_stats, :list)
  prop(highlight_dropdowns, :boolean, default: false)
  prop(filters, :map, default: %{})
  prop(criteria, :any, default: %{})
  prop(filter_context, :atom, default: :public)
  prop(live_view, :module, required: true)
  prop(path_params, :any, default: nil)
  prop(params, :map)
  prop(user, :map, from_context: :user)
  prop(premium_filters, :boolean, default: nil)
  data(test_params, :map)
  data(highlight_cards, :list, default: [])

  def update(assigns, socket) do
    test_params = Map.merge(assigns.criteria, assigns.filters)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(test_params: test_params)
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        assigns.params,
        assigns.path_params,
        test_params
      )
    }
  end

  def render(assigns) do
    ~F"""
    <div>
      <PeriodDropdown id="period_dropdown" filter_context={@filter_context} aggregated_only={!premium_filters?(@premium_filters, @user)} warning={@highlight_dropdowns}/>
      <FormatDropdown id="format_dropdown" filter_context={@filter_context} aggregated_only={!premium_filters?(@premium_filters, @user)}/>
      <RankDropdown id="rank_dropdown" filter_context={@filter_context} aggregated_only={!premium_filters?(@premium_filters, @user)} warning={@highlight_dropdowns}/>
      <LivePatchDropdown id="min_mull_count"
        options={[0, 25, 50, 100, 200, 400, 800, 1600, 3200, 6400, 9600, 12800, 16000]}
        title={"Min Mull Count"}
        param={"min_mull_count"}
        normalizer={&Util.to_int_or_orig/1}
        selected_as_title={false}/>
      <LivePatchDropdown id="min_drawn_count"
        options={[0, 25, 50, 100, 200, 400, 800, 1600, 3200, 6400, 9600, 12800, 16000]}
        title={"Min Drawn Count"}
        param={"min_drawn_count"}
        normalizer={&Util.to_int_or_orig/1}
        selected_as_title={false} />
      <LivePatchDropdown id="show_counts"
        options={[{"yes", "Show Counts"}, {"no", "Don't Show Counts"}]}
        title={"Show Counts"}
        param={"show_counts"}
        selected_as_title={true} />
      <ClassDropdown id={"opponent_class_filter"}
        title={"Opponent"}
        name_prefix={"VS "}
        param={"opponent_class"} />
      {#if premium_filters?(@premium_filters, @user)}
        <PlayableCardSelect format={@test_params["format"]} id={"player_mulligan"} param={"player_mulligan"} selected={@test_params["player_mulligan"] || []} title="In Mulligan"/>
        <PlayableCardSelect format={@test_params["format"]} id={"player_not_mulligan"} param={"player_not_mulligan"} selected={@test_params["player_not_mulligan"] || []} title="Not In Mulligan"/>
        <PlayableCardSelect format={@test_params["format"]} id={"player_drawn"} param={"player_drawn"} selected={@test_params["player_drawn"] || []} title="Drawn"/>
        <PlayableCardSelect format={@test_params["format"]} id={"player_not_drawn"} param={"player_not_drawn"} selected={@test_params["player_not_drawn"] || []} title="Not Drawn"/>
        <PlayableCardSelect format={@test_params["format"]} id={"player_kept"} param={"player_kept"} selected={@test_params["player_kept"] || []} title="Kept"/>
        <PlayableCardSelect format={@test_params["format"]} id={"player_not_kept"} param={"player_not_kept"} selected={@test_params["player_not_kept"] || []} title="Not Kept"/>
        <PlayerHasCoinDropdown id={"player_has_coin_dropdown"} />
        <ForceFreshDropdown id={"force_fresh"} />
      {/if}


      <table class="table is-fullwidth is-striped is-gapless">
        <thead>
          <th>
            <a :on-click="change_sort" phx-value-sort_by={"card"} phx-value-sort_direction={sort_direction(@filters, "card")}>
              {add_arrow("Card", "card", @filters)}
            </a>
          </th>

            <th>
            <a :on-click="change_sort" phx-value-sort_by={"mull_impact"} phx-value-sort_direction={sort_direction(@filters, "mull_impact")}>
              <span data-balloon-pos="up" aria-label={"Mull (kept + unkept) winrate - deck winrate"}>
                {add_arrow("Mulligan Impact", "mull_impact", @filters, true)}
              </span>
            </a>
          </th>
            <th :if={show_counts(@filters)}>
            <a :on-click="change_sort" phx-value-sort_by={"mull_count"} phx-value-sort_direction={sort_direction(@filters, "mull_count")}>
              {add_arrow("Mulligan Count", "mull_count", @filters)}
            </a>
            </th>

            <th>
            <a :on-click="change_sort" phx-value-sort_by={"drawn_impact"} phx-value-sort_direction={sort_direction(@filters, "drawn_impact")}>
              <span data-balloon-pos="up" aria-label={"Drawn winrate - deck winrate"}>
                {add_arrow("Drawn Impact", "drawn_impact", @filters)}
              </span>
            </a>
          </th>
            <th :if={show_counts(@filters)}>
            <a :on-click="change_sort" phx-value-sort_by={"drawn_count"} phx-value-sort_direction={sort_direction(@filters, "drawn_count")}>
              {add_arrow("Drawn Count", "drawn_count", @filters)}
            </a>
          </th>

            <th class="is-hidden-mobile">
            <a :on-click="change_sort" phx-value-sort_by={"kept_impact"} phx-value-sort_direction={sort_direction(@filters, "kept_impact")}>
              <span data-balloon-pos="up" aria-label={"Winrate when kept - deck winrate"}>
                {add_arrow("Kept Impact", "kept_impact", @filters)}
              </span>
            </a>
          </th>

            <th :if={show_counts(@filters)} class="is-hidden-mobile">
            <a :on-click="change_sort" phx-value-sort_by={"kept_count"} phx-value-sort_direction={sort_direction(@filters, "kept_count")}>
              {add_arrow("Kept Count", "kept_count", @filters)}
            </a>
            </th>

        </thead>
        <tbody>
          <tr :for={cs <- @card_stats |> DeckTracker.merge_card_stats() |> map_filter(@filters, @highlight_cards) |> sort(@filters) |> filter_same_deck(@filters)} class={"is-selected": selected?(cs, @highlight_cards)}>
            <td>

            <div class="decklist_card_container">
              <DecklistCard deck_class="NEUTRAL" card={Util.get(cs, :card)} count={count(cs, @filters)} decklist_options={Backend.UserManager.User.decklist_options(@user)}/>
            </div>

              </td>
            <td>
              <WinrateTag class={""} impact={true} winrate={Util.get(cs, :mull_impact)} sample={Util.get(cs, :mull_total)} round/>
              <span :if={!cs.sufficient_mull and !show_counts(@filters)}><HeroIcons.warning_triangle /></span>
            </td>
            <td :if={show_counts(@filters)}>{Util.get(cs, :mull_total) }</td>

            <td>
              <WinrateTag impact={true} winrate={Util.get(cs, :drawn_impact)} sample={Util.get(cs, :drawn_total)} />
              <span :if={!cs.sufficient_drawn and !show_counts(@filters)}><HeroIcons.warning_triangle /></span>
            </td>
            <td :if={show_counts(@filters)}>
              {Util.get(cs, :drawn_total)}</td>

            <td class="is-hidden-mobile"><WinrateTag impact={true} winrate={Util.get(cs, :kept_impact)} sample={Util.get(cs, :kept_total)}/></td>
            <td :if={show_counts(@filters)} class="is-hidden-mobile">{Util.get(cs, :kept_total)}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def premium_filters?(show_premium?, _) when is_boolean(show_premium?), do: show_premium?
  def premium_filters?(_, user), do: Backend.UserManager.User.premium?(user)

  def selected?(%{card: %{id: id}}, [_ | _] = to_highlight),
    do: Hearthstone.canonical_id(id) in to_highlight

  def selected?(_, _), do: false

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

  def flip_direction(
        new_params = %{"sort_by" => new_sort_by},
        old_params = %{"sort_by" => old_sort_by}
      )
      when new_sort_by == old_sort_by do
    new_direction = get_direction(old_params) |> flip_direction()
    Map.put(new_params, "sort_direction", new_direction)
  end

  def flip_direction(new_params, _old_params), do: new_params

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

  @default_min_mull_count 200
  @default_min_drawn_count 1600
  def default_minimum_counts(%{"deck_id" => _}),
    do: %{"min_mull_count" => 0, "min_drawn_count" => 0}

  def default_minimum_counts(%{"player_deck_id" => _}),
    do: %{"min_mull_count" => 0, "min_drawn_count" => 0}

  def default_minimum_counts(%{"min_count" => min_count}),
    do: %{"min_mull_count" => min_count, "min_drawn_count" => min_count}

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

  def map_filter(stats, filters, to_highlight) do
    %{"min_mull_count" => default_mull_min, "min_drawn_count" => default_drawn_min} =
      default_minimum_counts(filters)

    mull_min = Map.get(filters, "min_mull_count", default_mull_min)
    drawn_min = Map.get(filters, "min_drawn_count", default_drawn_min)

    Enum.flat_map(stats, fn cs ->
      mull = Util.get(cs, :mull_total)
      drawn = Util.get(cs, :drawn_total)
      card = card(Util.get(cs, :card_id))
      sufficient_mull = mull >= mull_min
      sufficient_drawn = drawn >= drawn_min
      in_highlight = card != nil and Hearthstone.canonical_id(card.id) in to_highlight

      if in_highlight or (sufficient_mull and sufficient_drawn and card != nil) do
        [
          cs
          |> Map.put(:card, card)
          |> Map.put(:sufficient_mull, sufficient_mull)
          |> Map.put(:sufficient_drawn, sufficient_drawn)
        ]
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

  def sort(stats, %{"sort_by" => "card"} = filters) do
    direction = get_direction(filters)
    Backend.Hearthstone.sort_cards(stats, direction: direction)
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

  def filter_relevant(filters) do
    filters
    |> Map.take([
      "min_mull_count",
      "min_drawn_count",
      "min_count",
      "show_counts",
      "player_deck_id",
      "deck_id",
      "player_mulligan",
      "player_not_mulligan",
      "player_drawn",
      "player_not_drawn",
      "player_kept",
      "player_not_kept",
      "archetype",
      "sort_by",
      "sort_direction"
    ])
    |> DecksExplorer.parse_int([
      "player_mulligan",
      "player_not_mulligan",
      "player_drawn",
      "player_not_drawn",
      "player_kept",
      "player_not_kept",
      "min_mull_count",
      "min_drawn_count",
      "min_count"
    ])
  end

  def default_criteria(context, criteria \\ nil) do
    default_format = FormatDropdown.default(context)

    %{
      "period" => PeriodDropdown.default(context, criteria, default_format),
      "rank" => RankDropdown.default(context),
      "opponent_class" => "any",
      "format" => default_format
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
            params: params,
            path_params: path_params,
            live_view: lv
          }
        } = socket
      ) do
    new_params = Map.merge(params, sort)

    {:noreply,
     socket
     |> push_patch(
       to:
         LivePatchDropdown.link(
           BackendWeb.Endpoint,
           lv,
           path_params,
           new_params
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
