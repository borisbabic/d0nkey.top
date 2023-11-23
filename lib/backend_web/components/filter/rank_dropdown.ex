defmodule Components.Filter.RankDropdown do
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker
  prop(title, :string, default: "Rank")
  prop(param, :string, default: "rank")
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(filter_context, :atom, default: :public)
  prop(live_view, :module, required: true)
  prop(aggregated_only, :boolean, default: false)

  def render(assigns) do
    ~F"""
      <LivePatchDropdown
        options={options(@filter_context)}
        title={@title}
        param={@param}
        url_params={@url_params}
        path_params={@path_params}
        selected_params={@selected_params}
        live_view={@live_view} />
    """
  end

  def options(context, aggregated_only \\ false) do
    aggregated =
      DeckTracker.get_latest_agg_log_entry()
      |> Map.get(:ranks, [])

    for %{slug: slug, display: d} <- DeckTracker.ranks_for_filters(context),
        !aggregated_only or slug in aggregated do
      display =
        if slug in aggregated,
          do: d,
          else: Components.Helper.warning_triangle(%{before: d})

      {slug, display}
    end
  end

  def default(context \\ :public) do
    DeckTracker.default_rank(context)
  end
end
