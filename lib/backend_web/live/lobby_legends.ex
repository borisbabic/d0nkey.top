defmodule BackendWeb.LobbyLegendsLive do
  use BackendWeb, :surface_live_view

  data(user, :any)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div>
      </div>
    </Context>
    """
  end
end
