defmodule BackendWeb.LeagueTeamController do
  use BackendWeb, :controller

  alias Backend.Fantasy
  alias Backend.Fantasy.LeagueTeam

  plug(:put_root_layout, {BackendWeb.LayoutView, "torch.html"})
  plug(Backend.Plug.AdminAuth, role: :fantasy_leagues)
  action_fallback BackendWeb.FallbackController

  def index(conn, params) do
    case Fantasy.paginate_league_teams(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering League teams. #{inspect(error)}")
        |> redirect(to: Routes.league_team_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Fantasy.change_league_team(%LeagueTeam{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"league_team" => league_team_params}) do
    case Fantasy.create_league_team(league_team_params) do
      {:ok, league_team} ->
        conn
        |> put_flash(:info, "League team created successfully.")
        |> redirect(to: Routes.league_team_path(conn, :show, league_team))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    league_team = Fantasy.get_league_team!(id)
    render(conn, "show.html", league_team: league_team)
  end

  def edit(conn, %{"id" => id}) do
    league_team = Fantasy.get_league_team!(id)
    changeset = Fantasy.change_league_team(league_team)
    render(conn, "edit.html", league_team: league_team, changeset: changeset)
  end

  def update(conn, %{"id" => id, "league_team" => league_team_params}) do
    league_team = Fantasy.get_league_team!(id)

    case Fantasy.update_league_team(league_team, league_team_params) do
      {:ok, league_team} ->
        conn
        |> put_flash(:info, "League team updated successfully.")
        |> redirect(to: Routes.league_team_path(conn, :show, league_team))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", league_team: league_team, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    league_team = Fantasy.get_league_team!(id)
    {:ok, _league_team} = Fantasy.delete_league_team(league_team)

    conn
    |> put_flash(:info, "League team deleted successfully.")
    |> redirect(to: Routes.league_team_path(conn, :index))
  end
end
