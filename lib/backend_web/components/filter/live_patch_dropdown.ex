defmodule Components.LivePatchDropdown do
  @moduledoc false
  use BackendWeb, :surface_component
  use Components.Filter.DropdownBase
  alias FunctionComponents.Dropdown

  prop(class, :css_class, default: nil)
  prop(warning, :boolean, default: false)

  @spec render(%{
          :normalizer => any,
          :selected_as_title => boolean,
          :title => any,
          optional(any) => any
        }) :: Phoenix.LiveView.Rendered.t()
  def render(assigns = %{actual_title: _}) do
    ~F"""
    <span>
      <Dropdown.menu title={@actual_title} class={[@class, "has-text-black", "tw-border-2 tw-rounded tw-border-orange-500": @warning]}>
        <Dropdown.item
          :for={opt <- @options}
          selected={@current == @normalizer.(value(opt))}
          class={@class}
          patch={link(BackendWeb.Endpoint, @live_view, @path_params, update_params(@url_params, @param, value(opt)))}>
          {display(opt)}
        </Dropdown.item>
      </Dropdown.menu>
    </span>
    """
  end

  def render(assigns), do: assigns |> add_title_current() |> render()
end
