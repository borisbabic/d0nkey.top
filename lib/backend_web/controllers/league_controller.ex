defmodule BackendWeb.LeagueController do
  use BackendWeb, :controller

  alias Backend.Fantasy
  alias Backend.Fantasy.League

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(Backend.Plug.AdminAuth, role: :fantasy_leagues)
  action_fallback BackendWeb.FallbackController

  def index(conn, params) do
    case Fantasy.paginate_leagues(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Leagues. #{inspect(error)}")
        |> redirect(to: Routes.league_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Fantasy.change_league(%League{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"league" => league_params}) do
    owner_id = league_params["owner_id"] || BackendWeb.AuthUtils.user(conn).id

    league_params
    |> Fantasy.create_league(owner_id)
    |> case do
      {:ok, league} ->
        conn
        |> put_flash(:info, "League created successfully.")
        |> redirect(to: Routes.league_path(conn, :show, league))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    league = Fantasy.get_league!(id)
    render(conn, "show.html", league: league)
  end

  def edit(conn, %{"id" => id}) do
    league = Fantasy.get_league!(id)
    changeset = Fantasy.change_league(league)
    render(conn, "edit.html", league: league, changeset: changeset)
  end

  def update(conn, %{"id" => id, "league" => league_params}) do
    league = Fantasy.get_league!(id)

    case Fantasy.update_league(league, league_params) do
      {:ok, league} ->
        conn
        |> put_flash(:info, "League updated successfully.")
        |> redirect(to: Routes.league_path(conn, :show, league))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", league: league, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    league = Fantasy.get_league!(id)
    {:ok, _league} = Fantasy.delete_league(league)

    conn
    |> put_flash(:info, "League deleted successfully.")
    |> redirect(to: Routes.league_path(conn, :index))
  end
end
