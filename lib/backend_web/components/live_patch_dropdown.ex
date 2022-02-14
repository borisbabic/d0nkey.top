defmodule Components.LivePatchDropdown do
  @moduledoc false
  use Surface.Component
  alias Components.Dropdown
  alias Surface.Components.LivePatch
  alias BackendWeb.Router.Helpers, as: Routes
  # either a list of {value, display} tuples, or a list of one value when value == display
  prop(options, :list, required: true)
  prop(param, :string, required: true)
  prop(live_view, :any, required: true)
  prop(path_params, :struct, default: nil)
  prop(url_params, :map, required: true)
  prop(title, :string, required: false)

  # If the params we want to use to decide whether it's selected differ from the url params
  prop(selected_params, :map, required: false)
  prop(selected_as_title, :boolean, default: true)

  prop(current_val, :any, required: false)
  prop(normalizer, :fun, required: false)

  @spec render(%{
          :normalizer => any,
          :selected_as_title => boolean,
          :title => any,
          optional(any) => any
        }) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    normalizer = assigns.normalizer || & &1
    current = current(assigns, normalizer)
    title = title(assigns, current, normalizer)
    ~F"""
      <Dropdown title={title}>
        <div :for={opt <- @options}>
          <LivePatch
            class={"dropdown-item", "is-active": current == normalizer.(value(opt))}
            to={link(@socket, @live_view, @path_params, update_params(@url_params, @param, value(opt)))}>
            {display(opt)}
          </LivePatch>
        </div>
      </Dropdown>
    """
  end

  def link(socket, live_view, nil, params) do
    Routes.live_path(socket, live_view, params)
  end
  def link(socket, live_view, path_params, params) do
    Routes.live_path(socket, live_view, path_params, params)
  end

  def update_params(url_params, param, nil), do: Map.delete(url_params, param)
  def update_params(url_params, param, val), do: Map.put(url_params, param, val)

  def title(%{selected_as_title: false, title: title}, _, _), do: title
  def title(%{selected_as_title: true, title: title, options: options}, current, normalizer), do:
    Enum.find_value(options, title, & normalizer.(value(&1)) == current && display(&1))

  def value({value, _display}), do: value
  def value(value), do: value

  def display({_value, display}), do: display
  def display(display), do: display

  def current(%{current_val: curr}, normalizer) when not is_nil(curr), do: normalizer.(curr)

  def current(%{selected_params: params, param: param}, normalizer) when not is_nil(params),
    do: do_current(params, param, normalizer)

  def current(%{url_params: params, param: param}, normalizer),
    do: do_current(params, param, normalizer)
  def current(_, _), do: nil

  defp do_current(params, param, normalizer) do
    with curr when not is_nil(curr) <- Map.get(params, param) do
      normalizer.(curr)
    end
  end
end
