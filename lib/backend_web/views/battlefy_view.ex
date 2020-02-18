defmodule BackendWeb.BattlefyView do
  use BackendWeb, :view

  def render("tournament.html", %{standings: standings_raw, tournament: tournament, conn: conn}) do
    standings =
      standings_raw
      |> Enum.map(fn s ->
        %{
          place: s.place,
          name: s.team.name,
          hsdeckviewer: Routes.battlefy_path(conn, :tournament_decks, tournament.id, s.team.name),
          yaytears: Backend.Yaytears.create_deckstrings_link(tournament.id, s.team.name)
        }
      end)
      |> Enum.sort_by(fn s -> s.place end)

    duration =
      tournament
      |> Backend.Battlefy.Tournament.get_duration()
      |> Util.human_duration()

    duration_subtitle = "Duration: #{duration}"

    subtitle =
      case standings |> Enum.count() do
        0 -> duration_subtitle
        num -> "#{duration_subtitle} Players: #{num}"
      end

    render("tournament.html", %{standings: standings, subtitle: subtitle, name: tournament.name})
  end
end
