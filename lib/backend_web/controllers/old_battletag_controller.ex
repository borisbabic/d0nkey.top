defmodule BackendWeb.OldBattletagController do
  use BackendWeb, :controller

  alias Backend.Battlenet
  alias Backend.Battlenet.OldBattletag


  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(Backend.Plug.AdminAuth, role: :old_battletags)
  action_fallback BackendWeb.FallbackController
  plug(:put_layout, false)


  def index(conn, params) do
    case Battlenet.paginate_old_battletags(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Old battletags. #{inspect(error)}")
        |> redirect(to: Routes.old_battletag_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Battlenet.change_old_battletag(%OldBattletag{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"old_battletag" => old_battletag_params}) do
    case Battlenet.create_old_battletag(old_battletag_params) do
      {:ok, old_battletag} ->
        conn
        |> put_flash(:info, "Old battletag created successfully.")
        |> redirect(to: Routes.old_battletag_path(conn, :show, old_battletag))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    old_battletag = Battlenet.get_old_battletag!(id)
    render(conn, "show.html", old_battletag: old_battletag)
  end

  def edit(conn, %{"id" => id}) do
    old_battletag = Battlenet.get_old_battletag!(id)
    changeset = Battlenet.change_old_battletag(old_battletag)
    render(conn, "edit.html", old_battletag: old_battletag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "old_battletag" => old_battletag_params}) do
    old_battletag = Battlenet.get_old_battletag!(id)

    case Battlenet.update_old_battletag(old_battletag, old_battletag_params) do
      {:ok, old_battletag} ->
        conn
        |> put_flash(:info, "Old battletag updated successfully.")
        |> redirect(to: Routes.old_battletag_path(conn, :show, old_battletag))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", old_battletag: old_battletag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    old_battletag = Battlenet.get_old_battletag!(id)
    {:ok, _old_battletag} = Battlenet.delete_old_battletag(old_battletag)

    conn
    |> put_flash(:info, "Old battletag deleted successfully.")
    |> redirect(to: Routes.old_battletag_path(conn, :index))
  end
end
