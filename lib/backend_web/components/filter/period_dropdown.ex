defmodule Components.Filter.PeriodDropdown do
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  prop(title, :string, default: "Period")
  prop(param, :string, default: "Param")
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(filter_context, :atom, default: :public)
  prop(live_view, :module, required: true)

  def render(assigns) do
    ~F"""
      <LivePatchDropdown
        options={options(@filter_context)}
        title={"Period"}
        param={"period"}
        url_params={@url_params}
        path_params={@path_params}
        selected_params={@selected_params}
        live_view={@live_view} />
    """
  end

  def options(context) do
    Hearthstone.DeckTracker.period_filters(context)
  end
end
