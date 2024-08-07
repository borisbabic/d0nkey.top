defmodule Components.Filter.FormatDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker

  prop(title, :string, default: "Format")
  prop(param, :string, default: "format")
  prop(options, :list, default: nil)
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(filter_context, :atom, default: :public)
  prop(live_view, :module, required: true)
  prop(aggregated_only, :boolean, default: false)
  prop(class, :css_class, default: nil)

  def render(assigns) do
    ~F"""
    <span>
      <LivePatchDropdown
        options={options(@options, @filter_context, @aggregated_only)}
        title={@title}
        class={@class}
        param={@param}
        url_params={@url_params}
        path_params={@path_params}
        selected_params={@selected_params}
        live_view={@live_view} />
    </span>
    """
  end

  def options(options, context, only_aggregated \\ false)

  def options(options, _, _) when is_list(options) do
    options
  end

  def options(nil, context, only_aggregated) do
    aggregated =
      DeckTracker.get_latest_agg_log_entry()
      |> Map.get(:formats, []) || []

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
