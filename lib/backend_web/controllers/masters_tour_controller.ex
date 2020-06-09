defmodule BackendWeb.MastersTourController do
  use BackendWeb, :controller
  alias Backend.MastersTour
  alias Backend.Infrastructure.BattlefyCommunicator

  def invited_players(conn, %{"tour_stop" => tour_stop}) do
    MastersTour.fetch(tour_stop)
    invited = MastersTour.list_invited_players(tour_stop)
    render(conn, "invited_players.html", %{invited: invited, tour_stop: tour_stop, conn: conn})
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
    user_tournaments = BattlefyCommunicator.get_user_tournaments(player_slug)

    render(conn, "qualifiers.html", %{
      fetched_qualifiers: fetched,
      range: {from, to},
      user_tournaments: user_tournaments,
      region: params["region"]
    })
  end

  def qualifiers(conn, params = %{"from" => %Date{} = from, "to" => %Date{} = to}) do
    fetched = BattlefyCommunicator.get_masters_qualifiers(from, to)

    render(conn, "qualifiers.html", %{
      fetched_qualifiers: fetched,
      range: {from, to},
      region: params["region"]
    })
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

  def earnings(conn, %{"show_gms" => show_gms}) do
    gm_season = {2020, 2}
    gms = Backend.PlayerInfo.current_gms()
    tour_stops = Backend.Blizzard.get_tour_stops_for_gm!(gm_season)
    earnings = MastersTour.get_gm_money_rankings(gm_season)

    render(conn, "earnings.html", %{
      tour_stops: tour_stops,
      earnings: earnings,
      show_gms: show_gms,
      gms: gms,
      gm_season: gm_season
    })
  end

  def earnings(conn, params) do
    earnings(conn, Map.merge(params, %{"show_gms" => "no"}))
  end

  def qualifier_stats(conn, %{"tour_stop" => ts}) do
    #    tour_stop = ts |> to_string() |> String.to_existing_atom()
    #    qualifiers = MastersTour.list_qualifiers_for_tour(tour_stop)
    {qualifiers, period} =
      case Integer.parse(ts) do
        {year, _} ->
          {MastersTour.list_qualifiers_for_year(year), year}

        :error ->
          tour_stop =
            ts
            |> to_string()
            |> String.to_existing_atom()

          {MastersTour.list_qualifiers_for_tour(tour_stop), tour_stop}
      end

    stats = MastersTour.PlayerStats.create_collection(qualifiers)

    render(conn, "qualifier_stats.html", %{
      period: period,
      total: qualifiers |> Enum.count(),
      stats: stats
    })
  end

  def qualifier_stats(conn, params) do
    qualifier_stats(
      conn,
      Map.merge(params, %{"tour_stop" => Backend.Blizzard.current_ladder_tour_stop()})
    )
  end
end
