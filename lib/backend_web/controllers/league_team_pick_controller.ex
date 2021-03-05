defmodule BackendWeb.LeagueTeamPickController do
  use BackendWeb, :controller

  alias Backend.Fantasy
  alias Backend.Fantasy.LeagueTeamPick

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(Backend.Plug.AdminAuth, role: :fantasy_leagues)
  action_fallback BackendWeb.FallbackController

  def index(conn, params) do
    case Fantasy.paginate_league_team_picks(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering League team picks. #{inspect(error)}")
        |> redirect(to: Routes.league_team_pick_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Fantasy.change_league_team_pick(%LeagueTeamPick{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"league_team_pick" => league_team_pick_params}) do
    case Fantasy.create_league_team_pick(league_team_pick_params) do
      {:ok, league_team_pick} ->
        conn
        |> put_flash(:info, "League team pick created successfully.")
        |> redirect(to: Routes.league_team_pick_path(conn, :show, league_team_pick))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    league_team_pick = Fantasy.get_league_team_pick!(id)
    render(conn, "show.html", league_team_pick: league_team_pick)
  end

  def edit(conn, %{"id" => id}) do
    league_team_pick = Fantasy.get_league_team_pick!(id)
    changeset = Fantasy.change_league_team_pick(league_team_pick)
    render(conn, "edit.html", league_team_pick: league_team_pick, changeset: changeset)
  end

  def update(conn, %{"id" => id, "league_team_pick" => league_team_pick_params}) do
    league_team_pick = Fantasy.get_league_team_pick!(id)

    case Fantasy.update_league_team_pick(league_team_pick, league_team_pick_params) do
      {:ok, league_team_pick} ->
        conn
        |> put_flash(:info, "League team pick updated successfully.")
        |> redirect(to: Routes.league_team_pick_path(conn, :show, league_team_pick))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", league_team_pick: league_team_pick, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    league_team_pick = Fantasy.get_league_team_pick!(id)
    {:ok, _league_team_pick} = Fantasy.delete_league_team_pick(league_team_pick)

    conn
    |> put_flash(:info, "League team pick deleted successfully.")
    |> redirect(to: Routes.league_team_pick_path(conn, :index))
  end
end
