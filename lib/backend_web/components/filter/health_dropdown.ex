defmodule Components.Filter.HealthDropdown do
  use Surface.LiveComponent
  alias Components.LivePatchDropdown

  prop(title, :string, default: "Health")
  prop(param, :string, default: "health")
  prop(max_specified, :integer, default: 12)
  prop(min_specified, :integer, default: 1)
  prop(any_name, :string, default: "Any Health")
  prop(title_prefix, :string, default: "Health ")
  prop(specified_prefix, :string, default: "")
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(live_view, :module, required: true)

  def render(assigns) do
    ~F"""
    <span>
      <LivePatchDropdown
        options={options(@min_specified, @max_specified, @specified_prefix, @any_name)}
        title={@title}
        param={@param}
        url_params={@url_params}
        path_params={@path_params}
        selected_params={@selected_params}
        selected_as_title_prefix={@title_prefix}
        live_view={@live_view} />
    </span>
    """
  end

  def options(min_specified, max_specified, specified_prefix, any_name) do
    specified =
      Enum.map(min_specified..max_specified, &{to_string(&1), "#{specified_prefix}#{&1}"})

    [{nil, any_name} | specified] ++ [">#{max_specified}"]
  end
end
