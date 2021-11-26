defmodule BackendWeb.AdminController do
  use BackendWeb, :controller
  alias Backend.MastersTour
  alias Backend.MastersTour.TourStop

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

  def wip(conn, _app) do
    # alias Backend.Battlefy
    # alias Backend.TournamentStats
    # alias Backend.TournamentStats.TeamStats
    # import Backend.MastersTour.InvitedPlayer

    # text =
    # Backend.MastersTour.tour_stops_tournaments()
    # |> Enum.take(1)
    # |> Enum.map(&Battlefy.create_tournament_stats/1)
    # |> Backend.TournamentStats.TournamentTeamStats.create_collection()
    # |> inspect(pretty: true)

    text(conn, "All work and no play")
  end

  def index(conn, _) do
    render(conn, "index.html")
  end

  def recalculate_archetypes(conn, %{"minutes_ago" => min_ago}) do
    Task.start(fn ->
        min_ago
        |> Backend.Hearthstone.recalculate_archetypes()
        |> inspect(pretty: true)
    end)

    text(conn, "Doing it")
  end

  def mt_player_nationality(conn, %{"tour_stop" => ts_string}) do
    response =
      ts_string
      |> TourStop.get()
      |> MastersTour.update_player_nationalities()
      |> case do
        {:ok, ret} -> inspect(ret, pretty: true)
        {:error, reason} -> reason
      end

    text(conn, response)
  end

  def fantasy_fix_btag(conn, %{"tour_stop" => ts_string}) do
    response =
      ts_string
      |> Backend.Fantasy.fix_mt_pick_battletag()
      |> case do
        {:ok, ret} -> ret
        {:error, reason} -> reason
      end
      |> inspect(pretty: true)

    text(conn, response)
  end

end
