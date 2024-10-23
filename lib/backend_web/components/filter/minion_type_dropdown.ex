defmodule Components.Filter.MinionTypeDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown

  prop(title, :string, default: "Minion Type")
  prop(param, :string, default: "minion_type")
  # constructed
  prop(game_mode, :integer, default: 1)
  prop(include_any?, :boolean, default: true)
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(live_view, :module, required: true)
  prop(options, :list, default: nil)

  def render(assigns) do
    ~F"""
    <span>
      <LivePatchDropdown
        options={options(@include_any?, @game_mode)}
        title={@title}
        param={@param}
        url_params={@url_params}
        path_params={@path_params}
        selected_params={@selected_params}
        live_view={@live_view} />
    </span>
    """
  end

  def options(include_any?, game_mode) do
    options =
      Backend.Hearthstone.minion_type_options(game_mode) |> Enum.sort_by(&elem(&1, 1), :asc)

    if include_any? do
      [{nil, "Any Minion Type"} | options]
    else
      options
    end
  end
end
