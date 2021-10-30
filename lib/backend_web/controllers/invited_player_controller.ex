defmodule BackendWeb.InvitedPlayerController do
  use BackendWeb, :controller

  alias Backend.MastersTour
  alias Backend.MastersTour.InvitedPlayer

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(Backend.Plug.AdminAuth, role: :invites)

  def index(conn, params) do
    case MastersTour.paginate_invited_player(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Invited player. #{inspect(error)}")
        |> redirect(to: Routes.invited_player_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = MastersTour.change_invited_player(%InvitedPlayer{})
    render(conn, "new.html", changeset: changeset)
  end

  @spec batch(Plug.Conn.t(), any) :: Plug.Conn.t()
  def batch(conn, _params) do
    render(conn, "batch.html")
  end

  def batch_insert(conn, %{"batch" => batch}) do
    batch_insert(batch)
    redirect(conn, to: Routes.invited_player_path(conn, :index))
  end

  def batch_insert(batch) do
    for ts <- split(batch["tour_stop"]), btag <- split(batch["battletag_full"]) do
      batch
      |> Map.new()
      |> Map.merge(%{"tour_stop" => ts, "battletag_full" => btag})
      |> MastersTour.create_invited_player()
    end
  end

  def split(string), do:
    string |> String.replace("\r", "") |> String.split("\n") |> Enum.map(&String.trim/1) |> Enum.filter(& &1 != "")

  def create(conn, %{"invited_player" => invited_player_params}) do
    case MastersTour.create_invited_player(invited_player_params) do
      {:ok, invited_player} ->
        conn
        |> put_flash(:info, "Invited player created successfully.")
        |> redirect(to: Routes.invited_player_path(conn, :show, invited_player))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    invited_player = MastersTour.get_invited_player!(id)
    render(conn, "show.html", invited_player: invited_player)
  end

  def edit(conn, %{"id" => id}) do
    invited_player = MastersTour.get_invited_player!(id)
    changeset = MastersTour.change_invited_player(invited_player)
    render(conn, "edit.html", invited_player: invited_player, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invited_player" => invited_player_params}) do
    invited_player = MastersTour.get_invited_player!(id)

    case MastersTour.update_invited_player(invited_player, invited_player_params) do
      {:ok, invited_player} ->
        conn
        |> put_flash(:info, "Invited player updated successfully.")
        |> redirect(to: Routes.invited_player_path(conn, :show, invited_player))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", invited_player: invited_player, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    invited_player = MastersTour.get_invited_player!(id)
    {:ok, _invited_player} = MastersTour.delete_invited_player(invited_player)

    conn
    |> put_flash(:info, "Invited player deleted successfully.")
    |> redirect(to: Routes.invited_player_path(conn, :index))
  end
end
