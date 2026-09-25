defmodule Components.DecksExplorer do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Backend.Blizzard
  alias Components.DeckWithStats
  alias Components.DeckTableRow
  alias Components.Filter.ArchetypeSelect
  alias Components.Filter.PlayableCardSelect
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.RegionDropdown
  alias Components.Filter.ForceFreshDropdown
  alias Components.Filter.FormatDropdown
  alias Components.Filter.ClassMultiDropdown
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Period
  alias BackendWeb.Router.Helpers, as: Routes
  alias Components.ArchetypeStatsModal
  alias Components.ClassStatsModal

  # @default_limit 15
  # @max_limit 30
  # @min_min_games 50
  @default_min_games 200
  @default_min_games_floor 50
  # # standard
  # @default_format 2
  # @default_order_by "winrate"
  # data(user, :any)

  prop(default_order_by, :string, default: "winrate")
  prop(default_format, :number, default: nil)
  prop(default_rank, :string, default: nil)
  prop(default_period, :string, default: nil)
  prop(default_view_mode, :string, default: "grid")
  prop(default_card_mode, :string, default: "card_top")
  prop(filter_context, :atom, default: :public)

  prop(min_games_options, :list, default: [1, 10, 20, 50, 100, 200, 400, 800, 1600, 3200, 6400, 12_800])

  prop(default_min_games, :integer, default: nil)
  prop(min_games_floor, :integer, default: 50)
  prop(limit_cap, :integer, default: 200)
  prop(default_limit, :integer, default: 20)
  prop(live_view, :module, required: true)
  prop(additional_params, :map, default: %{})
  prop(params, :map, required: true)
  prop(path_params, :any, default: nil)
  data(streams, :any)
  data(search_filters, :any)
  data(actual_params, :any)
  data(view_mode, :string, default: "grid")
  data(card_mode, :string, default: "card_top")
  data(user, :map, from_context: :user)
  data(offset, :integer, default: 0)
  data(needs_login?, :boolean, default: nil)
  data(end_of_stream?, :boolean, default: false)

  def update(assigns_raw, socket) do
    assigns =
      if Map.get(assigns_raw, :min_games_floor) == nil do
        Map.put(assigns_raw, :min_games_floor, @default_min_games_floor)
      else
        assigns_raw
      end

    {actual_params, search_filters} = parse_params(assigns)

    view_mode = Map.get(actual_params, "view_mode") || assigns.default_view_mode
    card_mode = Map.get(actual_params, "card_mode") || assigns.default_card_mode

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(
        actual_params: actual_params,
        search_filters: search_filters,
        view_mode: view_mode,
        card_mode: card_mode,
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

    criteria = Map.put(search_filters, "offset", new_offset)

    if :agg == DeckTracker.fresh_or_agg_deck_stats(criteria) or
         can_access_unaggregated?(
           Map.get(socket.assigns, :user),
           Map.get(socket.assigns, :filter_context)
         ) do
      fetched_deck_stats =
        criteria
        |> DeckTracker.deck_stats()
        |> Enum.map(&Map.put_new(&1, :id, &1.deck_id))
        |> with_decks()

      handle_offset_stream_scroll(
        socket,
        :deck_stats,
        fetched_deck_stats,
        new_offset,
        curr_offset,
        nil,
        reset
      )
    else
      handle_offset_stream_scroll(
        socket,
        :deck_stats,
        [],
        curr_offset,
        curr_offset,
        nil,
        reset
      )
      |> assign(:needs_login?, true)
    end
  end

  # Batch-preloads the `:deck` for each deck_stats entry in a single query, instead of each
  # `DeckWithStats`/`DeckTableRow` row fetching its own deck individually as it renders.
  defp with_decks(deck_stats) do
    decks_by_id =
      deck_stats
      |> Enum.map(& &1.deck_id)
      |> Backend.Hearthstone.decks_by_ids()

    Enum.map(deck_stats, fn stats -> Map.put(stats, :deck, Map.get(decks_by_id, stats.deck_id)) end)
  end

  def render(assigns) do
    ~F"""
    <div>
      <div phx-hook="InfiniteScrollLoaded" id="deck_stats_container" :if={{params, search_filters} = {@actual_params, @search_filters}}>

      <.filter_container>
        <FormatDropdown id="format_dropdown" filter_context={@filter_context} aggregated_only={!can_access_unaggregated?(@user, @filter_context)}/>
        <RankDropdown id="rank_dropdown" filter_context={@filter_context} aggregated_only={!can_access_unaggregated?(@user, @filter_context)} warning={warning?(@streams)} />
        <PeriodDropdown id="period_dropdown" filter_context={@filter_context} aggregated_only={!can_access_unaggregated?(@user, @filter_context)} warning={warning?(@streams)} />
        <RegionDropdown :if={can_access_unaggregated?(@user, @filter_context)} title={"Region"} warning={true} id={"deck_region"} filter_context={@filter_context} />

         { #<LivePatchDropdown
        #   options={limit_options()}
        #   title={"# Decks"}
        #   param={"limit"}
        #   selected_as_title={false}
        #   normalizer={&to_string/1} />
        }

        <ClassMultiDropdown id="player_class_dropdown" title="Player Class" param="player_class" />
        <ClassMultiDropdown id="opponent_class_dropdown" title="Opponent Class" param="opponent_class" any_param="Any Opponent" />

        <LivePatchDropdown
          options={min_games_options(@min_games_options, @min_games_floor)}
          title={"Min Games"}
          param={"min_games"}
          warning={warning?(@streams)}
          selected_as_title={true}
          normalizer={&to_string/1} />

        <LivePatchDropdown
          :if={show_winrate_dropdown?(@params)}
          options={[0, 20, 30, 40, 45, 50, 55, 60, 70, 80] |> Enum.map(& {&1, "Min #{&1}%"})}
          title={"Min Winrate"}
          param={"min_winrate"}
          warning={warning?(@streams)}
          selected_as_title={true}
          normalizer={&to_string/1} />

        <LivePatchDropdown
          options={order_by_options()}
          title={"Order By"}
          param={"order_by"} />

        <ArchetypeSelect criteria={@actual_params} id={"player_deck_archetype"} param={"player_deck_archetype"} selected={params["player_deck_archetype"] || []} title="Archetypes" />
        <LivePatchDropdown
          options={[{nil, "Any Decks"}, {"yes", "Includes Latest Set"}]}
          title={"Latest Set"}
          param={"includes_latest_set"} />
        <PlayableCardSelect id={"player_deck_includes"} format={params["format"]} param={"player_deck_includes"} selected={params["player_deck_includes"] || []} title="Include cards"/>
        <PlayableCardSelect id={"player_deck_excludes"} format={params["format"]} param={"player_deck_excludes"} selected={params["player_deck_excludes"] || []} title="Exclude cards"/>
        <ArchetypeSelect criteria={@actual_params} :if={can_access_unaggregated?(@user, @filter_context)} played_cards_archetypes={true} id={"opponent_archetype"} param={"opponent_archetype"} selected={params["opponent_archetype"] || []} title="Opponent Archetype" />
        <ClassStatsModal :if={can_access_unaggregated?(@user, @filter_context)} class="dropdown" id="class_stats_modal" get_stats={fn -> search_filters |> Map.drop(["force_fresh"]) |> modal_stats_filters() |> DeckTracker.class_stats() end} title={warning_if_public(@filter_context, "As Class")} />
        <ClassStatsModal :if={can_access_unaggregated?(@user, @filter_context)} class="dropdown" id="opponent_class_stats_modal" get_stats={fn -> search_filters |> Map.drop(["force_fresh"]) |> modal_stats_filters() |> DeckTracker.opponent_class_stats() end} title={warning_if_public(@filter_context, "Vs Class")}/>
        <ArchetypeStatsModal minimum_games={if @filter_context == :personal, do: 1, else: 20} :if={Backend.UserManager.User.premium?(@user)} class="dropdown" id="opponent_archetype_stats_modal" get_stats={fn -> search_filters |> Map.drop(["force_fresh"]) |> modal_stats_filters() |> DeckTracker.opponent_archetype_stats() end} title={warning_if_public(@filter_context, "Vs Archetype")}/>
        <ForceFreshDropdown
          id="decks_explorer_force_fresh"
          :if={@filter_context == :public and Backend.UserManager.User.premium?(@user)} />
        <LivePatchDropdown
          :if={@filter_context == :personal and !Enum.empty?(Hearthstone.DeckTracker.bugged_source_ids())}
          options={[{"no", "No"}, {"yes", "Yes"}]}
          title={"Exclude Bugged Deck Tracker Versions"}
          param={"exclude_bugged_sources"}
          selected_as_title={false}
        />
        <LivePatchDropdown
          :if={Backend.UserManager.User.can_access?(@user, :archetyping)}
          options={[{nil, "No"}, {"yes", Components.Helper.warning_triangle(%{before: "Yes"})}]}
          title={"No archetype"}
          param={"no_archetype"}
          selected_as_title={false}
        />

        <div class="tw-flex tw-items-center">
          <div class="buttons has-addons tw-mb-0">
            <.link
              patch={link_with_view_mode(assigns, "grid")}
              class={["button is-small tw-inline-flex tw-items-center tw-gap-1.5", if(@view_mode != "table", do: "is-info is-selected", else: "is-dark")]}
              title="Grid View"
            >
              <span class="icon is-small">
                <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 0 1 6 3.75h2.25A2.25 2.25 0 0 1 10.5 6v2.25a2.25 2.25 0 0 1-2.25 2.25H6a2.25 2.25 0 0 1-2.25-2.25V6ZM3.75 15.75A2.25 2.25 0 0 1 6 13.5h2.25a2.25 2.25 0 0 1 2.25 2.25V18a2.25 2.25 0 0 1-2.25 2.25H6A2.25 2.25 0 0 1 3.75 18v-2.25ZM13.5 6a2.25 2.25 0 0 1 2.25-2.25H18A2.25 2.25 0 0 1 20.25 6v2.25A2.25 2.25 0 0 1 18 10.5h-2.25a2.25 2.25 0 0 1-2.25-2.25V6ZM13.5 15.75a2.25 2.25 0 0 1 2.25-2.25H18a2.25 2.25 0 0 1 2.25 2.25V18A2.25 2.25 0 0 1 18 20.25h-2.25A2.25 2.25 0 0 1 13.5 18v-2.25Z" />
                </svg>
              </span>
              <span>Grid</span>
            </.link>
            <.link
              patch={link_with_view_mode(assigns, "table")}
              class={["button is-small tw-inline-flex tw-items-center tw-gap-1.5", if(@view_mode == "table", do: "is-info is-selected", else: "is-dark")]}
              title="Table View"
            >
              <span class="icon is-small">
                <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
                </svg>
              </span>
              <span>Table</span>
            </.link>
          </div>
        </div>

        <div :if={@view_mode == "table"} class="tw-flex tw-items-center">
          <div class="buttons has-addons tw-mb-0">
            <.link
              patch={link_with_card_mode(assigns, "card_top")}
              class={["button is-small tw-inline-flex tw-items-center tw-gap-1.5", if(@card_mode != "cropped_art", do: "is-info is-selected", else: "is-dark")]}
              title="Card Top View (Cut off below rarity gem)"
            >
              <span class="icon is-small">
                <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M6 3h12a2 2 0 012 2v14a2 2 0 01-2 2H6a2 2 0 01-2-2V5a2 2 0 012-2z" />
                  <path stroke-linecap="round" stroke-linejoin="round" d="M6 10h12" />
                </svg>
              </span>
              <span>Card Top</span>
            </.link>
            <.link
              patch={link_with_card_mode(assigns, "cropped_art")}
              class={["button is-small tw-inline-flex tw-items-center tw-gap-1.5", if(@card_mode == "cropped_art", do: "is-info is-selected", else: "is-dark")]}
              title="Cropped Card View (Card art with stat overlays)"
            >
              <span class="icon is-small">
                <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M4 4h16v16H4V4z" />
                  <path stroke-linecap="round" stroke-linejoin="round" d="M4 14l5-5 4 4 3-3 4 4" />
                </svg>
              </span>
              <span>Cropped Card</span>
            </.link>
          </div>
        </div>
      </.filter_container>

      <.filter_loading_indicator />

        <div
          :if={!@needs_login? and @view_mode == "table"}
          id="deck_stats_viewport_table_container"
          class="tw-overflow-x-auto tw-rounded-xl tw-border tw-border-slate-800 has-background-dark tw-mb-6"
        >
          <table class="tw-w-full tw-text-left tw-border-collapse">
            <thead>
              <tr class="tw-border-b tw-border-slate-800 tw-bg-black/20">
                <th class="tw-px-4 tw-py-2.5">
                  <div class="tw-flex tw-items-center">
                    <span class="tw-w-24 tw-shrink-0 tw-flex tw-justify-center">
                      <.link
                        patch={link_with_order_by(assigns, "winrate")}
                        class={[
                          "tw-inline-flex tw-items-center tw-justify-center tw-gap-1 tw-text-xs tw-font-bold tw-uppercase tw-tracking-wider tw-transition-colors tw-py-1 tw-px-1.5 tw-rounded hover:tw-bg-slate-800/60",
                          if(order_by_active?(params, "winrate"), do: "tw-text-sky-400", else: "tw-text-slate-400 hover:tw-text-slate-200")
                        ]}
                        title="Sort by Winrate"
                      >
                        <span>Winrate</span>
                        <span :if={order_by_active?(params, "winrate")} class="tw-text-xs">
                          {if(current_direction(params) == "asc", do: "↑", else: "↓")}
                        </span>
                      </.link>
                    </span>
                    <span class="tw-w-72 tw-shrink-0 tw-pl-4 tw-text-xs tw-font-bold tw-uppercase tw-tracking-wider tw-text-slate-300">
                      Deck
                    </span>
                    <span class="tw-w-24 tw-shrink-0 tw-flex tw-justify-center">
                      <.link
                        patch={link_with_order_by(assigns, "total")}
                        class={[
                          "tw-inline-flex tw-items-center tw-justify-center tw-gap-1 tw-text-xs tw-font-bold tw-uppercase tw-tracking-wider tw-transition-colors tw-py-1 tw-px-1.5 tw-rounded hover:tw-bg-slate-800/60",
                          if(order_by_active?(params, "total"), do: "tw-text-sky-400", else: "tw-text-slate-400 hover:tw-text-slate-200")
                        ]}
                        title="Sort by Total Games"
                      >
                        <span>Games</span>
                        <span :if={order_by_active?(params, "total")} class="tw-text-xs">
                          {if(current_direction(params) == "asc", do: "↑", else: "↓")}
                        </span>
                      </.link>
                    </span>
                    <span class="tw-w-20 tw-shrink-0 tw-flex tw-justify-center">
                      <.link
                        patch={link_with_order_by(assigns, "turns")}
                        class={[
                          "tw-inline-flex tw-items-center tw-justify-center tw-gap-1 tw-text-xs tw-font-bold tw-uppercase tw-tracking-wider tw-transition-colors tw-py-1 tw-px-1.5 tw-rounded hover:tw-bg-slate-800/60",
                          if(order_by_active?(params, "turns"), do: "tw-text-sky-400", else: "tw-text-slate-400 hover:tw-text-slate-200")
                        ]}
                        title="Sort by Average Turns"
                      >
                        <span>Turns</span>
                        <span :if={order_by_active?(params, "turns")} class="tw-text-xs">
                          {if(current_direction(params) == "asc", do: "↑", else: "↓")}
                        </span>
                      </.link>
                    </span>
                    <span class="tw-w-24 tw-shrink-0 tw-flex tw-justify-center">
                      <.link
                        patch={link_with_order_by(assigns, "duration")}
                        class={[
                          "tw-inline-flex tw-items-center tw-justify-center tw-gap-1 tw-text-xs tw-font-bold tw-uppercase tw-tracking-wider tw-transition-colors tw-py-1 tw-px-1.5 tw-rounded hover:tw-bg-slate-800/60",
                          if(order_by_active?(params, "duration"), do: "tw-text-sky-400", else: "tw-text-slate-400 hover:tw-text-slate-200")
                        ]}
                        title="Sort by Average Duration"
                      >
                        <span>Duration</span>
                        <span :if={order_by_active?(params, "duration")} class="tw-text-xs">
                          {if(current_direction(params) == "asc", do: "↑", else: "↓")}
                        </span>
                      </.link>
                    </span>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody
              id="deck_stats_viewport_table"
              phx-update="stream"
              phx-target={@myself}
              phx-viewport-bottom={if @end_of_stream?, do: "", else: "next-decks-page"}
              class="tw-divide-y tw-divide-slate-800/50"
            >
              <DeckTableRow
                :for={{dom_id, deck_with_stats} <- @streams.deck_stats}
                id={dom_id}
                deck_with_stats={deck_with_stats}
                show_win_loss?={@filter_context == :personal}
                user={@user}
                card_mode={@card_mode}
              />
            </tbody>
          </table>
        </div>

        <div
        :if={!@needs_login? and @view_mode != "table"}
        id="deck_stats_viewport"
        phx-update="stream"
        class="columns is-multiline is-mobile is-narrow is-centered"
        phx-target={@myself}
        phx-viewport-bottom={if @end_of_stream?, do: "", else: "next-decks-page"}>
          <div id={dom_id} :for={{dom_id, deck_with_stats} <- @streams.deck_stats} class="column is-narrow">
            <DeckWithStats deck_with_stats={deck_with_stats} show_win_loss?={@filter_context == :personal}/>
          </div>
        </div>
        <div :if={@needs_login?}>
          <br>
          <br>
          <br>
          <br>
          <div class="notification is-warning">
            You need to login to use these filters
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

  defp warning_if_public(:public, text), do: Components.Helper.warning_triangle(%{before: text})
  defp warning_if_public(_, text), do: text
  def can_access_unaggregated?(_, :personal), do: true
  def can_access_unaggregated?(%{id: _id, battletag: _btag}, :public), do: true
  def can_access_unaggregated?(_, _), do: false

  def handle_event("next-decks-page", _middle, socket) do
    %{offset: offset} = socket.assigns
    {_, %{"limit" => limit}} = parse_params(socket.assigns)
    new_offset = offset + limit
    {:noreply, stream_deck_stats(socket, new_offset)}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  defp warning?(%{deck_stats: %{inserts: []}}), do: true
  defp warning?(_), do: false

  defp parse_params(%{params: params} = assigns) do
    parse_params(params, assigns)
  end

  defp parse_params(raw_params, assigns) do
    {regions, context_based_defaults} =
      case assigns do
        %{filter_context: :public} ->
          {Hearthstone.DeckTracker.get_auto_aggregate_regions(), [{"exclude_bugged_sources", "yes"}]}

        _ ->
          {[], []}
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
      {"opponent_class", "any"},
      {"archetype", "any"},
      {"player_has_coin", "any"},
      {"rank", assigns.default_rank || RankDropdown.default(assigns.filter_context)}
      | context_based_defaults
    ]

    params =
      raw_params
      |> filter_relevant()
      |> apply_defaults(defaults)
      |> cap_param("limit", assigns.limit_cap)
      |> ensure_min_games()
      |> floor_param("min_games", assigns.min_games_floor)

    search_filters =
      assigns.additional_params
      |> Map.merge(params)
      |> Map.drop(["view_mode", "card_mode"])

    {params, search_filters}
  end

  defp ensure_min_games(%{"min_games" => min} = params) when is_integer(min), do: params

  defp ensure_min_games(%{"opponent_class" => oc} = params) when oc not in ["any", nil] do
    agg_min_games(params, 0.2)
  end

  defp ensure_min_games(%{"player_deck_archetype" => _} = params) do
    agg_min_games(params, 0.4)
  end

  defp ensure_min_games(%{"player_class" => pc} = params) when pc not in ["any", nil] do
    agg_min_games(params, 0.5)
  end

  defp ensure_min_games(params) do
    agg_min_games(params)
  end

  @supported_min_options [12_800, 6400, 3200, 1600, 800, 400, 200, 100]
  def agg_min_games(
        params,
        factor_multiplier \\ 1,
        default_min_games \\ @default_min_games
      ) do
    format_factor =
      case params["format"] do
        wild when wild in [1, "1", "wild", :wild] -> 0.3
        _ -> 1
      end

    rank_factor =
      case params["rank"] do
        r when r in ["bronze", "silver", "gold", "platinum", "diamond"] -> 0.5
        "top_100" -> 0.05
        "top_500" -> 0.15
        "legend_101_1000" -> 0.25
        "top_legend" -> 0.3
        "legend_1001_" -> 0.5
        "top_5k" -> 0.5
        "top_10k" -> 0.67
        "legend" -> 0.8
        "all" -> 1.4
        _ -> 1
      end

    min =
      with %Period{} = period <- DeckTracker.get_period_by_slug(params["period"]),
           {:ok, start_time} <- Period.start_time(period),
           {:ok, end_time} <- Period.end_time_or_now(period) do
        diff = NaiveDateTime.diff(end_time, start_time, :hour)

        period_factor =
          cond do
            diff < 24 ->
              200

            diff < 48 ->
              400

            diff < 72 ->
              800

            diff < 168 ->
              1600

            diff < 336 ->
              3200

            diff < 672 ->
              6400

            diff < 1344 ->
              12_800

            true ->
              25_600
          end

        factor = period_factor * rank_factor * format_factor * factor_multiplier

        Enum.find(@supported_min_options, default_min_games, fn c ->
          factor >= c
        end)
      else
        _ -> default_min_games
      end

    Map.put(params, "min_games", min)
  end

  defp modal_stats_filters(filters),
    do: Map.delete(filters, "min_games") |> Map.drop(["order_by", "direction", "limit"])

  # maybe unused?
  def handle_info({:update_params, params}, %{assigns: %{path_params: path_params, live_view: live_view}} = socket)
      when not is_nil(path_params) do
    path = Routes.live_path(socket, live_view, path_params, params)
    {:noreply, push_patch(socket, to: path)}
  end

  def limit_options, do: [10, 15, 20, 25, 30]

  def region_options,
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

  def show_winrate_dropdown?(params) do
    "winrate" != Map.get(params, "order_by", "winrate")
  end

  def order_by_options,
    do: [
      {"winrate", "Winrate %"},
      {"total", "Total Games"},
      {"turns", "Turns"},
      {"duration", "Duration"},
      {"cheapest_deck", "Cheapest Deck"},
      {"most_expensive_deck", "Most Expensive Deck"},
      {"newest_deck", "Newest Deck"},
      {"oldest_deck", "Oldest Deck"}
    ]

  def filter_relevant(params) do
    params
    |> Map.take([
      "rank",
      "period",
      "limit",
      "order_by",
      "direction",
      "player_class",
      "opponent_class",
      "format",
      "deck_format",
      "offset",
      "region",
      "min_games",
      "min_winrate",
      "player_deck_includes",
      "player_deck_excludes",
      "fresh_player_deck_includes",
      "fresh_player_deck_excludes",
      "exclude_bugged_sources",
      "archetype",
      "no_archetype",
      "opponent_archetype",
      "use_aggregated",
      "player_mulligan",
      "player_not_mulligan",
      "player_drawn",
      "player_not_drawn",
      "includes_latest_set",
      "player_kept",
      "player_not_kept",
      "force_fresh",
      "player_has_coin",
      "player_deck_archetype",
      "view_mode",
      "card_mode"
    ])
    |> parse_int([
      "limit",
      "min_games",
      "format",
      "deck_format",
      "offset",
      "player_mulligan",
      "player_not_mulligan",
      "player_drawn",
      "player_not_drawn",
      "player_kept",
      "player_not_kept",
      "fresh_player_deck_includes",
      "fresh_player_deck_excludes",
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

  defp build_live_path(assigns, params) do
    case assigns[:path_params] do
      nil ->
        Routes.live_path(BackendWeb.Endpoint, assigns[:live_view], params)

      path_params when is_list(path_params) ->
        apply(Routes, :live_path, [BackendWeb.Endpoint, assigns[:live_view] | path_params] ++ [params])

      path_param ->
        Routes.live_path(BackendWeb.Endpoint, assigns[:live_view], path_param, params)
    end
  end

  defp link_with_param(assigns, param, value) do
    params =
      (assigns[:actual_params] || %{})
      |> Map.put(param, value)

    build_live_path(assigns, params)
  end

  defp link_with_view_mode(assigns, mode), do: link_with_param(assigns, "view_mode", mode)
  defp link_with_card_mode(assigns, mode), do: link_with_param(assigns, "card_mode", mode)

  defp link_with_order_by(assigns, order_by) do
    params = assigns[:actual_params] || %{}
    active? = order_by_active?(params, order_by)
    current_dir = current_direction(params)

    new_dir =
      if active? do
        if current_dir == "asc", do: "desc", else: "asc"
      else
        "desc"
      end

    params
    |> Map.put("order_by", order_by)
    |> Map.put("direction", new_dir)
    |> then(&build_live_path(assigns, &1))
  end

  defp current_direction(params) do
    (params || %{})
    |> Map.get("direction", "desc")
    |> Util.sort_direction()
    |> to_string()
  end

  defp order_by_active?(params, key) do
    current = Map.get(params || %{}, "order_by", "winrate")
    current == key
  end
end
