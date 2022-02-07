defmodule Components.DeckStatsTable do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.ClassStatsTable
  alias Components.DecksExplorer
  alias Hearthstone.DeckTracker
  alias Components.LivePatchDropdown

  prop(live_view, :module, required: true)
  prop(params, :map, required: true)
  prop(path_params, :list, default: [])
  prop(deck_id, :integer, required: true)

  def render(assigns) do
    selected_params =
      assigns.params
      |> Map.take(param_keys())
      |> Map.put_new("rank", "diamond_to_legend")
      |> Map.put_new("period", "past_week")
      |> Map.put_new("players", "all_players")
    ~F"""
    <div>
      <Context get={user: user}>
        <LivePatchDropdown
          options={DecksExplorer.rank_options()}
          path_params={@path_params}
          title={"Rank"}
          param={"rank"}
          url_params={@params}
          selected_params={selected_params}
          live_view={@live_view} />

        <LivePatchDropdown
          options={DecksExplorer.default_period_options()}
          path_params={@path_params}
          title={"Period"}
          param={"period"}
          url_params={@params}
          selected_params={selected_params}
          live_view={@live_view} />

          <LivePatchDropdown :if={Backend.UserManager.User.battletag(user)}
            options={[{"all_players", "All Players"}, {"my_games", "My Games"}]}
            path_params={@path_params}
            title={"Players"}
            param={"players"}
            url_params={@params}
            selected_params={selected_params}
            live_view={@live_view} />
        <ClassStatsTable :if={stats = stats(@deck_id, params(selected_params, user))} stats={stats} />
      </Context>
    </div>
    """
  end

  def stats(nil, _), do: []
  def stats(deck_id, params) do
    DeckTracker.detailed_stats(deck_id, params)
  end
  defp params(selected, user) do
    selected
    |> Map.pop("players", "all_players")
    |> set_user_param(user)
    |> Enum.to_list()
  end
  defp set_user_param({"my_games", params}, %{battletag: battletag}), do: params |> Map.put_new("player_btag", battletag)
  defp set_user_param({_, params}, _), do: params
  def param_keys(), do: ["rank", "period", "players"]

end
