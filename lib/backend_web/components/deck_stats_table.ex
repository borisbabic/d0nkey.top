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
    ~F"""
    <div>
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

        <ClassStatsTable :if={stats = DeckTracker.detailed_stats(@deck_id, Enum.to_list(selected_params))} stats={stats} />
    </div>
    """
  end
  def param_keys(), do: ["rank", "period"]

end
