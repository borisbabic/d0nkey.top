defmodule Components.Filter.ClassDropdown do
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  alias Backend.Hearthstone.Deck

  prop(title, :string, default: "Class")
  prop(param, :string, default: "class")
  prop(any_name, :string, default: "Any Class")
  prop(name_prefix, :string, default: "")
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(live_view, :module, required: true)
  prop(include_neutral, :boolean, default: false)
  prop(options, :any, default: nil)

  def render(assigns) do
    ~F"""
      <span>
        <LivePatchDropdown
          options={options(@any_name, @name_prefix, @include_neutral, @options)}
          title={@title}
          param={@param}
          url_params={@url_params}
          path_params={@path_params}
          selected_params={@selected_params}
          live_view={@live_view} />
      </span>
    """
  end

  def options(any_name, name_prefix, include_neutral?, options) do
    any = {nil, any_name}
    classes = if is_list(options), do: options, else: Deck.classes()
    class_options = Enum.map(classes, &{&1, "#{name_prefix}#{Deck.class_name(&1)}"})

    if include_neutral? do
      [any, {"neutral", "Neutral"} | class_options]
    else
      [any | class_options]
    end
  end
end
