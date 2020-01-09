defmodule BackendWeb.MastersTourController do
  use BackendWeb, :controller
  alias Backend.MastersTour

  def invited_players(conn, %{"tour_stop" => tour_stop}) do
    MastersTour.fetch()
    invited = MastersTour.list_invited_players(tour_stop)
    render(conn, "invited_players.html", %{invited: invited})
  end
end
