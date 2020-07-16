defmodule BackendWeb.BattlefyView do
  require Logger
  use BackendWeb, :view
  alias Backend.Battlefy
  alias Backend.Battlefy.Organization

  @type future_opponent_team :: %{
          name: String.t(),
          yaytears: String.t(),
          hsdeckviewer: String.t(),
          link: String.t()
        }

  @type standings :: %{
          place: String.t(),
          name: String.t(),
          name_link: String.t(),
          has_score: boolean,
          score: String.t(),
          wins: integer,
          losses: integer,
          hsdeckviewer: String.t(),
          yaytears: String.t()
        }

  @spec handle_opponent_team(Battlefy.MatchTeam.t(), Battlefy.Tournament.t(), Plug.Conn.t()) ::
          nil
  def handle_opponent_team(%{team: nil}, _, _) do
    nil
  end

  @spec handle_opponent_team(Battlefy.MatchTeam.t(), Battlefy.Tournament.t(), Plug.Conn.t()) ::
          future_opponent_team
  def handle_opponent_team(%{team: %{name: name}}, %{id: tournament_id}, conn) do
    %{
      name: name,
      yaytears: Backend.Yaytears.create_deckstrings_link(tournament_id, name),
      hsdeckviewer: Routes.battlefy_path(conn, :tournament_decks, tournament_id, name),
      link: Routes.battlefy_path(conn, :tournament_player, tournament_id, name)
    }
  end

  def create_organization_dropdown(conn, org) do
    options =
      Battlefy.hardcoded_organizations()
      |> Enum.map(fn o ->
        %{
          selected: org && org.id == o.id,
          display: o |> Organization.display_name(),
          link:
            Routes.battlefy_path(
              conn,
              :organization_tournaments,
              Map.put(conn.query_params, "slug", o.slug)
            )
        }
      end)
      |> Enum.sort_by(fn d -> d.display end, :asc)

    {options, "Choose Organization"}
  end

  def create_daterange_dropdown(conn, {from, to}) do
    options =
      [{:week, "Week"}, {:month, "Month"}, {:year, "Year"}]
      |> Enum.map(fn {r, display} ->
        range = {f, t} = Util.get_range(r)

        %{
          selected: f == from && t == to,
          display: display,
          link: create_org_tour_link(range, conn)
        }
      end)

    {options, "Select Range"}
  end

  def render("organization_tournaments.html", %{
        from: from,
        to: to,
        tournaments: tour,
        org: org,
        conn: conn
      }) do
    range = {from, to}
    {before_range, after_range} = Util.get_surrounding_ranges(range)
    before_link = create_org_tour_link(before_range, conn)
    after_link = create_org_tour_link(after_range, conn)

    tournaments =
      (tour || [])
      |> Enum.map(fn t ->
        t
        |> Map.put_new(:link, Battlefy.create_tournament_link(t.slug, t.id, org.slug))
        |> Map.put_new(:standings_link, Routes.battlefy_path(conn, :tournament, t.id))
        |> Map.put_new(:yaytears, Backend.Yaytears.create_tournament_link(t.id))
      end)

    title =
      case org do
        nil ->
          "Choose organization"

        o ->
          link = Organization.create_link(o)
          name = o.name

          ~E"""
          <a class="is-link" href="<%= link %>"> <%= name %> </a>
          """
      end

    render("organization_tournaments.html", %{
      title: title,
      before_link: before_link,
      after_link: after_link,
      tournaments: tournaments,
      dropdowns: [
        create_organization_dropdown(conn, org),
        create_daterange_dropdown(conn, range)
      ],
      conn: conn
    })
  end

  def create_org_tour_link(range, conn) do
    new_params = conn.query_params |> Util.update_from_to_params(range)
    Routes.battlefy_path(conn, :organization_tournaments, new_params)
  end

  def render(
        "profile.html",
        %{
          tournament: tournament,
          opponent_matches: opponent_matches,
          player_matches: player_matches,
          team_name: team_name,
          conn: conn
        }
      ) do
    opponent =
      opponent_matches
      |> Enum.map(fn match = %{top: top, bottom: bottom, round_number: current_round} ->
        %{
          top: handle_opponent_team(top, tournament, conn),
          bottom: handle_opponent_team(bottom, tournament, conn),
          match_url: Battlefy.get_match_url(tournament, match),
          current_round: current_round,
          score: "#{top.score} - #{bottom.score}"
        }
      end)
      |> Enum.sort_by(fn o -> o.current_round end, :desc)

    player =
      player_matches
      |> Enum.map(fn match = %{top: top, bottom: bottom, round_number: rn} ->
        {player, opponent} =
          case {top.team, bottom.team} do
            {%{name: ^team_name}, _} ->
              {top, bottom || Battlefy.MatchTeam.empty()}

            {_, %{name: ^team_name}} ->
              {bottom, top || Battlefy.MatchTeam.empty()}

            _ ->
              Logger.warn("No team is the players team, wtf #{top.team} #{bottom.team}")
              {Battlefy.MatchTeam.empty(), Battlefy.MatchTeam.empty()}
          end

        %{
          score: "#{player.score} - #{opponent.score} ",
          match_url: Battlefy.get_match_url(tournament, match),
          opponent: handle_opponent_team(opponent, tournament, conn),
          current_round: rn
        }
      end)

    hsdeckviewer = Routes.battlefy_path(conn, :tournament_decks, tournament.id, team_name)
    yaytears = Backend.Yaytears.create_deckstrings_link(tournament.id, team_name)

    render("future_opponents.html", %{
      conn: conn,
      show_future: opponent |> Enum.any?(),
      show_player: player |> Enum.any?(),
      future_matches: opponent,
      player_matches: player,
      team_name: team_name,
      hsdeckviewer: hsdeckviewer,
      tournament: tournament,
      standings_link: Routes.battlefy_path(conn, :tournament, tournament.id),
      yaytears: yaytears
    })
  end

  def render(
        "tournament.html",
        params = %{standings: standings_raw, tournament: tournament, conn: conn}
      ) do
    standings = prepare_standings(standings_raw, tournament, conn)

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
      (tournament.stages || [])
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
      link: Battlefy.create_tournament_link(tournament),
      stages: stages,
      show_stage_selection: Enum.count(stages) > 1,
      stage_selection_text:
        if(selected_stage == nil, do: "Select Stage", else: selected_stage.name),
      show_score: standings |> Enum.any?(fn s -> s.has_score end)
    })
  end

  @spec prepare_standings([Battelfy.Standings.t()], Battlefy.Tournament.t(), Plug.Conn) :: [
          standings
        ]
  def prepare_standings(standings_raw, %{id: tournament_id}, conn) do
    standings_raw
    |> Enum.sort_by(fn s -> String.upcase(s.team.name) end)
    |> Enum.sort_by(fn s -> s.losses end)
    |> Enum.sort_by(fn s -> s.wins end, :desc)
    |> Enum.sort_by(fn s -> s.place end)
    |> Enum.map(fn s ->
      %{
        place: if(s.place && s.place > 0, do: s.place, else: "?"),
        name: s.team.name,
        name_link: Routes.battlefy_path(conn, :tournament_player, tournament_id, s.team.name),
        has_score: s.wins && s.losses,
        score: "#{s.wins} - #{s.losses}",
        wins: s.wins,
        losses: s.losses,
        hsdeckviewer: Routes.battlefy_path(conn, :tournament_decks, tournament_id, s.team.name),
        yaytears: Backend.Yaytears.create_deckstrings_link(tournament_id, s.team.name)
      }
    end)
  end
end
