defmodule BackendWeb.UserController do
  use BackendWeb, :controller

  alias Backend.UserManager
  alias Backend.UserManager.User

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(Backend.Plug.AdminAuth, role: :users)

  def index(conn, params) do
    case UserManager.paginate_users(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Users. #{inspect(error)}")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = UserManager.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case UserManager.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = UserManager.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = UserManager.get_user!(id)
    changeset = UserManager.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = UserManager.get_user!(id)

    case UserManager.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = UserManager.get_user!(id)
    {:ok, _user} = UserManager.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
