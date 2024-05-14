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
  prop(aggregated_only, :boolean, default: false)

  def render(assigns) do
    ~F"""
      <LivePatchDropdown
        options={options(@filter_context, @aggregated_only)}
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
      |> Map.get(:periods, []) || []

    for %{slug: slug, display: d} <- periods(context),
        !aggregated_only or slug in aggregated do
      display =
        if slug in aggregated or context == :personal,
          do: d,
          else: Components.Helper.warning_triangle(%{before: d})

      {slug, display}
    end
  end

  defp periods(context) do
    DeckTracker.periods_for_filters(context)
    |> Enum.reject(&future?/1)
  end

  defp future?(%{period_start: %NaiveDateTime{} = period_start}) do
    NaiveDateTime.compare(period_start, NaiveDateTime.utc_now()) == :gt
  end

  defp future?(_), do: false

  def default(_context \\ :public) do
    DeckTracker.default_period()
  end
end
