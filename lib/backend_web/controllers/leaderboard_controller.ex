defmodule BackendWeb.LeaderboardController do
  use BackendWeb, :controller

  alias Backend.Leaderboards
  alias Backend.Leaderboards.Leaderboard

  def index(conn, _params) do
    leaderboard = Leaderboards.list_leaderboard()
    render(conn, "index.html", leaderboard: leaderboard)
  end

  def new(conn, _params) do
    changeset = Leaderboards.change_leaderboard(%Leaderboard{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"leaderboard" => leaderboard_params}) do
    case Leaderboards.create_leaderboard(leaderboard_params) do
      {:ok, leaderboard} ->
        conn
        |> put_flash(:info, "Leaderboard created successfully.")
        |> redirect(to: Routes.leaderboard_path(conn, :show, leaderboard))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    leaderboard = Leaderboards.get_leaderboard!(id)
    render(conn, "show.html", leaderboard: leaderboard)
  end

  def edit(conn, %{"id" => id}) do
    leaderboard = Leaderboards.get_leaderboard!(id)
    changeset = Leaderboards.change_leaderboard(leaderboard)
    render(conn, "edit.html", leaderboard: leaderboard, changeset: changeset)
  end

  def update(conn, %{"id" => id, "leaderboard" => leaderboard_params}) do
    leaderboard = Leaderboards.get_leaderboard!(id)

    case Leaderboards.update_leaderboard(leaderboard, leaderboard_params) do
      {:ok, leaderboard} ->
        conn
        |> put_flash(:info, "Leaderboard updated successfully.")
        |> redirect(to: Routes.leaderboard_path(conn, :show, leaderboard))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", leaderboard: leaderboard, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    leaderboard = Leaderboards.get_leaderboard!(id)
    {:ok, _leaderboard} = Leaderboards.delete_leaderboard(leaderboard)

    conn
    |> put_flash(:info, "Leaderboard deleted successfully.")
    |> redirect(to: Routes.leaderboard_path(conn, :index))
  end
end
