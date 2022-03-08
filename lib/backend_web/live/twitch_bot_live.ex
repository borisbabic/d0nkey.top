defmodule BackendWeb.TwitchBotLive do
  use BackendWeb, :surface_live_view

  alias Components.TwitchCommandsTable

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
        <div class="title is-2">Twitch Commands</div>
        <a class="link" href="/twitch/bot/new-command">New Command</a>
        <TwitchCommandsTable id="commands_table" commands={commands(@user)} user={@user} />
      </div>
    </Context>
    """

  end
  defp commands(user) do
    Backend.TwitchBot.user_commands(user)
  end
end
