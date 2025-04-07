defmodule Components.ReplayExplorer do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker
  alias Components.ClassStatsModal
  alias Components.Filter.PlayerHasCoinDropdown
  alias Components.Filter.PlayableCardSelect
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.RegionDropdown
  alias Components.Filter.FormatDropdown
  alias Components.Filter.ClassDropdown
  alias Components.Filter.PrevButton
  alias Components.Filter.NextButton
  alias Components.DecksExplorer
  alias Components.ReplaysTable
  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput
  alias Components.Filter.ArchetypeSelect

  prop(default_order_by, :string, default: "latest")
  prop(default_format, :number, default: nil)
  prop(default_limit, :number, default: 20)
  prop(default_rank, :string, default: nil)
  prop(default_period, :string, default: nil)
  prop(live_view, :module, required: true)
  prop(additional_params, :map, default: %{})
  prop(params, :map, required: true)
  prop(path_params, :any, default: nil)

  prop(show_player_btag, :boolean, default: false)
  prop(show_deck, :boolean, default: true)
  prop(hide_deck_mobile, :boolean, default: false)
  prop(show_opponent, :boolean, default: true)
  prop(show_opponent_name, :boolean, default: true)
  prop(show_mode, :boolean, default: true)
  prop(show_rank, :boolean, default: true)
  prop(show_replay_link, :boolean, default: true)
  prop(show_played, :boolean, default: true)
  prop(show_result_as, :list, default: [:mode])

  prop(format_filter, :boolean, default: true)
  prop(rank_filter, :boolean, default: true)
  prop(period_filter, :boolean, default: true)
  prop(region_filter, :boolean, default: true)
  prop(filter_context, :atom, default: :public)
  prop(archetype_filter, :boolean, default: true)
  prop(player_class_filter, :boolean, default: true)
  prop(opponent_class_filter, :boolean, default: true)
  prop(includes_filter, :boolean, default: true)
  prop(excludes_filter, :boolean, default: true)
  prop(class_stats_modal, :boolean, default: true)
  prop(public_only, :boolean, default: true)
  prop(search_filter, :boolean, default: true)
  prop(player_coin_filter, :boolean, default: true)
  prop(card_specific_filters, :boolean, default: true)
  data(search_filters, :any)
  data(selected_params, :map)
  data(replays, :any)

  def update(assigns, socket) do
    {selected_params, search_filters} = parse_params(assigns.params, assigns)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(selected_params: selected_params, search_filters: search_filters)
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        assigns.params,
        assigns.path_params,
        selected_params
      )
      |> assign_async(:replays, fn -> {:ok, %{replays: DeckTracker.games(search_filters)}} end)
    }
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
      <div>
        <div>
          <div class="">
          <PrevButton default_limit={@default_limit} />
          <NextButton default_limit={@default_limit} />
          <FormatDropdown id="format_dropdown" :if={@format_filter} filter_context={@filter_context} />
          <RankDropdown id="rank_dropdown" :if={@rank_filter} filter_context={@filter_context} />
          <PeriodDropdown id="period_dropdown" :if={@period_filter} filter_context={@filter_context} />
          <RegionDropdown id="region_dropdown" :if={@region_filter} filter_context={@filter_context} />
          <LivePatchDropdown
            options={[{nil, "Any"}, {"win", "Win"}, {"loss", "Loss"}, {"draw", "Draw"}]}
            title={"Result"}
            param={"status"}
            selected_as_title={true}
            use_nil_val_as_title={false}
          />
          <ArchetypeSelect :if={@archetype_filter} id={"player_deck_archetype"} param={"player_deck_archetype"} selected={@params["player_deck_archetype"] || []} title="Archetypes" />
          <ClassDropdown :if={@player_class_filter} id="player_class_dropdown"
            param={"player_class"} />
          <ClassDropdown :if={@opponent_class_filter} id="opponent_class_dropdown"
            any_name={"Any Opponent"}
            name_prefix={"VS "}
            param={"opponent_class"} />

          <PlayableCardSelect format={@params["format"]} :if={@includes_filter} id={"player_deck_includes"} param={"player_deck_includes"} selected={@params["player_deck_includes"] || []} title="Include cards"/>
          <PlayableCardSelect format={@params["format"]} :if={@excludes_filter} id={"player_deck_excludes"} param={"player_deck_excludes"} selected={@params["player_deck_excludes"] || []} title="Exclude cards"/>
          <PlayerHasCoinDropdown :if={@player_coin_filter} id={"player_has_coin_dropdown"} warning_triangle={false} />

          {#if @card_specific_filters }
            <PlayableCardSelect format={@params["format"]} id={"player_mulligan"} param={"player_mulligan"} selected={@params["player_mulligan"] || []} title="In Mulligan"/>
            <PlayableCardSelect format={@params["format"]} id={"player_not_mulligan"} param={"player_not_mulligan"} selected={@params["player_not_mulligan"] || []} title="Not In Mulligan"/>
            <PlayableCardSelect format={@params["format"]} id={"player_drawn"} param={"player_drawn"} selected={@params["player_drawn"] || []} title="Drawn"/>
            <PlayableCardSelect format={@params["format"]} id={"player_not_drawn"} param={"player_not_drawn"} selected={@params["player_not_drawn"] || []} title="Not Drawn"/>
            <PlayableCardSelect format={@params["format"]} id={"player_kept"} param={"player_kept"} selected={@params["player_kept"] || []} title="Kept"/>
            <PlayableCardSelect format={@params["format"]} id={"player_not_kept"} param={"player_not_kept"} selected={@params["player_not_kept"] || []} title="Not Kept"/>
          {/if}
          <ClassStatsModal :if={@class_stats_modal} class="dropdown" id="class_stats_modal" get_stats={fn -> @search_filters |> DeckTracker.class_stats() end} title="Class Stats" />
          <Form :if={@search_filter} for={%{}} as={:search} change="change" submit="change">
            <TextInput class={"input"} opts={placeholder: "Search opponent"}/>
          </Form>
        </div>

        <div :if={@replays.loading}>
          Loading replays...
        </div>
        <div :if={@replays.ok? && @replays.result}>
          <ReplaysTable
          show_player_btag={@show_player_btag}
          show_deck={@show_deck}
          hide_deck_mobile={@hide_deck_mobile}
          show_opponent={@show_opponent}
          show_opponent_name={@show_opponent_name}
          show_mode={@show_mode}
          show_rank={@show_rank}
          show_replay_link={@show_replay_link}
          show_result_as={@show_result_as}
          show_played={@show_played}
          replays={@replays.result}/>
          <div :if={!(Enum.any?(@replays.result))} >
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
    default_format = assigns.default_format || FormatDropdown.default(assigns.filter_context)

    defaults = [
      {"limit", assigns.default_limit},
      {"format", default_format},
      {"rank", assigns.default_rank || RankDropdown.default(assigns.filter_context)},
      {"period",
       assigns.default_period ||
         PeriodDropdown.default(assigns.filter_context, raw_params, default_format)},
      {"order_by", assigns.default_order_by}
    ]

    params =
      raw_params
      |> filter_relevant()
      |> DecksExplorer.apply_defaults(defaults)

    search_filters = Map.merge(assigns.additional_params, params)
    {params, search_filters}
  end

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
      "status",
      "region",
      "player_deck_includes",
      "player_deck_excludes",
      "player_deck_archetype",
      "player_mulligan",
      "player_not_mulligan",
      "player_drawn",
      "player_deck_id",
      "player_not_drawn",
      "player_kept",
      "player_not_kept",
      "player_has_coin",
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
