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

  def qualifier_stats(conn, params = %{"tour_stop" => ts}) do
    period =
      case Integer.parse(ts) do
        {year, _} ->
          year

        :error ->
          ts
          |> to_string()
          |> String.to_existing_atom()
      end

    {stats, total} = MastersTour.get_player_stats(period)

    direction =
      case params["direction"] do
        "desc" -> :desc
        "asc" -> :asc
        _ -> nil
      end

    min = with raw when is_binary(raw) <- params["min"], {val, _} <- Integer.parse(raw), do: val

    render(conn, "qualifier_stats.html", %{
      min: min,
      period: period,
      total: total,
      sort_by: params["sort_by"],
      direction: direction,
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
