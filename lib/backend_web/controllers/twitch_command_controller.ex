defmodule BackendWeb.TwitchCommandController do
  use BackendWeb, :controller

  alias Backend.TwitchBot
  alias Backend.TwitchBot.TwitchCommand


  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(Backend.Plug.AdminAuth, role: :twitch_commands)
  plug(:put_layout, false)


  def index(conn, params) do
    case TwitchBot.paginate_twitch_commands(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Twitch commands. #{inspect(error)}")
        |> redirect(to: Routes.twitch_command_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = TwitchBot.change_twitch_command(%TwitchCommand{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"twitch_command" => twitch_command_params}) do
    case TwitchBot.create_twitch_command(twitch_command_params) do
      {:ok, twitch_command} ->
        conn
        |> put_flash(:info, "Twitch command created successfully.")
        |> redirect(to: Routes.twitch_command_path(conn, :show, twitch_command))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    twitch_command = TwitchBot.get_twitch_command!(id)
    render(conn, "show.html", twitch_command: twitch_command)
  end

  def edit(conn, %{"id" => id}) do
    twitch_command = TwitchBot.get_twitch_command!(id)
    changeset = TwitchBot.change_twitch_command(twitch_command)
    render(conn, "edit.html", twitch_command: twitch_command, changeset: changeset)
  end

  def update(conn, %{"id" => id, "twitch_command" => twitch_command_params}) do
    twitch_command = TwitchBot.get_twitch_command!(id)

    case TwitchBot.update_twitch_command(twitch_command, twitch_command_params) do
      {:ok, twitch_command} ->
        conn
        |> put_flash(:info, "Twitch command updated successfully.")
        |> redirect(to: Routes.twitch_command_path(conn, :show, twitch_command))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", twitch_command: twitch_command, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    twitch_command = TwitchBot.get_twitch_command!(id)
    {:ok, _twitch_command} = TwitchBot.delete_twitch_command(twitch_command)

    conn
    |> put_flash(:info, "Twitch command deleted successfully.")
    |> redirect(to: Routes.twitch_command_path(conn, :index))
  end
end
