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
          show_search={false}
          options={DeckTracker.regions_for_filters()}
          title={@title}
          param={@param}
          url_params={@url_params}
          path_params={@path_params}
          selected_params={@selected_params}
          selected_to_top={false}
          selected_as_title={false}
          default_selector={default_selector(@filter_context)}
          live_view={@live_view} />
      </span>
    """
  end

  def default(:public) do
    DeckTracker.get_auto_aggregate_regions()
  end

  def default(:personal) do
    DeckTracker.list_regions()
    |> Enum.map(& &1.code)
  end

  def default_selector(context) do
    fn _ -> default(context) end
  end
end
