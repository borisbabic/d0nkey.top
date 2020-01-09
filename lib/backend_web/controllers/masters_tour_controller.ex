defmodule BackendWeb.MastersTourController do
  use BackendWeb, :controller
  alias Backend.MastersTour
  alias Backend.Infrastructure.BattlefyCommunicator

  def invited_players(conn, %{"tour_stop" => tour_stop}) do
    MastersTour.fetch()
    invited = MastersTour.list_invited_players(tour_stop)
    render(conn, "invited_players.html", %{invited: invited})
  end

  def qualifiers(conn, _params) do
    fetched = BattlefyCommunicator.get_masters_qualifiers()
    render(conn, "qualifiers.html", %{fetched_qualifiers: fetched})
  end
end
