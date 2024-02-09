defmodule Components.Filter.RegionDropdown do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.MultiSelectDropdown
  alias Hearthstone.DeckTracker

  prop(title, :string, default: "Region")
  prop(param, :string, default: "region")
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(filter_context, :atom, default: :public)
  prop(live_view, :module, required: true)

  def render(assigns) do
    ~F"""
      <span>
        <MultiSelectDropdown
          id={"#{@id}_ms_id"}
          show_search={true}
          options={DeckTracker.regions_for_filters()}
          title={@title}
          param={@param}
          url_params={@url_params}
          path_params={@path_params}
          selected_params={@selected_params}
          default_selector={&default_selector/1}
          live_view={@live_view} />
      </span>
    """
  end

  def default(:public) do
    DeckTracker.get_auto_aggregate_regions()
  end

  def default(:private) do
    DeckTracker.list_regions()
    |> Enum.map(& &1.code)
  end

  def default_selector(%{filter_context: context}) do
    default(context)
  end
end
