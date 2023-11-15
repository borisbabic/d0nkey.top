defmodule Components.Filter.PeriodDropdown do
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker
  prop(title, :string, default: "Period")
  prop(param, :string, default: "period")
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(filter_context, :atom, default: :public)
  prop(live_view, :module, required: true)

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

  def options(context) do
    %{periods: aggregated} = DeckTracker.get_latest_agg_log_entry()

    for %{slug: slug, display: d} <- DeckTracker.periods_for_filters(context) do
      display =
        if slug in (aggregated || []),
          do: d,
          else: Components.Helper.warning_triangle(%{before: d})

      {slug, display}
    end
  end

  def default(_context \\ :public) do
    DeckTracker.default_period()
  end
end
