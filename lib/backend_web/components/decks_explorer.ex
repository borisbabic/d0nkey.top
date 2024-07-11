defmodule Components.DecksExplorer do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Backend.Blizzard
  alias Components.DeckWithStats
  alias Components.Filter.ArchetypeSelect
  alias Components.Filter.PlayableCardSelect
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.RegionDropdown
  alias Components.Filter.FormatDropdown
  alias Components.Filter.ClassDropdown
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.AggregationCount
  alias BackendWeb.Router.Helpers, as: Routes
  alias Components.ClassStatsModal

  # @default_limit 15
  # @max_limit 30
  # @min_min_games 50
  @default_min_games 200
  # # standard
  # @default_format 2
  # @default_order_by "winrate"
  # data(user, :any)

  prop(default_order_by, :string, default: "winrate")
  prop(default_format, :number, default: nil)
  prop(default_rank, :string, default: nil)
  prop(default_period, :string, default: nil)
  prop(filter_context, :atom, default: :public)

  prop(min_games_options, :list,
    default: [1, 10, 20, 50, 100, 200, 400, 800, 1600, 3200, 6400, 12_800]
  )

  prop(default_min_games, :integer, default: nil)
  prop(min_games_floor, :integer, default: 50)
  prop(limit_cap, :integer, default: 200)
  prop(default_limit, :integer, default: 15)
  prop(live_view, :module, required: true)
  prop(additional_params, :map, default: %{})
  prop(params, :map, required: true)
  prop(path_params, :any, default: nil)
  data(streams, :any)
  data(search_filters, :any)
  data(actual_params, :any)
  data(user, :map, from_context: :user)
  data(offset, :integer, default: 0)
  data(end_of_stream?, :boolean, default: false)

  def update(assigns, socket) do
    {actual_params, search_filters} = parse_params(assigns)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(
        actual_params: actual_params,
        search_filters: search_filters,
        offset: 0,
        end_of_stream?: false
      )
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        assigns.params,
        assigns.path_params,
        actual_params
      )
      |> stream_deck_stats(0, true)
      # |> stream(:deck_stats, deck_stats, reset: true)
    }
  end

  def stream_deck_stats(socket, new_offset, reset \\ false) when new_offset >= 0 do
    %{offset: curr_offset} = socket.assigns
    {_, search_filters} = parse_params(socket.assigns)
    # %{"limit" => limit} = search_filters

    fetched_deck_stats =
      search_filters
      |> Map.put("offset", new_offset)
      |> DeckTracker.deck_stats()
      |> Enum.map(&Map.put_new(&1, :id, &1.deck_id))

    handle_offset_stream_scroll(
      socket,
      :deck_stats,
      fetched_deck_stats,
      new_offset,
      curr_offset,
      nil,
      reset
    )
  end

  def render(assigns) do
    ~F"""
    <div>
      <div :if={{params, search_filters} = {@actual_params, @search_filters}}>

        <FormatDropdown id="format_dropdown" filter_context={@filter_context} />
        <RankDropdown id="rank_dropdown" filter_context={@filter_context} warning={warning?(@streams)} />
        <PeriodDropdown id="period_dropdown" filter_context={@filter_context} warning={warning?(@streams)} />
        <RegionDropdown id={"deck_region"} filter_context={@filter_context} />

         { #<LivePatchDropdown
        #   options={limit_options()}
        #   title={"# Decks"}
        #   param={"limit"}
        #   selected_as_title={false}
        #   normalizer={&to_string/1} />
        }

        <ClassDropdown id="player_class_dropdown" title="Player Class" param="player_class" />
        <ClassDropdown id="opponent_class_dropdown" title="Opponent Class" param="opponent_class" any_param="Any Opponent" />

        <LivePatchDropdown
          options={min_games_options(@min_games_options, @min_games_floor)}
          title={"Min Games"}
          param={"min_games"}
          warning={warning?(@streams)}
          selected_as_title={true}
          normalizer={&to_string/1} />

        <LivePatchDropdown
          options={order_by_options()}
          title={"Order By"}
          param={"order_by"} />

        <ArchetypeSelect id={"player_deck_archetype"} update_fun={ArchetypeSelect.update_archetypes_fun(@params, "player_deck_archetype")} selected={params["player_deck_archetype"] || []} title="Archetypes" />
        <PlayableCardSelect id={"player_deck_includes"} update_fun={PlayableCardSelect.update_cards_fun(@params, "player_deck_includes")} selected={params["player_deck_includes"] || []} title="Include cards"/>
        <PlayableCardSelect id={"player_deck_excludes"} update_fun={PlayableCardSelect.update_cards_fun(@params, "player_deck_excludes")} selected={params["player_deck_excludes"] || []} title="Exclude cards"/>
        <ClassStatsModal class="dropdown" id="class_stats_modal" get_stats={fn -> search_filters |> Map.drop(["force_fresh"]) |> class_stats_filters() |> DeckTracker.class_stats() end} title="As Class" />
        <ClassStatsModal class="dropdown" id="opponent_class_stats_modal" get_stats={fn -> search_filters |> Map.drop(["force_fresh"]) |> class_stats_filters() |> DeckTracker.opponent_class_stats() end} title={"Vs Class"}/>
        <LivePatchDropdown
          :if={Backend.UserManager.User.can_access?(@user, :archetyping)}
          options={[{nil, "No"}, {"yes", "Yes"}]}
          title={"No archetype"}
          param={"no_archetype"}
          selected_as_title={false}
        />
        <br>
        <br>

        <div
        id="deck_stats_viewport"
        phx-update="stream"
        class="columns is-multiline is-mobile is-narrow is-centered"
        phx-target={@myself}
        phx-viewport-bottom={!@end_of_stream? && "next-decks-page"}>
          <div id={dom_id} :for={{dom_id, deck_with_stats} <- @streams.deck_stats} class="column is-narrow">
            <DeckWithStats deck_with_stats={deck_with_stats} />
          </div>
        </div>
        <div :if={warning?(@streams)} >
          <br>
          <br>
          <br>
          <br>
          <div class="notification is-warning">
            No decks available for these filters. Maybe try changing one of the highlighted ones?
          </div>
        </div>
      </div>
    </div>
    """
  end

  # def handle_event("previous-decks-page", %{"_overran" => true}, socket) do
  #   %{offset: offset} = socket.assigns
  #   {_, %{"limit" => limit}} = parse_params(socket.assigns)

  #   if offset <= (@viewport_size_factor - 1) * limit do
  #     {:noreply, socket}
  #   else
  #     {:noreply, stream_deck_stats(socket, 0)}
  #   end
  # end

  # def handle_event("previous-decks-page", _, socket) do
  #   %{offset: offset} = socket.assigns
  #   {_, %{"limit" => limit}} = parse_params(socket.assigns)
  #   new_offset = Enum.max([offset - limit, 0])

  #   if new_offset == offset do
  #     {:noreply, socket}
  #   else
  #     {:noreply, stream_deck_stats(socket, new_offset)}
  #   end
  # end

  def handle_event("next-decks-page", _middle, socket) do
    %{offset: offset} = socket.assigns
    {_, %{"limit" => limit}} = parse_params(socket.assigns)
    new_offset = offset + limit
    {:noreply, stream_deck_stats(socket, new_offset)}
  end

  defp warning?(%{deck_stats: %{inserts: []}}), do: true
  defp warning?(_), do: false

  defp parse_params(assigns = %{params: params}) do
    parse_params(params, assigns)
  end

  defp parse_params(raw_params, assigns) do
    regions =
      case assigns do
        %{filter_context: :public} ->
          Hearthstone.DeckTracker.get_auto_aggregate_regions()

        _ ->
          []
      end

    default_format = assigns.default_format || FormatDropdown.default(assigns.filter_context)

    defaults = [
      {"limit", assigns.default_limit},
      {"region", regions},
      {"min_games", assigns.default_min_games},
      {"format", default_format},
      {"order_by", assigns.default_order_by},
      {"period",
       assigns.default_period ||
         PeriodDropdown.default(assigns.filter_context, raw_params, default_format)},
      {"game_type", [7]},
      {"opponent_class", "any"},
      {"archetype", "any"},
      {"rank", assigns.default_rank || RankDropdown.default(assigns.filter_context)}
    ]

    params =
      raw_params
      |> filter_relevant()
      |> apply_defaults(defaults)
      |> cap_param("limit", assigns.limit_cap)
      |> ensure_min_games()
      |> floor_param("min_games", assigns.min_games_floor)

    search_filters = Map.merge(assigns.additional_params, params)
    {params, search_filters}
  end

  defp ensure_min_games(%{"min_games" => min} = params) when is_integer(min), do: params

  defp ensure_min_games(%{"opponent_class" => oc} = params) when oc != "any" do
    Map.put(params, "min_games", @default_min_games)
  end

  defp ensure_min_games(params) do
    min =
      case DeckTracker.current_aggregation_count(params) do
        {:ok, count} -> AggregationCount.choose_count(count, 50, @default_min_games)
        _ -> @default_min_games
      end

    Map.put(params, "min_games", min)
  end

  defp class_stats_filters(filters),
    do: Map.delete(filters, "min_games") |> Map.delete("order_by")

  def handle_info({:update_params, params}, socket = %{assigns: %{path_params: path_params}})
      when not is_nil(path_params) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, path_params, params))}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  def limit_options(), do: [10, 15, 20, 25, 30]

  def region_options(),
    do: [
      {nil, "All Regions"}
      | Enum.map(Blizzard.regions(), &{to_string(&1), Blizzard.get_region_name(&1, :long)})
    ]

  def min_games_options(options, min) do
    options
    |> Enum.sort()
    |> Enum.drop_while(&(&1 < min))
    |> Enum.map(&{&1, "Min #{&1}"})
  end

  def order_by_options(), do: [{"winrate", "Winrate %"}, {"total", "Total Games"}]

  def filter_relevant(params) do
    params
    |> Map.take([
      "rank",
      "period",
      "limit",
      "order_by",
      "player_class",
      "opponent_class",
      "format",
      "deck_format",
      "offset",
      "region",
      "min_games",
      "player_deck_includes",
      "archetype",
      "no_archetype",
      "player_deck_excludes",
      "use_aggregated",
      "force_fresh",
      "player_deck_archetype"
    ])
    |> parse_int([
      "limit",
      "min_games",
      "format",
      "deck_format",
      "offset",
      "player_deck_includes",
      "player_deck_excludes"
    ])
  end

  def parse_int(params, to_parse) when is_list(to_parse),
    do: Enum.reduce(to_parse, params, &parse_int(&2, &1))

  def parse_int(params, param) do
    curr = Map.get(params, param)

    new_val =
      if is_list(curr) do
        Enum.map(curr, &Util.to_int_or_orig/1)
      else
        Util.to_int_or_orig(curr)
      end

    if new_val && new_val != curr do
      Map.put(params, param, new_val)
    else
      params
    end
  end

  def apply_defaults(filters, defaults) do
    Enum.reduce(defaults, filters, fn {key, val}, carry ->
      Map.put_new(carry, key, val)
    end)
  end

  def cap_param(params, param, max),
    do: limit_param(params, param, max, &Kernel.>/2)

  def floor_param(params, param, min),
    do: limit_param(params, param, min, &Kernel.</2)

  def limit_param(params, param, limit, limiter) do
    curr = Map.get(params, param)

    if curr && limiter.(curr, limit) do
      Map.put(params, param, limit)
    else
      params
    end
  end
end
