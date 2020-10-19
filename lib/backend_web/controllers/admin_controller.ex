defmodule BackendWeb.AdminController do
  use BackendWeb, :controller

  def get_all_leaderboards(conn, _params) do
    current_season = Date.utc_today() |> Backend.Blizzard.get_season_id()

    Task.start(fn ->
      for ldb <- ["WLD", "STD"],
          season_id <- 63..current_season,
          region <- Backend.Blizzard.qualifier_regions() do
        Backend.Leaderboards.get_leaderboard(region, ldb, season_id)
      end
    end)

    text(conn, "Success")
  end

  def test(conn, _params) do
    IO.inspect(conn)
    text(conn, "Success")
  end

  def config_vars(conn, _params) do
    print_config_vars(conn, :backend)
  end

  def ueberauth_config_vars(conn, _params) do
    print_config_vars(conn, :ueberauth)
  end

  defp print_config_vars(conn, app) do
    Application.get_env(:backend, :admin_config_vars_cutoff_date)
    |> Timex.parse!("{YYYY}-{0M}-{0D}")
    |> Date.compare(Date.utc_today())
    |> case do
      :lt ->
        text(conn, "Can't touch this, nanana")

      _ ->
        log = Application.get_all_env(app) |> inspect(pretty: true)
        text(conn, log)
    end
  end

  def wip(conn, app) do
    alias Backend.Battlefy
    alias Backend.TournamentStats
    alias Backend.TournamentStats.TeamStats
    import Backend.MastersTour.InvitedPlayer

    text =
      Backend.MastersTour.tour_stops_tournaments()
      |> Enum.take(1)
      |> Enum.map(&Battlefy.create_tournament_stats/1)
      |> Backend.TournamentStats.TournamentTeamStats.create_collection()
      |> inspect(pretty: true)

    text(conn, text)
  end
end
