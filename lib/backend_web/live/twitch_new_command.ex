defmodule BackendWeb.TwitchNewCommandLive do
  use BackendWeb, :surface_live_view

  alias Components.NewTwitchCommand

  data(user, :any)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
    }
  end

  def render(assigns) do
    ~F"""
    <Context  put={user: @user}>
      <div>
        <div class="title is-2">New Twitch Commands</div>
        <NewTwitchCommand id="new_twitch_command" user={@user} />
      </div>
    </Context>
    """

  end
end
