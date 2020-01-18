defmodule BackendWeb.BattlefyController do
  use BackendWeb, :controller
  alias Backend.Battlefy

  def tournament(conn, %{"tournament_id" => tournament_id}) do
    tournament = Battlefy.get_tournament(tournament_id)
    standings = Battlefy.get_tournament_standings(tournament)
    render(conn, "tournament.html", %{standings: standings, tournament: tournament})
  end
end
