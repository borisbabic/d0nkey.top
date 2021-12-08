defmodule Components.DeckStatsTable do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.ClassStatsTable
  alias BackendWeb.DecksLive
  alias Hearthstone.DeckTracker
  alias Components.LivePatchDropdown

  prop(live_view, :module, required: true)
  prop(params, :map, required: true)
  prop(path_params, :list, default: [])
  prop(deck_id, :integer, required: true)

  def render(assigns) do
    ~F"""
    <div>
        <LivePatchDropdown
          options={DecksLive.rank_options()}
          path_params={@path_params}
          title={"Rank"}
          param={"rank"}
          url_params={@params}
          live_view={@live_view} />

        <LivePatchDropdown
          options={DecksLive.period_options()}
          path_params={@path_params}
          title={"Period"}
          param={"period"}
          url_params={@params}
          live_view={@live_view} />

        <ClassStatsTable :if={stats = stats(@deck_id, @params)} stats={stats} />
    </div>
    """
  end

  def stats(id, raw_params) do
    params =
      raw_params
      |> Map.take(param_keys())
      |> Map.put_new("rank", "diamond_to_legend")
      |> Map.put_new("period", "past_week")
      |> Enum.to_list()

    DeckTracker.detailed_stats(id, params)
  end

  def param_keys(), do: ["rank", "period"]

end
