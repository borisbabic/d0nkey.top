defmodule BackendWeb.MastersTourController do
  use BackendWeb, :controller
  alias Backend.MastersTour
  alias Backend.Infrastructure.BattlefyCommunicator

  def invited_players(conn, %{"tour_stop" => tour_stop}) do
    MastersTour.fetch(tour_stop)
    invited = MastersTour.list_invited_players(tour_stop)
    render(conn, "invited_players.html", %{invited: invited, tour_stop: tour_stop})
  end

  def qualifiers(conn, %{"from" => %Date{} = from, "to" => %Date{} = to}) do
    fetched = BattlefyCommunicator.get_masters_qualifiers(from, to)
    render(conn, "qualifiers.html", %{fetched_qualifiers: fetched, range: {from, to}})
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
end
