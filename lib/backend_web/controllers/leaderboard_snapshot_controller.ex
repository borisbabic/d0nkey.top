defmodule BackendWeb.LeaderboardSnapshotController do
  use BackendWeb, :controller

  alias Backend.Leaderboards
  alias Backend.Leaderboards.LeaderboardSnapshot

  def index(conn, _params) do
    leaderboard_snapshot = Leaderboards.list_leaderboard_snapshot()
    render(conn, "index.html", leaderboard_snapshot: leaderboard_snapshot)
  end

  def new(conn, _params) do
    changeset = Leaderboards.change_leaderboard_snapshot(%LeaderboardSnapshot{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"leaderboard_snapshot" => leaderboard_snapshot_params}) do
    case Leaderboards.create_leaderboard_snapshot(leaderboard_snapshot_params) do
      {:ok, leaderboard_snapshot} ->
        conn
        |> put_flash(:info, "Leaderboard snapshot created successfully.")
        |> redirect(to: Routes.leaderboard_snapshot_path(conn, :show, leaderboard_snapshot))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    leaderboard_snapshot = Leaderboards.get_leaderboard_snapshot!(id)
    render(conn, "show.html", leaderboard_snapshot: leaderboard_snapshot)
  end

  def edit(conn, %{"id" => id}) do
    leaderboard_snapshot = Leaderboards.get_leaderboard_snapshot!(id)
    changeset = Leaderboards.change_leaderboard_snapshot(leaderboard_snapshot)
    render(conn, "edit.html", leaderboard_snapshot: leaderboard_snapshot, changeset: changeset)
  end

  def update(conn, %{"id" => id, "leaderboard_snapshot" => leaderboard_snapshot_params}) do
    leaderboard_snapshot = Leaderboards.get_leaderboard_snapshot!(id)

    case Leaderboards.update_leaderboard_snapshot(leaderboard_snapshot, leaderboard_snapshot_params) do
      {:ok, leaderboard_snapshot} ->
        conn
        |> put_flash(:info, "Leaderboard snapshot updated successfully.")
        |> redirect(to: Routes.leaderboard_snapshot_path(conn, :show, leaderboard_snapshot))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", leaderboard_snapshot: leaderboard_snapshot, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    leaderboard_snapshot = Leaderboards.get_leaderboard_snapshot!(id)
    {:ok, _leaderboard_snapshot} = Leaderboards.delete_leaderboard_snapshot(leaderboard_snapshot)

    conn
    |> put_flash(:info, "Leaderboard snapshot deleted successfully.")
    |> redirect(to: Routes.leaderboard_snapshot_path(conn, :index))
  end
end
