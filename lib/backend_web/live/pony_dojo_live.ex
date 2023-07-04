defmodule BackendWeb.PonyDojoLive do
  @moduledoc false
  use BackendWeb, :surface_live_view

  alias Components.PonyDojoPlayer
  data(user, :any)

  def mount(_params, session, s) do
    socket = s |> assign_defaults(session |> put_user_in_context())
    {:ok, socket}
  end

  def render(assigns) do
    ~F"""
      <div class="title is-2">
        Pony Dojo Power Rankings
      </div>
      <div class="columns is-mobile is-narrow is-multiline">
        <div :for={{p, index} <- Backend.PonyDojo.players() |> Enum.take(50) |> Enum.with_index()} class="column">
          <PonyDojoPlayer num={index + 1} player={p} />
        </div>
      </div>
    """
  end
end
