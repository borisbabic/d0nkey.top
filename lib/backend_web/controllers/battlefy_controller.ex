defmodule BackendWeb.BattlefyController do
  use BackendWeb, :controller
  alias Backend.Battlefy

  def tournament(conn, %{"tournament_id" => tournament_id}) do
    tournament = Battlefy.get_tournament(tournament_id)
    standings = Battlefy.get_tournament_standings(tournament)
    render(conn, "tournament.html", %{standings: standings, tournament: tournament})
  end

  def tournament_decks(conn, %{
        "tournament_id" => tournament_id,
        "battletag_full" => battletag_full
      }) do
    tournament_decks =
      Battlefy.get_deckstrings(%{tournament_id: tournament_id, battletag_full: battletag_full})

    link = Backend.HSDeckViewer.create_link(tournament_decks)
    redirect(conn, external: link)
  end
end
