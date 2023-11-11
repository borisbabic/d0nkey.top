defmodule Components.ReplayExplorer do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker
  alias Components.ClassStatsModal
  alias Components.Filter.PlayableCardSelect
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
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
  prop(default_rank, :string, default: "diamond_to_legend")
  prop(live_view, :module, required: true)
  prop(additional_params, :map, default: %{})
  prop(params, :map, required: true)
  prop(path_params, :any, default: nil)

  prop(show_player_btag, :boolean, default: false)
  prop(show_deck, :boolean, default: true)
  prop(show_opponent, :boolean, default: true)
  prop(show_mode, :boolean, default: true)
  prop(show_rank, :boolean, default: true)
  prop(show_replay_link, :boolean, default: true)
  prop(show_played, :boolean, default: true)

  prop(format_filter, :boolean, default: true)
  prop(rank_filter, :boolean, default: true)
  prop(period_filter, :boolean, default: true)
  prop(filter_context, :atom, default: :public)
  prop(player_class_filter, :boolean, default: true)
  prop(opponent_class_filter, :boolean, default: true)
  prop(includes_filter, :boolean, default: true)
  prop(excludes_filter, :boolean, default: true)
  prop(class_stats_modal, :boolean, default: true)
  prop(search_filter, :boolean, default: true)

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        assigns.params,
        assigns.path_params
      )
    }
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
      <div>
        <div :if={{params, search_filters} = parse_params(@params, assigns)}>
          <div class="level is-mobile level-left">
            <LivePatchDropdown :if={@format_filter}
            options={format_options()}
            title={"Format"}
            param={"format"}
            normalizer={&to_string/1} />

          <RankDropdown id="rank_dropdown" :if={@rank_filter} filter_context={@filter_context} />
          <PeriodDropdown id="period_dropdown" :if={@period_filter} filter_context={@filter_context} />

          <LivePatchDropdown :if={@player_class_filter}
            options={DecksExplorer.class_options("Any Class")}
            title={"Class"}
            param={"player_class"} />

          <LivePatchDropdown :if={@opponent_class_filter}
            options={DecksExplorer.class_options("Any Opponent")}
            title={"Opponent Class"}
            param={"opponent_class"} />

          <PlayableCardSelect :if={@includes_filter} id={"player_deck_includes"} update_fun={PlayableCardSelect.update_cards_fun(@params, "player_deck_includes")} selected={params["player_deck_includes"] || []} title="Include cards"/>
          <PlayableCardSelect :if={@excludes_filter} id={"player_deck_excludes"} update_fun={PlayableCardSelect.update_cards_fun(@params, "player_deck_excludes")} selected={params["player_deck_excludes"] || []} title="Exclude cards"/>
          <ClassStatsModal :if={@class_stats_modal} class="dropdown" id="class_stats_modal" get_stats={fn -> search_filters |> DeckTracker.class_stats() end} title="Class Stats" />
          <Form :if={@search_filter} for={%{}} as={:search} change="change" submit="change">
            <TextInput class={"input"} opts={placeholder: "Search opponent"}/>
          </Form>
        </div>

        <div :if={replays = DeckTracker.games(search_filters)}>
          <ReplaysTable
          show_player_btag={@show_player_btag}
          show_deck={@show_deck}
          show_opponent={@show_opponent}
          show_mode={@show_mode}
          show_rank={@show_rank}
          show_replay_link={@show_replay_link}
          show_played={@show_played}
          replays={replays}/>
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
      {"order_by", assigns.default_order_by}
    ]

    params =
      raw_params
      |> filter_relevant()
      |> DecksExplorer.apply_defaults(defaults)

    search_filters = Map.merge(assigns.additional_params, params)
    {params, search_filters}
  end

  def format_options(), do: [{"all", "All Formats"} | DecksExplorer.format_options()]

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
      "offset",
      "region",
      "player_deck_includes",
      "player_deck_excludes",
      "opponent_btag_like"
    ])
    |> DecksExplorer.parse_int([
      "limit",
      "format",
      "offset",
      "player_deck_includes",
      "player_deck_excludes"
    ])
  end
end
