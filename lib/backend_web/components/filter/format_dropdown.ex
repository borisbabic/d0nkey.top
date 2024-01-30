defmodule Components.Filter.FormatDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker

  prop(title, :string, default: "Format")
  prop(param, :string, default: "format")
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

  def options(context, only_aggregated \\ false) do
    aggregated =
      DeckTracker.get_latest_agg_log_entry()
      |> Map.get(:formats, [])

    for %{value: value, display: d} <- DeckTracker.formats_for_filters(context),
        !only_aggregated or value in aggregated do
      display =
        if value in aggregated or context == :personal,
          do: d,
          else: Components.Helper.warning_triangle(%{before: d})

      {value, display}
    end
  end

  def default(context \\ :public) do
    DeckTracker.default_format(context)
  end
end
