defmodule BackendWeb.GroupMembershipController do
  use BackendWeb, :controller

  alias Backend.UserManager
  alias Backend.UserManager.GroupMembership


  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(:put_layout, false)


  def index(conn, params) do
    case UserManager.paginate_group_memberships(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Group memberships. #{inspect(error)}")
        |> redirect(to: Routes.group_membership_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = UserManager.change_group_membership(%GroupMembership{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"group_membership" => group_membership_params}) do
    case UserManager.create_group_membership(group_membership_params) do
      {:ok, group_membership} ->
        conn
        |> put_flash(:info, "Group membership created successfully.")
        |> redirect(to: Routes.group_membership_path(conn, :show, group_membership))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    group_membership = UserManager.get_group_membership!(id)
    render(conn, "show.html", group_membership: group_membership)
  end

  def edit(conn, %{"id" => id}) do
    group_membership = UserManager.get_group_membership!(id)
    changeset = UserManager.change_group_membership(group_membership)
    render(conn, "edit.html", group_membership: group_membership, changeset: changeset)
  end

  def update(conn, %{"id" => id, "group_membership" => group_membership_params}) do
    group_membership = UserManager.get_group_membership!(id)

    case UserManager.update_group_membership(group_membership, group_membership_params) do
      {:ok, group_membership} ->
        conn
        |> put_flash(:info, "Group membership updated successfully.")
        |> redirect(to: Routes.group_membership_path(conn, :show, group_membership))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group_membership: group_membership, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    group_membership = UserManager.get_group_membership!(id)
    {:ok, _group_membership} = UserManager.delete_group_membership(group_membership)

    conn
    |> put_flash(:info, "Group membership deleted successfully.")
    |> redirect(to: Routes.group_membership_path(conn, :index))
  end
end
