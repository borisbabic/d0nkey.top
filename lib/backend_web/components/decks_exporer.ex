defmodule Components.DecksExplorer do
  @moduledoc false
  use Surface.LiveComponent
  alias Backend.Blizzard
  alias Backend.Hearthstone.Deck
  alias Components.DeckWithStats
  alias Components.Filter.PlayableCardSelect
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker
  alias Hearthstone.Enums.Format
  alias BackendWeb.Router.Helpers, as: Routes
  alias Components.ClassStatsModal

  # @default_limit 15
  # @max_limit 30
  # @min_min_games 50
  # @default_min_games 100
  # # standard
  # @default_format 2
  # @default_order_by "winrate"
  # data(user, :any)

  @default_period_options [{"past_30_days", "Past 30 Days"}, {"past_2_weeks", "Past 2 Weeks"}, {"past_week", "Past Week"}, {"past_day", "Past Day"}, {"past_3_days", "Past 3 Days"}, {"alterac_valley", "Alterac Valley"}, {"onyxias_lair", "Onyxia's Lair"}]

  def default_period_options(), do: @default_period_options
  prop(default_order_by, :string, default: "winrate")
  prop(default_format, :number, default: 2)
  prop(default_rank, :string, default: "diamond_to_legend")
  prop(period_options, :list, default: @default_period_options)
  prop(extra_period_options, :list, default: [])
  prop(min_games_options, :list, default: [1, 10, 20, 50, 100, 200, 400, 800, 1600, 3200])
  prop(default_min_games, :integer, default: 100)
  prop(min_games_floor, :integer, default: 50)
  prop(limit_cap, :integer, default: 30)
  prop(default_limit, :integer, default: 15)
  prop(live_view, :module, required: true)
  prop(additional_params, :map, default: %{})
  prop(params, :map, required: true)
  prop(path_params, :any, default: nil)

  def render(assigns) do

    ~F"""
    <div>
      <div :if={{params, search_filters} = parse_params(@params, assigns)}>
        <LivePatchDropdown
          options={format_options()}
          title={"Format"}
          param={"format"}
          url_params={@params}
          path_params={@path_params}
          selected_params={params}
          normalizer={&to_string/1}
          live_view={@live_view} />
        <LivePatchDropdown
          options={rank_options()}
          title={"Rank"}
          param={"rank"}
          url_params={@params}
          path_params={@path_params}
          selected_params={params}
          live_view={@live_view} />

        <LivePatchDropdown
          options={@extra_period_options ++ @period_options}
          title={"Period"}
          param={"period"}
          url_params={@params}
          path_params={@path_params}
          selected_params={params}
          live_view={@live_view} />

        <LivePatchDropdown
          options={limit_options()}
          title={"Decks"}
          param={"limit"}
          selected_as_title={false}
          url_params={@params}
          path_params={@path_params}
          selected_params={params}
          normalizer={&to_string/1}
          live_view={@live_view} />

        <LivePatchDropdown
          options={class_options("Any Class")}
          title={"Class"}
          param={"player_class"}
          url_params={@params}
          path_params={@path_params}
          selected_params={params}
          live_view={@live_view} />

        <LivePatchDropdown
          options={class_options("Any Opponent")}
          title={"Opponent Class"}
          param={"opponent_class"}
          url_params={@params}
          path_params={@path_params}
          selected_params={params}
          live_view={@live_view} />


        <LivePatchDropdown
          options={min_games_options(@min_games_options, @min_games_floor)}
          title={"Min Games"}
          param={"min_games"}
          selected_as_title={false}
          url_params={@params}
          path_params={@path_params}
          selected_params={params}
          normalizer={&to_string/1}
          live_view={@live_view} />

        <LivePatchDropdown
          options={order_by_options()}
          title={"Order By"}
          param={"order_by"}
          url_params={@params}
          path_params={@path_params}
          selected_params={params}
          live_view={@live_view} />

        <PlayableCardSelect id={"player_deck_includes"} update_fun={PlayableCardSelect.update_cards_fun(@params, "player_deck_includes")} selected={params["player_deck_includes"] || []} title="Include cards"/>
        <PlayableCardSelect id={"player_deck_excludes"} update_fun={PlayableCardSelect.update_cards_fun(@params, "player_deck_excludes")} selected={params["player_deck_excludes"] || []} title="Exclude cards"/>
        <ClassStatsModal class="dropdown" id="class_stats_modal" get_stats={fn -> search_filters |> class_stats_filters() |> DeckTracker.class_stats() end} title="As Class" />
        <ClassStatsModal class="dropdown" id="opponent_class_stats_modal" get_stats={fn -> search_filters |> class_stats_filters() |> DeckTracker.opponent_class_stats() end} title={"Vs Class"}/>
        <br>
        <br>

        <div :if={deck_stats = DeckTracker.deck_stats(search_filters)} class="columns is-multiline is-mobile is-narrow is-centered">
          <div :for={deck_with_stats <- deck_stats} class="column is-narrow">
            <DeckWithStats deck_with_stats={deck_with_stats} />
          </div>
          <div :if={!(Enum.any?(deck_stats))} >
            <br>
            <br>
            <br>
            <br>
            No decks available for these filters
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp parse_params(raw_params, assigns) do
    defaults = [
      {"limit", assigns.default_limit},
      {"min_games", assigns.default_min_games},
      {"format", assigns.default_format},
      {"order_by", assigns.default_order_by},
      {"period", default_period()},
      {"game_type", Hearthstone.Enums.GameType.constructed_types()},
      {"rank", assigns.default_rank},
    ]

    params = raw_params
    |> filter_relevant()
    |> apply_defaults(defaults)
    |> cap_param("limit", assigns.limit_cap)
    |> floor_param("min_games", assigns.min_games_floor)
    search_filters = Map.merge(assigns.additional_params, params)
    {params, search_filters}
  end

  defp class_stats_filters(filters), do: Map.delete(filters, "min_games") |> Map.delete("order_by")

  def handle_info({:update_params, params}, socket = %{assigns: %{path_params: path_params}}) when not is_nil(path_params) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, path_params, params))}
  end
  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}


  def rank_options(), do: [{"legend", "Legend"}, {"diamond_to_legend", "Diamond-Legend"}, {"all", "All"}]
  def limit_options(), do: [10, 15, 20, 25, 30]
  def class_options(any_name \\ "Any"), do: [{nil, any_name} | Enum.map(Deck.classes(), & {&1, Deck.class_name(&1)})]
  def format_options(), do:
    Enum.map(Format.all(), fn {id, name} ->
      {to_string(id), name}
    end)
  def region_options(), do:
    [
      {nil, "All Regions"}
      | Enum.map(Blizzard.regions(), & {to_string(&1), Blizzard.get_region_name(&1, :long)})
    ]
  def min_games_options(options, min), do: options |> Enum.sort() |> Enum.drop_while(& &1 < min)
  def order_by_options(), do: [{"winrate", "Winrate %"}, {"total", "Total Games"}]

  def filter_relevant(params) do
    params
    |> Map.take(["rank", "period", "limit", "order_by", "player_class", "opponent_class", "format", "offset", "region", "min_games", "player_deck_includes", "player_deck_excludes"])
    |> parse_int(["limit", "min_games", "format", "offset", "player_deck_includes", "player_deck_excludes"])
  end

  def parse_int(params, to_parse) when is_list(to_parse), do:
    Enum.reduce(to_parse, params, &parse_int(&2, &1))

  def parse_int(params, param) do
    curr = Map.get(params, param)
    new_val = if is_list(curr) do
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

  defp default_period(), do: "onyxias_lair"

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
