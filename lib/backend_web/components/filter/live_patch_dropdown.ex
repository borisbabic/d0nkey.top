defmodule Components.LivePatchDropdown do
  @moduledoc false
  use BackendWeb, :surface_component
  use Components.Filter.DropdownBase
  alias Components.Dropdown
  alias Surface.Components.LivePatch

  @spec render(%{
          :normalizer => any,
          :selected_as_title => boolean,
          :title => any,
          optional(any) => any
        }) :: Phoenix.LiveView.Rendered.t()
  def render(assigns = %{actual_title: _}) do
    ~F"""
      <Dropdown title={@actual_title}>
        <div :for={opt <- @options}>
          <LivePatch
            class={"dropdown-item", "is-active": @current == @normalizer.(value(opt))}
            to={link(BackendWeb.Endpoint, @live_view, @path_params, update_params(@url_params, @param, value(opt)))}>
            {display(opt)}
          </LivePatch>
        </div>
      </Dropdown>
    """
  end

  def render(assigns), do: assigns |> add_title_current() |> render()
end
