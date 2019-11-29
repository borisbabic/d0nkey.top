defmodule BackendWeb.LeaderboardEntryController do
  use BackendWeb, :controller

  alias Backend.Leaderboards
  alias Backend.Leaderboards.LeaderboardEntry

  def index(conn, _params) do
    leaderboard_entry = Leaderboards.list_leaderboard_entry()
    render(conn, "index.html", leaderboard_entry: leaderboard_entry)
  end

  def new(conn, _params) do
    changeset = Leaderboards.change_leaderboard_entry(%LeaderboardEntry{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"leaderboard_entry" => leaderboard_entry_params}) do
    case Leaderboards.create_leaderboard_entry(leaderboard_entry_params) do
      {:ok, leaderboard_entry} ->
        conn
        |> put_flash(:info, "Leaderboard entry created successfully.")
        |> redirect(to: Routes.leaderboard_entry_path(conn, :show, leaderboard_entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    leaderboard_entry = Leaderboards.get_leaderboard_entry!(id)
    render(conn, "show.html", leaderboard_entry: leaderboard_entry)
  end

  def edit(conn, %{"id" => id}) do
    leaderboard_entry = Leaderboards.get_leaderboard_entry!(id)
    changeset = Leaderboards.change_leaderboard_entry(leaderboard_entry)
    render(conn, "edit.html", leaderboard_entry: leaderboard_entry, changeset: changeset)
  end

  def update(conn, %{"id" => id, "leaderboard_entry" => leaderboard_entry_params}) do
    leaderboard_entry = Leaderboards.get_leaderboard_entry!(id)

    case Leaderboards.update_leaderboard_entry(leaderboard_entry, leaderboard_entry_params) do
      {:ok, leaderboard_entry} ->
        conn
        |> put_flash(:info, "Leaderboard entry updated successfully.")
        |> redirect(to: Routes.leaderboard_entry_path(conn, :show, leaderboard_entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", leaderboard_entry: leaderboard_entry, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    leaderboard_entry = Leaderboards.get_leaderboard_entry!(id)
    {:ok, _leaderboard_entry} = Leaderboards.delete_leaderboard_entry(leaderboard_entry)

    conn
    |> put_flash(:info, "Leaderboard entry deleted successfully.")
    |> redirect(to: Routes.leaderboard_entry_path(conn, :index))
  end
end
