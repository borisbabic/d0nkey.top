defmodule BackendWeb.PlaygroundLive do
  use BackendWeb, :surface_live_view

  use Components.TwitchChat, component_ids: ["d0nkeytop_twitch_chat"]

  data(user, :any)

  def mount(_params, session, socket) do
    {:ok, socket |> assign_defaults(session) |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <TwitchChat id="d0nkeytop_twitch_chat" channel="#d0nkeytop" />
      </div>
    """
  end
end
