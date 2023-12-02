defmodule BackendWeb.FunctionComponents.LayoutComponent do
  @moduledoc "Function components for the layout, primarily the navbar"
  use BackendWeb, :component

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
end
