defmodule BackendWeb.PonyDojoLive do
  use BackendWeb, :surface_live_view

  alias Components.PonyDojoPlayer
  data(user, :any)

  def mount(_params, session, s) do
    socket = s |> assign_defaults(session)
    {:ok, socket}
  end

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div class="title is-2">
        Pony Dojo Power Rankings
      </div>
      <div class="columns is-mobile is-narrow is-multiline">
        <div :for={{p, index} <- Backend.PonyDojo.players() |> Enum.with_index()} class="column">
          <PonyDojoPlayer num={index + 1} player={p} />
        </div>
      </div>
    </Context>
    """
  end

end
