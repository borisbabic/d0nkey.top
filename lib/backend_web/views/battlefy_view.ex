defmodule BackendWeb.BattlefyView do
  require Logger
  use BackendWeb, :view
  alias Backend.Hearthstone.Lineup
  alias Backend.MastersTour
  alias Backend.Battlefy
  alias Backend.Battlefy.Organization
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchTeam
  alias Backend.MastersTour

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

  def render("tournament_table.html", params = %{conn: conn, raw: raw}) do
    slug = fn t -> (t.organization && t.organization.slug) || params[:slug] end

    tournaments =
      raw
      |> Enum.map(fn t ->
        t
        |> Map.put_new(:link, Battlefy.create_tournament_link(t.slug, t.id, t |> slug.()))
        |> Map.put_new(:standings_link, Routes.battlefy_path(conn, :tournament, t.id))
        |> Map.put_new(:yaytears, Backend.Yaytears.create_tournament_link(t.id))
      end)

    render("tournament_table.html", %{tournaments: tournaments})
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

    dropdowns =
      [
        create_organization_dropdown(conn, org),
        create_daterange_dropdown(conn, range)
      ]
      |> add_stats_dropdown(conn, org)

    render("organization_tournaments.html", %{
      title: title,
      before_link: before_link,
      after_link: after_link,
      tournaments: tour || [],
      slug: org && org.slug,
      dropdowns: dropdowns,
      conn: conn
    })
  end

  def add_stats_dropdown(dropdowns, _, nil), do: dropdowns

  def add_stats_dropdown(dropdowns, conn, org) do
    case org.slug |> Battlefy.organization_stats() do
      stats_configs = [_ | _] ->
        options =
          stats_configs
          |> Enum.map(fn %{title: title, stats_slug: ss} ->
            %{
              selected: false,
              display: title,
              link: Routes.battlefy_path(conn, :organization_tournament_stats, ss)
            }
          end)

        dropdowns ++ [{options, "Stats"}]

      _ ->
        dropdowns
    end
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
          deckcodes: deckcodes,
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

    {player, class_stats_raw} = handle_player_matches(player_matches, team_name, tournament, conn)
    hsdeckviewer = Routes.battlefy_path(conn, :tournament_decks, tournament.id, team_name)
    yaytears = Backend.Yaytears.create_deckstrings_link(tournament.id, team_name)
    class_stats = class_stats_raw |> Enum.map(fn {_k, v} -> v end)

    render("future_opponents.html", %{
      conn: conn,
      show_future: opponent |> Enum.any?(),
      show_player: player |> Enum.any?(),
      future_matches: opponent,
      player_matches: player,
      team_name: team_name,
      hsdeckviewer: hsdeckviewer,
      deckcodes: deckcodes,
      tournament: tournament,
      class_stats: class_stats,
      show_class_stats: class_stats |> Enum.count() > 0,
      standings_link: Routes.battlefy_path(conn, :tournament, tournament.id),
      yaytears: yaytears
    })
  end

  def handle_player_matches(player_matches, team_name, tournament, conn) do
    player_matches
    |> Enum.map_reduce(%{}, fn match = %{top: top, bottom: bottom, round_number: rn}, acc ->
      {player, opponent, player_place, opponent_place} =
        case {top.team, bottom.team} do
          {%{name: ^team_name}, _} ->
            {top, bottom || Battlefy.MatchTeam.empty(), :top, :bottom}

          {_, %{name: ^team_name}} ->
            {bottom, top || Battlefy.MatchTeam.empty(), :bottom, :top}

          _ ->
            Logger.warn("No team is the players team, wtf #{top.team} #{bottom.team}")
            {Battlefy.MatchTeam.empty(), Battlefy.MatchTeam.empty(), nil, nil}
        end

      class_stats = Match.create_class_stats(match, player_place)
      opponent_class_stats = Match.create_class_stats(match, opponent_place)

      {
        %{
          score: "#{player.score} - #{opponent.score} ",
          match_url: Battlefy.get_match_url(tournament, match),
          opponent: handle_opponent_team(opponent, tournament, conn),
          class_stats: class_stats,
          opponent_class_stats: opponent_class_stats,
          current_round: rn
        },
        class_stats
        |> Battlefy.ClassMatchStats.merge_collections(acc)
      }
    end)
  end

  @spec calculate_ongoing([Match.t()], boolean, Battlefy.Tournament.t(), Plug.Conn.t()) :: Map.t()

  def calculate_ongoing(_, _show_ongoing = false, _, _), do: Map.new()

  def calculate_ongoing(matches, _show_ongoing = true, tournament, conn) do
    matches
    |> Enum.filter(&Match.ongoing?/1)
    |> Enum.flat_map(fn m = %{top: t, bottom: b} ->
      [
        {
          t |> MatchTeam.get_name(),
          %{
            score: "#{t.score} - #{b.score}",
            match_url: Battlefy.get_match_url(tournament, m),
            opponent: b |> MatchTeam.get_name(),
            opponent_link:
              Routes.battlefy_path(
                conn,
                :tournament_player,
                tournament.id,
                b |> MatchTeam.get_name() || ""
              )
          }
        },
        {
          b |> MatchTeam.get_name(),
          %{
            score: "#{b.score} - #{t.score}",
            match_url: Battlefy.get_match_url(tournament, m),
            opponent: t |> MatchTeam.get_name(),
            opponent_link:
              Routes.battlefy_path(
                conn,
                :tournament_player,
                tournament.id,
                t |> MatchTeam.get_name()
              )
          }
        }
      ]
    end)
    |> Map.new()
  end

  def tour_stop?(%{id: id}),
    do: !!Backend.MastersTour.TourStop.get_by(:battlefy_id, id)

  def render("class_match_stats.html", %{class: class, bans: 1}) do
    ~E"""
    <img class="image is-32x32" style="opacity:0.2;" src="<%= class_url(class) %>" >
    """
  end

  defp class_url(class), do: "/images/icons/#{class}.png"

  @win_color "hsl(141, 53%, 53%)"
  @loss_color "hsl(348, 86%, 61%)"
  @result_width 2
  @border_width 1
  @border_color "black"
  defp build_box_shadow(wins, losses) do
    {
      @border_width + (wins + losses) * @result_width,
      """
      border_radius: 100%;
      box-shadow: 0 0 0 #{@border_width}px #{@border_color}
        , 0 0 0 #{@border_width + losses * @result_width}px #{@loss_color}
        , 0 0 0 #{@border_width + (wins + losses) * @result_width}px #{@win_color}
        ;
      """
    }
  end

  def render("class_match_stats.html", %{class: class, bans: 0, wins: wins, losses: losses}) do
    image_url = class_url(class)

    text_coloring_class =
      case wins - losses do
        # n when n > 0 -> "has-text-success"
        # _ -> "has-text-danger"
        _ -> "has-text-dark"
      end

    {offset, border_css} = build_box_shadow(wins, losses)
    size = 32 - offset
    style = border_css <> "height: #{size}px; width: #{size}px; margin: 3px #{offset}px;"

    ~E"""
    <figure class="image is-rounded">
      <img class="image is-rounded" style="<%= style %>" src="<%= image_url %>"/>
    </figure>
    """
  end

  def render(u = "tournaments_stats.html", p = %{conn: conn, tournaments: tournaments}) do
    tournaments_string =
      tournaments
      |> Enum.map(fn %{name: name, id: id} ->
        "#{id} # #{name}"
      end)
      |> Enum.join("\n")

    edit_tournaments_link =
      Routes.battlefy_path(conn, :tournaments_stats, %{edit: tournaments_string})

    table_params =
      p
      |> Map.put(
        :link_creator,
        fn params ->
          Routes.battlefy_path(conn, :tournament_stats, conn.query_params |> Map.merge(params))
        end
      )
      |> Map.put(
        :dropdown_row,
        ~E"""
        <a href="<%= edit_tournaments_link %>" class="is-link button"><- Edit tournaments</a>
        """
      )

    title = p[:title] || "Custom Tournaments Stats"
    render("tournaments_stats.html", %{conn: conn, table_params: table_params, title: title})
  end

  def render("tournaments_stats_input.html", %{conn: conn, edit: edit}) do
    self_link = Routes.battlefy_path(conn, :tournaments_stats)

    render("tournaments_stats_input.html", %{
      c: conn,
      self_link: self_link,
      title: "Tournament Stats",
      edit: edit
    })
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def render(
        "tournament.html",
        params = %{
          standings: standings_raw,
          tournament: tournament,
          conn: conn,
          earnings: earnings,
          show_earnings: show_earnings,
          show_ongoing: show_ongoing,
          lineups: lineups,
          fantasy_picks: fantasy_picks,
          show_lineups: show_lineups,
          highlight_fantasy: highlight_fantasy,
          matches: matches
        }
      ) do
    ongoing = calculate_ongoing(matches, show_ongoing, tournament, conn)
    is_tour_stop = tour_stop?(tournament)

    standings =
      prepare_standings(standings_raw, tournament, ongoing, conn, is_tour_stop, earnings, lineups)

    highlight = if params.highlight == nil, do: [], else: params.highlight
    country_highlight = if params.country_highlight == nil, do: [], else: params.country_highlight
    fantasy_highlight = if highlight_fantasy, do: fantasy_picks, else: []

    highlighted_standings =
      standings
      |> Enum.filter(fn s ->
        highlight |> Enum.member?(s.name) ||
          (s.country != nil && country_highlight |> Enum.member?(s.country)) ||
          fantasy_highlight |> Enum.member?(s.name)
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
      (tournament.stages || [])
      |> Enum.map(fn s ->
        %{
          name: s.name,
          link: Routes.battlefy_path(conn, :tournament, tournament.id, %{stage_id: s.id}),
          selected: params[:stage_id] && params[:stage_id] == s.id
        }
      end)

    selected_stage = stages |> Enum.find_value(fn s -> s.selected && s end)

    player_options =
      standings
      |> Enum.map(fn s ->
        %{
          name: s.name,
          selected: s.name in highlight,
          display: s.name,
          value: s.name
        }
      end)
      |> Enum.sort_by(fn p -> p.name end)

    dropdowns =
      [get_ongoing_dropdown(conn, tournament, show_ongoing)]
      |> add_lineups_dropdown(conn, show_lineups, tournament)
      |> add_earnings_dropdown(is_tour_stop, conn, tournament, show_earnings)
      |> add_highlight_fantasy_dropdown(conn, highlight_fantasy, tournament, fantasy_picks)

    render("tournament.html", %{
      standings: standings,
      highlight: highlighted_standings,
      id: tournament.id,
      conn: conn,
      player_options: player_options,
      selected_countries: country_highlight,
      use_countries: is_tour_stop,
      subtitle: subtitle,
      name: tournament.name,
      dropdowns: dropdowns,
      link: Battlefy.create_tournament_link(tournament),
      stages: stages,
      show_stage_selection: Enum.count(stages) > 1,
      show_ongoing: show_ongoing,
      show_earnings: show_earnings,
      deck_num: max_decks(lineups),
      stage_selection_text:
        if(selected_stage == nil, do: "Select Stage", else: selected_stage.name),
      show_score: standings |> Enum.any?(fn s -> s.has_score end)
    })
  end

  def add_highlight_fantasy_dropdown(dds, conn, highlight_fantasy, tournament, [_ | _]) do
    dds ++
      [
        {[
           %{
             display: "Yes",
             selected: highlight_fantasy,
             link:
               Routes.battlefy_path(
                 conn,
                 :tournament,
                 tournament.id,
                 Map.put(conn.query_params, "highlight_fantasy", "yes")
               )
           },
           %{
             display: "No",
             selected: !highlight_fantasy,
             link:
               Routes.battlefy_path(
                 conn,
                 :tournament,
                 tournament.id,
                 Map.put(conn.query_params, "highlight_fantasy", "no")
               )
           }
         ], "Highlight Fantasy Picks"}
      ]
  end

  def add_highlight_fantasy_dropdown(dds, _, _, _, _), do: dds

  def add_earnings_dropdown(dds, false, _, _, _), do: dds

  def add_earnings_dropdown(dds, true, conn, tournament, show_earnings),
    do: dds ++ [get_earnings_dropdown(conn, tournament, show_earnings)]

  def add_lineups_dropdown(dds, conn, show_lineups, tournament) do
    dds ++
      [
        {[
           %{
             display: ~E"""
             <span><%= warning_triangle() %> Yes</span>
             """,
             selected: show_lineups,
             link:
               Routes.battlefy_path(
                 conn,
                 :tournament,
                 tournament.id,
                 Map.put(conn.query_params, "show_lineups", "yes")
               )
           },
           %{
             display: "No",
             selected: !show_lineups,
             link:
               Routes.battlefy_path(
                 conn,
                 :tournament,
                 tournament.id,
                 Map.put(conn.query_params, "show_lineups", "no")
               )
           }
         ], "Show lineups"}
      ]
  end

  defp max_decks(lineups = [%{decks: _} | _]),
    do: lineups |> Enum.map(&(&1.decks |> Enum.count())) |> Enum.max()

  defp max_decks(_), do: 0

  def get_ongoing_dropdown(conn, tournament, show_ongoing) do
    {[
       %{
         display: "Yes",
         selected: show_ongoing,
         link:
           Routes.battlefy_path(
             conn,
             :tournament,
             tournament.id,
             Map.put(conn.query_params, "show_ongoing", "yes")
           )
       },
       %{
         display: "No",
         selected: !show_ongoing,
         link:
           Routes.battlefy_path(
             conn,
             :tournament,
             tournament.id,
             Map.put(conn.query_params, "show_ongoing", "no")
           )
       }
     ], "Show Ongoing"}
  end

  def get_earnings_dropdown(conn, tournament, show_earnings) do
    {[
       %{
         display: "Yes",
         selected: show_earnings,
         link:
           Routes.battlefy_path(
             conn,
             :tournament,
             tournament.id,
             Map.put(conn.query_params, "show_earnings", "yes")
           )
       },
       %{
         display: "No",
         selected: !show_earnings,
         link:
           Routes.battlefy_path(
             conn,
             :tournament,
             tournament.id,
             Map.put(conn.query_params, "show_earnings", "no")
           )
       }
     ], "Show Earnings"}
  end

  defp player_earnings(earnings, player) do
    earnings
    |> Enum.find_value(fn {name, total, _} ->
      MastersTour.same_player?(name, player) && total
    end)
  end

  @spec prepare_standings(
          [Battelfy.Standings.t()] | nil,
          Battlefy.Tournament.t(),
          [{String.t(), String.t()}],
          Plug.Conn,
          boolean,
          MastersTour.gm_money_rankings(),
          [Lineup.t()]
        ) :: [
          standings
        ]
  def prepare_standings(nil, _, _, _, _, _, _), do: []

  def prepare_standings(
        standings_raw,
        %{id: tournament_id},
        ongoing,
        conn,
        use_countries,
        earnings,
        lineups
      ) do
    lineup_map = lineups |> Enum.map(&{&1.name, &1}) |> Map.new()

    standings_raw
    |> Enum.sort_by(fn s -> String.upcase(s.team.name) end)
    |> Enum.sort_by(fn s -> s.losses end)
    |> Enum.sort_by(fn s -> s.wins end, :desc)
    |> Enum.sort_by(fn s -> s.place end)
    |> Enum.map(fn s ->
      {country, pre_name_cell} =
        with true <- use_countries,
             cc when is_binary(cc) <- Backend.PlayerInfo.get_country(s.team.name) do
          {cc, country_flag(cc)}
        else
          _ -> {nil, ""}
        end

      %{
        place: if(s.place && s.place > 0, do: s.place, else: "?"),
        country: country,
        name: s.team.name,
        name_class: if(s.disqualified, do: "disqualified-player", else: ""),
        earnings: player_earnings(earnings, s.team.name),
        pre_name_cell: pre_name_cell,
        name_link: Routes.battlefy_path(conn, :tournament_player, tournament_id, s.team.name),
        has_score: s.wins && s.losses,
        score: "#{s.wins} - #{s.losses}",
        wins: s.wins,
        losses: s.losses,
        ongoing: ongoing |> Map.get(s.team.name),
        hsdeckviewer: Routes.battlefy_path(conn, :tournament_decks, tournament_id, s.team.name),
        lineup: lineup_map[s.team.name],
        yaytears: Backend.Yaytears.create_deckstrings_link(tournament_id, s.team.name)
      }
    end)
  end

  def render("user_tournaments.html", %{
        slug: slug,
        page: page,
        tournaments: tournaments,
        conn: conn
      }) do
    render(
      "user_tournaments.html",
      %{
        title: "#{slug}'s Battlefy Tournaments",
        subtitle: "Public tournaments only",
        tournaments: tournaments,
        conn: conn,
        slug: slug,
        prev_button: prev_button(conn, page - 1, slug),
        next_button: next_button(conn, page + 1, slug)
      }
    )
  end

  @spec next_button(Plug.Conn.t(), integer(), String.t()) :: Phoenix.HTML.Safe.t()
  def next_button(conn, next_page, slug) do
    new_params = conn.query_params |> Map.put("page", next_page)
    link = Routes.battlefy_path(conn, :user_tournaments, slug, new_params)

    ~E"""
    <a class="icon button is-link" href="<%= link %>">
      <i class="fas fa-caret-right"></i>
    </a>
    """
  end

  @spec prev_button(Plug.Conn.t(), integer(), String.t()) :: Phoenix.HTML.Safe.t()
  def prev_button(_, 0, _),
    do: ~E"""
      <span class="icon button is-link">
          <i class="fas fa-caret-left"></i>
      </span>
    """

  def prev_button(conn, prev_page, slug) do
    new_params = conn.query_params |> Map.put("page", prev_page)
    link = Routes.battlefy_path(conn, :user_tournaments, slug, new_params)

    ~E"""
    <a class="icon button is-link" href="<%= link %>">
      <i class="fas fa-caret-left"></i>
    </a>
    """
  end
end
