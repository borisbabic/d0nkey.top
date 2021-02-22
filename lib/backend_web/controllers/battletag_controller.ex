defmodule BackendWeb.BattletagController do
  use BackendWeb, :controller

  alias Backend.Battlenet
  alias Backend.Battlenet.Battletag

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(Backend.Plug.AdminAuth, role: :battletag_info)

  def index(conn, params) do
    case Battlenet.paginate_battletag_info(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Battletag info. #{inspect(error)}")
        |> redirect(to: Routes.battletag_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Battlenet.change_battletag(%Battletag{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"battletag" => battletag_params}) do
    battletag_params
    |> Map.put("reported_by", conn |> BackendWeb.AuthUtils.battletag())
    |> Battlenet.create_battletag()
    |> case do
      {:ok, battletag} ->
        conn
        |> put_flash(:info, "Battletag created successfully.")
        |> redirect(to: Routes.battletag_path(conn, :show, battletag))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    battletag = Battlenet.get_battletag!(id)
    render(conn, "show.html", battletag: battletag)
  end

  def edit(conn, %{"id" => id}) do
    battletag = Battlenet.get_battletag!(id)
    changeset = Battlenet.change_battletag(battletag)
    render(conn, "edit.html", battletag: battletag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "battletag" => battletag_params}) do
    battletag = Battlenet.get_battletag!(id)

    case Battlenet.update_battletag(battletag, battletag_params) do
      {:ok, battletag} ->
        conn
        |> put_flash(:info, "Battletag updated successfully.")
        |> redirect(to: Routes.battletag_path(conn, :show, battletag))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", battletag: battletag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    battletag = Battlenet.get_battletag!(id)
    {:ok, _battletag} = Battlenet.delete_battletag(battletag)

    conn
    |> put_flash(:info, "Battletag deleted successfully.")
    |> redirect(to: Routes.battletag_path(conn, :index))
  end
end
