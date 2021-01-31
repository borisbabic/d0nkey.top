defmodule BackendWeb.PlayerView do
  use BackendWeb, :view

  alias Backend.Blizzard
  alias Backend.MastersTour
  alias Backend.MastersTour.PlayerStats
  alias Backend.MastersTour.TourStop
  alias Backend.TournamentStats.TeamStats
  alias Backend.TournamentStats.TournamentTeamStats

  defp simple_link(href, text) do
    ~E"""
    <a class="is-link" href="<%= href %>"><%= text %></a>
    """
  end

  def render(
        "player_profile.html",
        %{
          battletag_full: battletag_full,
          qualifier_stats: qs,
          player_info: pi,
          tournaments: t,
          finishes: finishes,
          competitions: competitions,
          tournament_team_stats: tts,
          conn: conn,
          mt_earnings: mt_earnings
        }
      ) do
    stats_rows =
      qs
      |> Enum.flat_map(fn {year, ps} ->
        [
          {"#{year} MTQ played", ps |> PlayerStats.with_result()},
          {"#{year} MTQ winrate", ps |> PlayerStats.matches_won_percent() |> Float.round(2)}
        ]
      end)

    player_rows =
      case {pi.country, pi.region} do
        {nil, nil} ->
          []

        {country, nil} ->
          [{"Country", country |> Util.get_country_name()}]

        {nil, region} ->
          [{"Region", region |> Blizzard.get_region_name(:long)}]

        {country, region} ->
          [
            {"Country", country |> Util.get_country_name()},
            {"Region", region |> Blizzard.get_region_name(:long)}
          ]
      end

    earnings_rows = [{"2020 MT earnings", mt_earnings}]

    mt_total_stats =
      tts |> Enum.map(&TournamentTeamStats.total_stats/1) |> TeamStats.calculate_team_stats()

    mt_total_row = [{"MT Match Score", "#{mt_total_stats.wins} - #{mt_total_stats.losses}"}]

    rows =
      (player_rows ++ stats_rows ++ earnings_rows ++ mt_total_row)
      |> Enum.map(fn {title, val} -> "#{title}: #{val}" end)

    table_headers =
      [
        "Competition",
        "Place",
        "Score"
      ]
      |> Enum.map(fn h -> ~E"<th><%= h %></th>" end)

    mt_rows =
      tts
      |> Enum.map(fn ts ->
        swiss = ts |> TournamentTeamStats.filter_stages(:swiss)
        stats = ts |> TournamentTeamStats.total_stats()
        position = stats |> TeamStats.best()
        tournament_link = Routes.battlefy_path(conn, :tournament, ts.tournament_id)
        tournament_title = "MT #{ts.tournament_name |> to_string()}"
        score = "#{swiss.wins} - #{swiss.losses}"
        tour_stop = TourStop.get(ts.tournament_name)

        player_link =
          Routes.battlefy_path(conn, :tournament_player, ts.tournament_id, ts.team_name)

        %{
          competition: simple_link(tournament_link, tournament_title),
          time: tour_stop.start_time,
          position: simple_link(player_link, position),
          score: score
        }
      end)

    qualifier_rows =
      t
      |> Enum.flat_map(fn t ->
        t.standings
        |> Enum.find(fn ps -> ps.battletag_full == battletag_full end)
        |> case do
          # this shouldn't be possible, but let's be safe
          nil ->
            []

          ps ->
            tournament_link =
              MastersTour.create_qualifier_link(t.tournament_slug, t.tournament_id)

            tournament_title = Recase.to_title(t.tournament_slug)

            player_link =
              Routes.battlefy_path(conn, :tournament_player, t.tournament_id, battletag_full)

            [
              %{
                competition: simple_link(tournament_link, tournament_title),
                time: t.start_time,
                position: simple_link(player_link, ps.position),
                score: "#{ps.wins} - #{ps.losses}"
              }
            ]
        end
      end)

    leaderboard_names = Backend.PlayerInfo.leaderboard_names(battletag_full)

    leaderboard_rows =
      finishes
      |> Enum.flat_map(fn f ->
        f.entries
        |> Enum.find(fn e -> leaderboard_names |> Enum.member?(e.account_id) end)
        |> case do
          # this shouldn't be possible, but let's be safe
          nil ->
            []

          pe ->
            leaderboard_link =
              Routes.leaderboard_path(
                conn,
                :index,
                %{
                  "leaderboardId" => f.leaderboard_id,
                  "seasonId" => f.season_id,
                  "region" => f.region
                  #                   "highlight" => [pe.account_id |> Backend.MastersTour.InvitedPlayer.shorten_battletag()]
                }
              )

            leaderboard_title =
              Blizzard.get_leaderboard_name(f.region, f.leaderboard_id, f.season_id)

            [
              %{
                competition: simple_link(leaderboard_link, leaderboard_title),
                time: f.upstream_updated_at,
                position: simple_link(leaderboard_link, pe.rank),
                score: pe.rating || ""
              }
            ]
        end
      end)

    table_rows =
      pick_competitions(competitions, %{
        qualifiers: qualifier_rows,
        leaderboard: leaderboard_rows,
        mt: mt_rows
      })
      # sorted descending. trial and errored it, ofc
      |> Enum.sort_by(fn r -> r.time end, fn a, b -> NaiveDateTime.compare(a, b) == :gt end)
      |> Enum.map(fn r ->
        ~E"""
        <tr>
          <td> <%= r.competition %> </td>
          <td> <%= r.position %> </td>
          <td> <%= r.score %> </td>
        <tr>
        """
      end)

    render("player_profile.html", %{
      bt: battletag_full,
      rows: rows,
      table_headers: table_headers,
      conn: conn,
      competition_options: get_competition_options(competitions),
      table_rows: table_rows
    })
  end

  def get_competition_options(competitions) do
    [{"qualifiers", "Qualifiers"}, {"leaderboard", "Leaderboards"}, {"mt", "MTs"}]
    |> Enum.map(fn {v, n} -> {v, n, competitions == [] || Enum.member?(competitions, v)} end)
  end

  def pick_competitions([], rows), do: rows |> Enum.flat_map(fn {_, r} -> r end)

  def pick_competitions(competitions, rows) do
    rows
    |> Enum.flat_map(fn {k, r} ->
      if Enum.member?(competitions, to_string(k)) do
        r
      else
        []
      end
    end)
  end
end
