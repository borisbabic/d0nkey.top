defmodule BackendWeb.DiscordController do
  use BackendWeb, :controller
  alias Backend.Discord

  def broadcasts(conn, _params) do
    render(conn, "broadcasts.html")
  end

  def create_broadcast(conn, _params) do
    {:ok, broadcast} = Discord.create_broadcast()

    redirect(conn,
      to: Routes.discord_path(conn, :view_publish, broadcast.id, broadcast.publish_token)
    )
  end

  def broadcast(conn = %{method: "POST"}, %{"photo" => %{path: path, filename: name}}) do
    Discord.broadcast(path, name)
    render(conn, "broadcast.html")
  end

  def publish(conn = %{method: "POST"}, %{
        "photo" => %{path: path, filename: name},
        "token" => token,
        "id" => id
      }) do
    broadcast = Discord.get_broadcast!(id)

    if token == broadcast.publish_token do
      Discord.broadcast(broadcast, path, name)
      render(conn, "success.html", %{broadcast: broadcast})
    else
      render(conn, "not_allowed.html")
    end
  end

  def view_publish(conn, %{"token" => token, "id" => id}) do
    broadcast = Discord.get_broadcast!(id)

    if token == broadcast.publish_token do
      render(conn, "view_publish.html", %{broadcast: broadcast})
    else
      render(conn, "not_allowed.html")
    end
  end

  def subscribe(conn = %{method: "POST"}, %{"hook_url" => hook_url, "token" => token, "id" => id}) do
    broadcast = Discord.get_broadcast!(id)

    if token == broadcast.subscribe_token do
      Discord.subscribe(broadcast, hook_url)
      render(conn, "success.html")
    else
      render(conn, "not_allowed.html")
    end
  end

  def view_subscribe(conn, %{"token" => token, "id" => id}) do
    broadcast = Discord.get_broadcast!(id)

    if token == broadcast.subscribe_token do
      render(conn, "view_subscribe.html", %{broadcast: broadcast})
    else
      render(conn, "not_allowed.html")
    end
  end
end
