defmodule BackendWeb.BattlefyController do
  use BackendWeb, :controller
  alias Backend.Battlefy

  def tournament(conn, %{"tournament_id" => tournament_id, "stage_id" => stage_id}) do
    tournament = Battlefy.get_tournament(tournament_id)
    standings = Battlefy.get_stage_standings(stage_id)

    render(conn, "tournament.html", %{
      standings: standings,
      tournament: tournament,
      stage_id: stage_id
    })
  end

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

  def future_opponents(conn, %{
        "tournament_id" => tournament_id,
        "battletag_full" => team_name
      }) do
    tournament = Battlefy.get_tournament(tournament_id)

    opponent_matches = Battlefy.get_future_opponents(tournament_id, team_name)

    render(conn, "future_opponents.html", %{
      tournament: tournament,
      opponent_matches: opponent_matches,
      team_name: team_name,
      conn: conn
    })
  end
end
