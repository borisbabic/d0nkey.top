defmodule BackendWeb.BattlefyView do
  use BackendWeb, :view

  def render(
        "tournament.html",
        params = %{standings: standings_raw, tournament: tournament, conn: conn}
      ) do
    standings =
      standings_raw
      |> Enum.sort_by(fn s -> String.upcase(s.team.name) end)
      |> Enum.sort_by(fn s -> s.losses end)
      |> Enum.sort_by(fn s -> s.wins end, :desc)
      |> Enum.sort_by(fn s -> s.place end)
      |> Enum.map(fn s ->
        %{
          place: if(s.place && s.place > 0, do: s.place, else: "?"),
          name: s.team.name,
          has_score: s.wins && s.losses,
          score: "#{s.wins} - #{s.losses}",
          wins: s.wins,
          losses: s.losses,
          hsdeckviewer: Routes.battlefy_path(conn, :tournament_decks, tournament.id, s.team.name),
          yaytears: Backend.Yaytears.create_deckstrings_link(tournament.id, s.team.name)
        }
      end)

    duration_subtitle =
      case Backend.Battlefy.Tournament.get_duration(tournament) do
        nil -> "Duration: ?"
        duration -> "Duration: #{Util.human_duration(duration)}"
      end

    subtitle =
      case standings |> Enum.count() do
        0 -> duration_subtitle
        num -> "#{duration_subtitle} Players: #{num}"
      end

    stages =
      tournament.stages
      |> Enum.map(fn s ->
        %{
          name: s.name,
          link: Routes.battlefy_path(conn, :tournament, tournament.id, %{stage_id: s.id}),
          selected: params[:stage_id] && params[:stage_id] == s.id
        }
      end)

    selected_stage = stages |> Enum.find_value(fn s -> s.selected && s end)

    render("tournament.html", %{
      standings: standings,
      subtitle: subtitle,
      name: tournament.name,
      link: Backend.MastersTour.create_qualifier_link(tournament.slug, tournament.id),
      stages: stages,
      show_stage_selection: Enum.count(stages) > 1,
      stage_selection_text:
        if(selected_stage == nil, do: "Select Stage", else: selected_stage.name),
      show_score: standings |> Enum.any?(fn s -> s.has_score end)
    })
  end
end
