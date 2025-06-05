defmodule BackendWeb.TwitchBotLive do
  use BackendWeb, :surface_live_view

  alias Components.TwitchCommandsTable

  data(user, :any)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()}
    |> assign(page_title: "Twitch Commands")
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Twitch Commands</div>
        <a class="link" href="/twitch/bot/new-command">New Command</a>
        <TwitchCommandsTable id="commands_table" commands={commands(@user)} user={@user} />
      </div>
    """
  end

  defp commands(user) do
    Backend.TwitchBot.user_commands(user)
  end
end
