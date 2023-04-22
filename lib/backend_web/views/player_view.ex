defmodule BackendWeb.PlayerView do
  use BackendWeb, :view

  alias Backend.Blizzard
  alias Backend.Battlenet.Battletag
  alias Backend.MastersTour.PlayerStats
  alias Backend.MastersTour.TourStop
  alias Backend.TournamentStats.TeamStats
  alias Backend.TournamentStats.TournamentTeamStats
  alias BackendWeb.ViewUtil

  defp simple_link(href, text) do
    ~E"""
    <a class="is-link" href="<%= href %>"><%= text %></a>
    """
  end

  def render(
        "player_profile.html",
        %{
          battletags: battletags,
          qualifier_stats: qs,
          player_info: pi,
          tournaments: t,
          battletag_full: battletag_full,
          finishes: finishes,
          competitions: competitions,
          tournament_team_stats: tts,
          conn: conn
        }
      ) do
    short_btags = Enum.map(battletags, &Battletag.shorten/1)

    update_link = fn new_params ->
      merged_params = conn.query_params |> Map.merge(new_params)

      Routes.player_path(
        conn,
        :player_profile,
        battletag_full,
        merged_params
      )
    end

    %{
      limit: limit,
      offset: offset,
      prev_button: prev_button,
      next_button: next_button,
      dropdown: limit_dropdown
    } =
      ViewUtil.handle_pagination(conn.query_params, update_link,
        default_limit: 200,
        limit_options: [50, 100, 150, 200, 250, 300, 350, 500, 750, 1000, 2000, 3000, 4000, 5000]
      )

    stats_rows =
      qs
      |> Enum.flat_map(fn {period, ps} ->
        if ps |> PlayerStats.with_result() > 0 do
          [
            {"#{period} MTQ played", ps |> PlayerStats.with_result()},
            {"#{period} MTQ winrate", ps |> PlayerStats.matches_won_percent() |> Float.round(2)}
          ]
        else
          []
        end
      end)

    mt_total_stats =
      tts |> Enum.map(&TournamentTeamStats.total_stats/1) |> TeamStats.calculate_team_stats()

    mt_total_row =
      if mt_total_stats.wins + mt_total_stats.losses > 0 do
        [{"MT Match Score", "#{mt_total_stats.wins} - #{mt_total_stats.losses}"}]
      else
        []
      end

    rows =
      (stats_rows ++ mt_total_row)
      |> Enum.map(fn {title, val} -> "#{title}: #{val}" end)

    table_headers =
      [
        "Competition",
        "Place",
        "Score"
      ]
      |> Enum.map(fn h -> ~E"<th><%= h %></th>" end)

    mt_rows = mt_rows(tts, conn)

    qualifier_rows = qualifier_rows(t, battletags, conn)

    leaderboard_rows = leaderboard_rows(finishes, short_btags, conn)

    table_rows =
      pick_competitions(competitions, %{
        qualifiers: qualifier_rows,
        leaderboard: leaderboard_rows,
        mt: mt_rows
      })
      # sorted descending. trial and errored it, ofc
      |> Enum.sort_by(fn r -> r.time end, fn a, b -> NaiveDateTime.compare(a, b) == :gt end)
      |> Enum.drop(offset)
      |> Enum.take(limit)
      |> Enum.map(fn r ->
        ~E"""
        <tr>
          <td> <%= r.competition %> </td>
          <td> <%= r.position %> </td>
          <td> <%= r.score %> </td>
        <tr>
        """
      end)

    dropdowns = [
      limit_dropdown,
      ldb_leaderboard_dropdown(conn),
      ldb_region_dropdown(conn)
    ]

    render("player_profile.html", %{
      bt: battletag_full,
      rows: rows,
      table_headers: table_headers,
      prev_button: prev_button,
      next_button: next_button,
      dropdowns: dropdowns,
      conn: conn,
      competition_options: get_competition_options(competitions),
      table_rows: table_rows
    })
  end

  @leaderboard_key "ldb_leaderboard_id"
  defp ldb_leaderboard_dropdown(conn) do
    current = Map.get(conn.query_params, @leaderboard_key)

    options =
      Backend.Blizzard.leaderboards_with_name()
      |> Enum.map(fn {id, name} ->
        %{
          display: name,
          selected: to_string(id) == current,
          link:
            Routes.player_path(
              conn,
              :player_profile,
              conn.params["battletag_full"],
              Map.put(conn.query_params, @leaderboard_key, id)
            )
        }
      end)

    {options, dropdown_title(options, "Leaderboard")}
  end

  @ldb_region_key "ldb_region"
  defp ldb_region_dropdown(conn) do
    current = Map.get(conn.query_params, @ldb_region_key)

    options =
      Backend.Blizzard.qualifier_regions_with_name()
      |> Enum.map(fn {r, name} ->
        %{
          display: name,
          selected: to_string(r) == current,
          link:
            Routes.player_path(
              conn,
              :player_profile,
              conn.params["battletag_full"],
              Map.put(conn.query_params, @ldb_region_key, r)
            )
        }
      end)

    {options, dropdown_title(options, "Leaderboard Region")}
  end

  @spec mt_rows([TournamentTeamStats.t()], Plug.Conn.t()) :: [any()]
  def mt_rows(tts, conn) do
    tts
    |> Enum.map(fn ts ->
      swiss = ts |> TournamentTeamStats.filter_stages(:swiss)
      stats = ts |> TournamentTeamStats.total_stats()
      position = stats |> TeamStats.best()
      tour_stop = TourStop.get(ts.tournament_name)
      tournament_link = Routes.battlefy_path(conn, :tournament, ts.tournament_id)
      tournament_title = "MT #{TourStop.display_name(tour_stop) |> to_string()}"

      score =
        case swiss do
          %{wins: wins, losses: losses} -> "#{swiss.wins} - #{swiss.losses}"
          _ -> ""
        end

      player_link = Routes.battlefy_path(conn, :tournament_player, ts.tournament_id, ts.team_name)

      %{
        competition: simple_link(tournament_link, tournament_title),
        time: tour_stop.start_time,
        position: simple_link(player_link, position),
        score: score
      }
    end)
  end

  def qualifier_rows(tournaments, battletags, conn) do
    tournaments
    |> Enum.flat_map(fn t ->
      t.standings
      |> Enum.find(fn ps -> ps.battletag_full in battletags end)
      |> case do
        # this shouldn't be possible, but let's be safe
        nil ->
          []

        ps ->
          tournament_link = Routes.battlefy_path(conn, :tournament, t.tournament_id)

          tournament_title = Recase.to_title(t.tournament_slug)

          player_link =
            Routes.battlefy_path(conn, :tournament_player, t.tournament_id, ps.battletag_full)

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
  end

  def leaderboard_rows(finishes, leaderboard_names, conn) do
    finishes
    |> Enum.map(fn e ->
      leaderboard_link =
        Routes.leaderboard_path(
          conn,
          :index,
          %{
            "leaderboardId" => e.season.leaderboard_id,
            "seasonId" => e.season.season_id,
            "region" => e.season.region
            #                   "highlight" => [pe.account_id |> Backend.MastersTour.InvitedPlayer.shorten_battletag()]
          }
        )

      leaderboard_title =
        Blizzard.get_leaderboard_name(
          e.season.region,
          e.season.leaderboard_id,
          e.season.season_id
        )

      score =
        if e.rating do
          history_link = history_link(conn, e.season, e.account_id, :rating)

          assigns = %{
            rating: Backend.Leaderboards.rating_display(e.rating, e.season.leaderboard_id),
            link: history_link
          }

          ~H"""
          <%= @rating %> <%= @link %>
          """
        else
          ""
        end

      %{
        competition: simple_link(leaderboard_link, leaderboard_title),
        time: e.inserted_at,
        position:
          concat(
            simple_link(leaderboard_link, e.rank),
            history_link(conn, e.season, e.account_id, :rank)
          ),
        score: score
      }
    end)
  end

  def concat(first, second) do
    ~E"""
    <%= first %> <%= second %>
    """
  end

  def history_link(conn, ss, player, attr \\ "rank", period_param \\ nil)
  def history_link(_conn, _ss, nil, _attr, _period_param), do: nil

  def history_link(conn, ss, player, attr, period_param) do
    period = if period_param, do: period_param, else: "season_#{ss.season_id}"

    link =
      Routes.leaderboard_path(conn, :player_history, ss.region, period, ss.leaderboard_id, player,
        attr: attr
      )

    history_link(%{link: link})
  end

  def history_link(assigns) do
    ~H"""
      <a href={@link}>
        <span class="icon">
          <i class="fas fa-history"></i>
        </span>
      </a>
    """
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
