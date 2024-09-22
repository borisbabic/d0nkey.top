defmodule FunctionComponents.Battlefy do
  @moduledoc false

  use Phoenix.Component

  alias FunctionComponents.Dropdown
  attr :stages, :list, required: true
  attr :title, :string, required: true

  def stage_selection_dropdown(assigns) do
    ~H"""
      <Dropdown.menu title={@title}>
          <%= for %{name: name, selected: selected, link: link} <- @stages do %>
              <Dropdown.item selected={selected}  href={link}>
                  <%=name%>
              </Dropdown.item>
          <% end %>
      </Dropdown.menu>
    """
  end
end
