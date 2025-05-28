defmodule Components.OpponentStatsTable do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.ClassStatsTable
  alias Hearthstone.DeckTracker
  alias Components.LivePatchDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.FormatDropdown
  alias Components.Filter.RegionDropdown
  alias Components.Filter.ForceFreshDropdown
  alias Components.Filter.PlayerHasCoinDropdown

  prop(live_view, :module, required: true)
  prop(params, :map, required: true)
  prop(path_params, :any, default: [])
  prop(target, :any, required: true)
  prop(user, :map, from_context: :user)
  prop(include_format, :boolean, default: false)
  data(needs_login?, :boolean, default: false)
  data(selected_params, :list, default: [])
  data(stats, :list, default: [])

  def update(assigns, socket_without_assigns) do
    socket = assign(socket_without_assigns, assigns)

    criteria =
      assigns.params
      |> Map.take(param_keys())
      |> Map.put_new("rank", RankDropdown.default())
      |> Map.put_new("period", PeriodDropdown.default(:public, assigns.params))
      |> Map.put_new("players", "all_players")
      |> Map.put_new("player_has_coin", "any")
      |> Components.DecksExplorer.parse_int(["format"])
      |> add_format(assigns.include_format)

    user = Map.get(socket.assigns, :user)

    {stats, needs_login?} =
      if :agg == DeckTracker.fresh_or_agg(criteria) or can_access_unaggregated?(user) do
        {stats(assigns.target, params(criteria, user)), false}
      else
        {[], true}
      end

    selected_params = add_region(criteria)

    {
      :ok,
      socket
      |> assign(selected_params: selected_params, stats: stats, needs_login?: needs_login?)
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        assigns.params,
        assigns.path_params,
        selected_params
      )
    }
  end

  defp can_access_unaggregated?(%{id: _id, battletag: _btag}), do: true
  defp can_access_unaggregated?(_), do: false
  defp add_format(params, true), do: Map.put_new(params, "format", 2)
  defp add_format(params, _false), do: params

  defp add_region(params = %{"players" => players}) do
    context = if players == "all_players", do: :public, else: :personal
    Map.put_new(params, "region", RegionDropdown.default(context))
  end

  def render(assigns) do
    ~F"""
    <div>
          <RankDropdown id="opp_stats_table_rank_dropdown" aggregated_only={aggregated_only?(@needs_login?, @selected_params)} filter_context={filter_context(@selected_params)}/>
          <PeriodDropdown id="opp_stats_table_period_dropdown" aggregated_only={aggregated_only?(@needs_login?, @selected_params)} filter_context={filter_context(@selected_params)}/>
          <RegionDropdown id="opp_stats_table_region_dropdown" :if={can_access_unaggregated?(@user)} />
          <FormatDropdown class={"is-hidden-mobile"} :if={@include_format} id="opp_stats_format_dropdown" aggregated_only={aggregated_only?(@needs_login?, @selected_params)} filter_context={filter_context(@selected_params)}/>
          <PlayerHasCoinDropdown id={"opp_stats_table_player_has_coin_dropdown"} />
          <ForceFreshDropdown id="opp_stats_table_force_fresh_dropdown" :if={Backend.UserManager.User.premium?(@user)} />
          <LivePatchDropdown :if={Backend.UserManager.User.battletag(@user)}
            options={[{"all_players", "All Players"}, {"my_games", "My Games"}]}
            title={"Players"}
            param={"players"} />
        <ClassStatsTable :if={@stats && !@needs_login?} stats={@stats} show_win_loss?={personal_context?(@selected_params)} />
        <div :if={@needs_login?}>
          <br>
          <br>
          <br>
          <br>
          <div class="notification is-warning">
            You need to login to use these filters
          </div>
        </div>
    </div>
    """
  end

  defp aggregated_only?(needs_login, selected_params) do
    !needs_login and !personal_context?(selected_params)
  end

  defp personal_context?(selected_params), do: :personal == filter_context(selected_params)
  defp filter_context(%{"players" => "my_games"}), do: :personal
  defp filter_context(_), do: :public
  def stats(nil, _), do: []

  def stats(target, params) do
    DeckTracker.detailed_stats(target, params)
  end

  defp params(selected, user) do
    selected
    |> Map.pop("players", "all_players")
    |> set_user_param(user)
    |> Enum.to_list()
  end

  defp set_user_param({"my_games", params}, %{battletag: battletag}),
    do: params |> Map.put_new("player_btag", battletag)

  defp set_user_param({_, params}, _), do: params

  def param_keys(),
    do: ["rank", "period", "players", "region", "format", "force_fresh", "player_has_coin"]
end
