defmodule Components.Filter.ManaCostDropdown do
  use Surface.LiveComponent
  alias Components.LivePatchDropdown

  prop(title, :string, default: "Mana Cost")
  prop(param, :string, default: "mana_cost")
  prop(max_specified, :integer, default: 10)
  prop(min_specified, :integer, default: 0)
  prop(any_name, :string, default: "Any Cost")
  prop(title_prefix, :string, default: "Cost ")
  prop(specified_prefix, :string, default: "")
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(live_view, :module, required: true)

  def render(assigns) do
    ~F"""
      <LivePatchDropdown
        options={options(@min_specified, @max_specified, @specified_prefix, @any_name)}
        title={@title}
        param={@param}
        url_params={@url_params}
        path_params={@path_params}
        selected_params={@selected_params}
        selected_as_title_prefix={@title_prefix}
        live_view={@live_view} />
    """
  end

  def options(min_specified, max_specified, specified_prefix, any_name) do
    specified =
      Enum.map(min_specified..max_specified, &{to_string(&1), "#{specified_prefix}#{&1}"})

    [{nil, any_name} | specified] ++ [">#{max_specified}"]
  end
end
