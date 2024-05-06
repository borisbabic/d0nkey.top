defmodule Components.OpponentStatsTable do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.ClassStatsTable
  alias Hearthstone.DeckTracker
  alias Components.LivePatchDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RegionDropdown

  prop(live_view, :module, required: true)
  prop(params, :map, required: true)
  prop(path_params, :any, default: [])
  prop(target, :any, required: true)
  prop(user, :map, from_context: :user)
  data(selected_params, :list, default: [])

  def update(assigns, socket) do
    selected_params =
      assigns.params
      |> Map.take(param_keys())
      |> Map.put_new("rank", RankDropdown.default())
      |> Map.put_new("period", PeriodDropdown.default())
      |> Map.put_new("players", "all_players")
      |> add_region()

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(selected_params: selected_params)
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        assigns.params,
        assigns.path_params,
        selected_params
      )
    }
  end

  defp add_region(params = %{"players" => players}) do
    context = if players == "all_players", do: :public, else: :personal
    Map.put_new(params, "region", RegionDropdown.default(context))
  end

  def render(assigns) do
    ~F"""
    <div>
        <RankDropdown id="opp_stats_table_rank_dropdown"/>
        <PeriodDropdown id="opp_stats_table_period_dropdown" />
        <RegionDropdown id="opp_stats_table_region_dropdown" />

          <LivePatchDropdown :if={Backend.UserManager.User.battletag(@user)}
            options={[{"all_players", "All Players"}, {"my_games", "My Games"}]}
            title={"Players"}
            param={"players"} />
        <ClassStatsTable :if={stats = stats(@target, params(@selected_params, @user))} stats={stats} />
    </div>
    """
  end

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
  def param_keys(), do: ["rank", "period", "players", "region"]
end
