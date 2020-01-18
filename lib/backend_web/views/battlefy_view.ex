defmodule BackendWeb.BattlefyView do
  use BackendWeb, :view

  def render("tournament.html", %{standings: standings_raw, tournament: tournament}) do
    standings =
      standings_raw
      |> Enum.map(fn s -> %{place: s.place, name: s.team.name} end)
      |> Enum.sort_by(fn s -> s.place end)

    duration =
      case tournament.last_completed_match_at do
        %{calendar: _} ->
          Util.human_diff(tournament.last_completed_match_at, tournament.start_time)

        _ ->
          nil
      end

    render("tournament.html", %{standings: standings, duration: duration, name: tournament.name})
  end
end
