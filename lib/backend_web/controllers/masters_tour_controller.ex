defmodule BackendWeb.MastersTourController do
  use BackendWeb, :controller
  alias Backend.MastersTour
  alias Backend.MastersTour.TourStop
  alias Backend.Infrastructure.BattlefyCommunicator
  alias Backend.UserManager.Guardian

  def invited_players(conn, %{"tour_stop" => tour_stop}) do
    MastersTour.fetch(tour_stop)
    invited = MastersTour.list_invited_players(tour_stop)

    render(conn, "invited_players.html", %{
      invited: invited,
      tour_stop: tour_stop,
      page_title: "#{tour_stop} invited players",
      conn: conn
    })
  end

  def invited_players(conn, _params) do
    tour_stop =
      case Backend.Blizzard.current_ladder_tour_stop() do
        "" ->
          ts =
            Backend.MastersTour.TourStop.all()
            |> Enum.max_by(fn ts -> ts.start_time |> to_string() end)

          ts.id |> to_string

        ts ->
          ts
      end

    redirect(conn,
      to: Routes.masters_tour_path(conn, :invited_players, tour_stop)
    )
  end

  def qualifiers(
        conn,
        params = %{
          "from" => %Date{} = from,
          "to" => %Date{} = to,
          "player_slug" => player_slug
        }
      ) do
    fetched = BattlefyCommunicator.get_masters_qualifiers(from, to)

    user_tournaments =
      BattlefyCommunicator.get_user_tournaments_from(player_slug, Util.day_start(from, :naive))

    render(conn, "qualifiers.html", %{
      fetched_qualifiers: fetched,
      range: {from, to},
      user_tournaments: user_tournaments,
      page_title: "MT Qualifiers",
      region: params["region"]
    })
  end

  def qualifiers(conn, params = %{"from" => %Date{} = from, "to" => %Date{} = to}) do
    fetched = BattlefyCommunicator.get_masters_qualifiers(from, to)

    user_params =
      conn
      |> Guardian.Plug.current_resource()
      |> case do
        %{battlefy_slug: slug} ->
          %{
            user_tournaments:
              BattlefyCommunicator.get_user_tournaments_from(slug, Util.day_start(from, :naive))
          }

        _ ->
          %{}
      end

    render(
      conn,
      "qualifiers.html",
      %{
        fetched_qualifiers: fetched,
        page_title: "MT Qualifiers",
        range: {from, to},
        region: params["region"]
      }
      |> Map.merge(user_params)
    )
  end

  def qualifiers(conn, params = %{"from" => from, "to" => to}) do
    from_date = Date.from_iso8601!(from)
    to_date = Date.from_iso8601!(to)
    qualifiers(conn, %{params | "from" => from_date, "to" => to_date})
  end

  def qualifiers(conn, params) do
    {from, to} = MastersTour.get_masters_date_range(:week)
    qualifiers(conn, Map.merge(params, %{"from" => from, "to" => to}))
  end

  @default_season {2021, 1}
  def parse_season("2020_2"), do: {2020, 2}
  def parse_season("2021_1"), do: {2021, 1}
  def parse_season("2021_2"), do: {2021, 2}
  def parse_season(_), do: @default_season

  defp show_current_score?(%{"show_current_score" => current_score})
       when is_binary(current_score),
       do: String.starts_with?(current_score, "yes")

  defp show_current_score?(_), do: false

  def earnings(conn, params = %{"show_gms" => show_gms}) do
    gm_season = params["season"] |> parse_season()
    gms = Backend.PlayerInfo.get_grandmasters(gm_season)
    tour_stops = Backend.Blizzard.get_tour_stops_for_gm!(gm_season)
    earnings = MastersTour.get_gm_money_rankings(gm_season)

    {standings, show_current_score} =
      with true <- show_current_score?(params),
           current_ts when not is_nil(current_ts) <- MastersTour.TourStop.get_current(),
           %{battlefy_id: battlefy_id} <- MastersTour.TourStop.get(current_ts),
           standings when standings != [] <-
             battlefy_id |> Backend.Battlefy.get_tournament_standings() do
        {standings, true}
      else
        _ -> {[], false}
      end

    region =
      params["region"]
      |> Backend.Blizzard.to_region()
      |> Util.nilify()

    render(conn, "earnings.html", %{
      tour_stops: tour_stops,
      earnings: earnings,
      standings: standings,
      page_title: "MT Earnings",
      show_current_score: show_current_score,
      show_gms: show_gms,
      region: region,
      gms: gms,
      country: params["country"],
      gm_season: gm_season
    })
  end

  def tour_stops(conn, _params) do
    tournaments = MastersTour.tour_stops_tournaments()

    render(conn, "tour_stops.html", %{
      conn: conn,
      page_title: "Tour Stops",
      tournaments: tournaments
    })
  end

  def earnings(conn, params) do
    earnings(conn, Map.merge(params, %{"show_gms" => "no"}))
  end

  defp direction("desc"), do: :desc
  defp direction("asc"), do: :asc
  defp direction(_), do: nil

  defp columns(columns = %{}) do
    columns
    |> Enum.filter(fn {_, selected} -> selected == "true" end)
    |> Enum.map(fn {column, _} -> column end)
  end

  defp columns(_), do: nil

  def qualifier_stats(conn, params = %{"tour_stop" => ts}) do
    period =
      case Integer.parse(ts |> to_string()) do
        {year, _} ->
          year

        :error ->
          ts
          |> to_string()
          |> String.to_existing_atom()
      end

    {stats, total} = MastersTour.get_player_stats(period)

    direction = direction(params["direction"])

    min = with raw when is_binary(raw) <- params["min"], {val, _} <- Integer.parse(raw), do: val

    selected_columns = columns(params["columns"])

    invited_players = MastersTour.list_invited_players()

    render(conn, "qualifier_stats.html", %{
      min: min,
      period: period,
      total: total,
      sort_by: params["sort_by"],
      direction: direction,
      show_flags: parse_yes_no(params["show_flags"]),
      countries: multi_select_to_array(params["country"]),
      selected_columns: selected_columns,
      invited_players: invited_players,
      page_title: "#{period} Qualifier Stats",
      stats: stats
    })
  end

  def qualifier_stats(conn, params) do
    period =
      case Backend.Blizzard.current_ladder_tour_stop() do
        "" ->
          Backend.MastersTour.TourStop.all()
          |> Enum.map(fn ts -> ts.year end)
          |> Enum.max()
          |> to_string()

        ts ->
          ts |> to_string()
      end

    qualifier_stats(
      conn,
      Map.merge(params, %{"tour_stop" => period})
    )
  end

  def masters_tours_stats(conn, params) do
    tour_stops =
      TourStop.all() |> Enum.filter(fn ts -> ts.battlefy_id end) |> Enum.map(fn ts -> ts.id end)

    tournament_team_stats = MastersTour.masters_tours_stats()
    direction = direction(params["direction"])
    selected_columns = multi_select_to_array(params["columns"])

    render(conn, "masters_tours_stats.html", %{
      conn: conn,
      direction: direction,
      selected_columns: selected_columns,
      countries: multi_select_to_array(params["country"]),
      sort_by: params["sort_by"],
      tour_stops: tour_stops,
      page_title: "MT Stats",
      tournament_team_stats: tournament_team_stats
    })
  end
end
