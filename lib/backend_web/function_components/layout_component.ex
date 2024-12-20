defmodule FunctionComponents.LayoutComponent do
  @moduledoc "Function components for the layout, primarily the navbar"
  use BackendWeb, :component

  alias FunctionComponents.Dropdown
  attr :display, :string, required: true
  attr :battlefy_id, :string, required: true
  attr :start, NaiveDateTime, required: true
  attr :finish, NaiveDateTime, required: true
  attr :twitch, :string, required: false, default: nil
  attr :show_trophy, :boolean, required: false, default: true

  def live_battlefy(assigns) do
    ~H"""
      <%= if Util.in_range?(NaiveDateTime.utc_now(), {@start, @finish}) do %>
        <a class="navbar-item" href={Routes.battlefy_path(BackendWeb.Endpoint, :tournament, @battlefy_id)}>
        <%= if @show_trophy do %>🏆<% end %><%= @display %>
          <%= if @twitch && Twitch.HearthstoneLive.twitch_display_live?(@twitch) do %>
            <p><sup class="is-size-7 has-text-info"> Live!</sup></p>
          <% end %>
        </a>
      <% end %>
    """
  end

  attr :sub_menus, :list, required: false, default: []
  attr :display, :string, required: true
  attr :main_link, :string, required: false, default: "#"
  slot :inner_block, required: true

  def navbar_dropdown(assigns) do
    ~H"""
      <div class="navbar-item has-dropdown" x-on:mouseleave="if(window.canCloseDropdown($event)) open=false;" x-data={"{#{init_to_false(["open" | @sub_menus])}}"} x-bind:class="{'is-active': open}" x-bind:aria-expanded="open" x-on:keydown.esc={"open=false"}>
        <Dropdown.title aria_controls={"navbar-dropdown"} title={@display} {%{href: @main_link}} class="navbar-item navbar-link" />
          <div class="navbar-dropdown">
            <div>
              <%= render_slot(@inner_block) %>
            </div>
          </div>
      </div>
    """
  end

  attr :link, :string, required: true
  attr :display, :string, required: true

  def navbar_item_link(assigns) do
    ~H"""
    <Dropdown.item base_class="navbar-item" href={@link}>
      <%= @display %>
      </Dropdown.item>
    """
  end

  defp init_to_false(to_false) do
    to_false
    |> Enum.map_join(", ", fn item ->
      "#{item}: false"
    end)
  end
end
