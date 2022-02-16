defmodule Components.ReplayExplorer do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker
  alias Components.ClassStatsModal
  alias Components.Filter.PlayableCardSelect
  alias Components.DecksExplorer
  alias Components.ReplaysTable
  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput

  # @default_limit 15
  # @max_limit 30
  # @min_min_games 50
  # @default_min_games 100
  # # standard
  # @default_format 2
  # @default_order_by "winrate"
  # data(user, :any)

  prop(default_order_by, :string, default: "latest")
  prop(default_format, :number, default: "all")
  prop(default_limit, :number, default: 20)
  prop(period_options, :list, default: Components.DecksExplorer.default_period_options())
  prop(extra_period_options, :list, default: [])
  prop(default_rank, :string, default: "diamond_to_legend")
  prop(live_view, :module, required: true)
  prop(additional_params, :map, default: %{})
  prop(params, :map, required: true)
  prop(path_params, :any, default: nil)
  prop(show_player_btag, :boolean, default: false)

  def render(assigns) do

    ~F"""
    <div>
      <div :if={{params, search_filters} = parse_params(@params, assigns)}>
        <div class="level is-mobile level-left">
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
            options={DecksExplorer.rank_options()}
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
            options={DecksExplorer.class_options("Any Class")}
            title={"Class"}
            param={"player_class"}
            url_params={@params}
            path_params={@path_params}
            selected_params={params}
            live_view={@live_view} />

          <LivePatchDropdown
            options={DecksExplorer.class_options("Any Opponent")}
            title={"Opponent Class"}
            param={"opponent_class"}
            url_params={@params}
            path_params={@path_params}
            selected_params={params}
            live_view={@live_view} />

          <PlayableCardSelect id={"player_deck_includes"} update_fun={PlayableCardSelect.update_cards_fun(@params, "player_deck_includes")} selected={params["player_deck_includes"] || []} title="Include cards"/>
          <PlayableCardSelect id={"player_deck_excludes"} update_fun={PlayableCardSelect.update_cards_fun(@params, "player_deck_excludes")} selected={params["player_deck_excludes"] || []} title="Exclude cards"/>
          <ClassStatsModal class="dropdown" id="class_stats_modal" get_stats={fn -> search_filters |> DeckTracker.class_stats() end} title="Class Stats" />
          <Form for={:search} change="change" submit="change">
            <TextInput class={"input"} opts={placeholder: "Search opponent"}/>
          </Form>
        </div>

        <div :if={replays = DeckTracker.games(search_filters)}>
          <ReplaysTable show_player_btag={@show_player_btag} replays={replays}/>
          <div :if={!(Enum.any?(replays))} >
            <br>
            <br>
            <br>
            <br>
            No replays available for these filters
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("change", %{"search" => [search]}, socket) do
    {:noreply, update_search(socket, search)}
  end

  def update_search(socket = %{assigns: %{params: p}}, search) do
    p = Map.put(p, "opponent_btag_like", search)
    assign(socket, params: p)
  end

  defp parse_params(raw_params, assigns) do
    defaults = [
      {"limit", assigns.default_limit},
      {"format", assigns.default_format},
      {"order_by", assigns.default_order_by},
    ]

    params = raw_params
    |> filter_relevant()
    |> DecksExplorer.apply_defaults(defaults)
    search_filters = Map.merge(assigns.additional_params, params)
    {params, search_filters}
  end

  def format_options(), do: [{"all", "All Formats"} | DecksExplorer.format_options()]

  def filter_relevant(params) do
    params
    |> Map.take(["rank", "period", "limit", "order_by", "player_class", "opponent_class", "format", "offset", "region", "player_deck_includes", "player_deck_excludes", "opponent_btag_like"])
    |> DecksExplorer.parse_int(["limit", "format", "offset", "player_deck_includes", "player_deck_excludes"])
  end
end
