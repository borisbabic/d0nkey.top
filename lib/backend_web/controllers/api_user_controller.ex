defmodule BackendWeb.ApiUserController do
  use BackendWeb, :controller

  alias Backend.Api
  alias Backend.Api.ApiUser

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(Backend.Plug.AdminAuth, role: :api_users)

  def index(conn, params) do
    case Api.paginate_api_users(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Api users. #{inspect(error)}")
        |> redirect(to: Routes.api_user_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Api.change_api_user(%ApiUser{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"api_user" => api_user_params}) do
    case Api.create_api_user(api_user_params) do
      {:ok, api_user} ->
        conn
        |> put_flash(:info, "Api user created successfully.")
        |> redirect(to: Routes.api_user_path(conn, :show, api_user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    api_user = Api.get_api_user!(id)
    render(conn, "show.html", api_user: api_user)
  end

  def edit(conn, %{"id" => id}) do
    api_user = Api.get_api_user!(id)
    changeset = Api.change_api_user(api_user)
    render(conn, "edit.html", api_user: api_user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "api_user" => api_user_params}) do
    api_user = Api.get_api_user!(id)

    case Api.update_api_user(api_user, api_user_params) do
      {:ok, api_user} ->
        conn
        |> put_flash(:info, "Api user updated successfully.")
        |> redirect(to: Routes.api_user_path(conn, :show, api_user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", api_user: api_user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    api_user = Api.get_api_user!(id)
    {:ok, _api_user} = Api.delete_api_user(api_user)

    conn
    |> put_flash(:info, "Api user deleted successfully.")
    |> redirect(to: Routes.api_user_path(conn, :index))
  end
end
