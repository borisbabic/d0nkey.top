defmodule Components.Filter.SpellSchoolDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown

  prop(title, :string, default: "Spell School")
  prop(param, :string, default: "spell_school")
  prop(include_any?, :boolean, default: true)
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(option_filter, :fun, default: &__MODULE__.filter_out_trinkets/1)
  prop(live_view, :module, required: true)
  prop(options, :list, default: nil)

  def render(assigns) do
    ~F"""
    <span>
      <LivePatchDropdown
        options={options(@include_any?, @option_filter)}
        title={@title}
        param={@param}
        url_params={@url_params}
        path_params={@path_params}
        selected_params={@selected_params}
        live_view={@live_view} />
    </span>
    """
  end

  def options(include_any?, option_filter) do
    options =
      Backend.Hearthstone.spell_school_options()
      |> Enum.sort_by(&elem(&1, 1), :asc)
      |> Enum.filter(option_filter)

    if include_any? do
      [{nil, "Any Spell School"} | options]
    else
      options
    end
  end

  def filter_out_trinkets({slug, _name}), do: !(slug =~ "trinket")
end
