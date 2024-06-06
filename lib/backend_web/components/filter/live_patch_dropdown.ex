defmodule Components.LivePatchDropdown do
  @moduledoc false
  use BackendWeb, :surface_component
  use Components.Filter.DropdownBase
  alias Components.Dropdown
  alias Surface.Components.LivePatch

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
      <Dropdown title={@actual_title} class={@class, "tw-border-2 tw-rounded tw-border-orange-500": @warning}>
        <div :for={opt <- @options}>
          <LivePatch
            class={"dropdown-item", @class, "is-active": @current == @normalizer.(value(opt))}
            to={link(BackendWeb.Endpoint, @live_view, @path_params, update_params(@url_params, @param, value(opt)))}>
            {display(opt)}
          </LivePatch>
        </div>
      </Dropdown>
    """
  end

  def render(assigns), do: assigns |> add_title_current() |> render()
end
