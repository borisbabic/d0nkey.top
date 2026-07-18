defmodule BackendWeb.BattlefyController do
  use BackendWeb, :controller
  alias Backend.Battlefy
  alias Backend.Battlefy.MatchTeam
  alias Backend.Battlefy.Stage
  alias Backend.Battlefy.Tournament
  alias Backend.Infrastructure.BattlefyCommunicator, as: Api
  alias Backend.MastersTour.TourStop
  alias Backend.TournamentStreams
  require Logger

  defp direction("desc"), do: :desc
  defp direction("asc"), do: :asc
  defp direction(_), do: nil

  defp ongoing?(%{"show_ongoing" => ongoing}) when is_binary(ongoing),
    do: String.starts_with?(ongoing, "yes")

  defp ongoing?(_), do: false

  defp matches?(%{"show_matches" => matches}) when is_binary(matches),
    do: String.starts_with?(matches, "yes") or String.starts_with?(matches, "all")

  defp matches?(_), do: false

  defp show_earnings?(%{"show_earnings" => earnings}) when is_binary(earnings),
    do: String.starts_with?(earnings, "yes")

  defp show_earnings?(_), do: false

  defp show_lineups(%{"show_lineups" => <<"top_"::binary, to_show::bitstring>>}) do
    case Integer.parse(to_show) do
      {num, _} -> num
      _ -> false
    end
  end

  defp show_lineups(%{"show_lineups" => "yes"}), do: true
  defp show_lineups(_), do: false

  defp highlight_fantasy(%{"highlight_fantasy" => "no"}), do: false
  defp highlight_fantasy(_), do: true

  defp earnings(params, tournament_id) do
    with true <- show_earnings?(params),
         %{id: ts_id} = ts <-
           TourStop.all()
           |> Enum.find(fn ts -> ts.battlefy_id == tournament_id end),
         {:ok, season} <- Backend.Blizzard.get_promotion_season_for_gm(ts_id),
         {:ok, point_system} <- TourStop.gm_point_system(ts),
         earnings <- Backend.MastersTour.get_gm_money_rankings(season, point_system) do
      {earnings, true}
    else
      _ -> {[], false}
    end
  end

  def profile_tournament(conn, params), do: tournament(conn, params)

  def tournament(conn, %{"tournament_id" => tournament_id} = params) do
    Logger.debug("tournament params #{inspect(params)}")
    tournament = Battlefy.get_tournament(tournament_id)

    Logger.debug("Fetched tournament")
    invited_mapset = invited_mapset(params, tournament)
    participants = participants(params, tournament)
    Logger.debug("Fetched participants")
    {earnings, show_earnings} = earnings(params, tournament_id)
    Logger.debug("Earnings")

    fantasy_picks =
      conn
      |> BackendWeb.AuthUtils.user()
      |> Backend.Fantasy.get_battlefy_or_mt_user_picks(tournament_id)
      |> Enum.map(&(&1.pick |> Backend.Battlenet.Battletag.shorten()))

    Logger.debug("fetched fantasy picks")

    show_lineups = show_lineups(params)

    Logger.debug("Preparing to render tournament from controller")

    render(
      conn,
      "tournament.html",
      %{
        tournament: tournament,
        show_earnings: show_earnings,
        invited_mapset: invited_mapset,
        earnings: earnings,
        fantasy_picks: fantasy_picks,
        other_streams: TournamentStreams.get_for_tournament({"battlefy", params["tournament_id"]}),
        show_lineups: show_lineups,
        highlight_fantasy: highlight_fantasy(params),
        has_lineups: Backend.Hearthstone.has_lineups?(params["tournament_id"], "battlefy"),
        lineups: lineups(show_lineups, params["tournament_id"]),
        country_highlight: multi_select_to_array(params["country"]),
        page_title: Map.get(tournament, :name),
        stage_id: params["stage_id"],
        participants: participants,
        highlight: get_highlight(params)
      }
      |> add_standings_or_bracket(params)
      |> enqueue_missing_lineups()
    )
  end

  defp add_standings_or_bracket(existing, params) do
    if show_bracket?(existing.tournament, params) do
      add_bracket(existing, params)
    else
      add_matches_standings(existing, params)
    end
  end

  defp show_bracket?(_tournament, %{"view_mode" => view_mode}) do
    view_mode == "bracket"
  end

  defp show_bracket?(_tournament, %{"stage_id" => "all_brackets"}), do: true

  defp show_bracket?(tournament, %{"stage_id" => stage_id}) do
    with [_ | _] = stages <- tournament.stages,
         %{} = stage <-
           Enum.find(stages, &(&1.id == stage_id)) do
      bracketable_by_default?(stage)
    else
      _ -> false
    end
  end

  defp show_bracket?(%{stages: nil}, _), do: false

  defp show_bracket?(tournament, _) do
    Enum.at(tournament.stages, -1)
    |> bracketable_by_default?()
  end

  defp enqueue_missing_lineups(
         %{
           has_lineups: true,
           show_lineups: true,
           standings_raw: [_ | _] = standings,
           lineups: [_ | _] = lineups,
           tournament: tournament
         } = args
       ) do
    Backend.Battlefy.LineupFetcher.async_enqueue_missing_lineups(tournament, standings, lineups)
    args
  end

  defp enqueue_missing_lineups(args), do: args

  def participants(%{"show_actual_battletag" => "yes"}, %{id: id}),
    do: Battlefy.get_participants(id)

  def participants(_, _), do: []

  def invited_mapset(%{"show_invited" => ts}, %{id: id}) do
    with [_ | _] = invited <- Backend.MastersTour.list_invited_players(ts),
         [_ | _] = participants <- Battlefy.get_participants(id) do
      invited_ms = invited |> MapSet.new(& &1.battletag_full)

      participants
      |> Enum.flat_map(fn
        %{name: name, players: [%{in_game_name: ign}]} ->
          [{name, name}, {name, ign}]

        %{name: name} ->
          [{name, name}]

        _ ->
          []
      end)
      |> Enum.flat_map(fn {name, to_check} ->
        if MapSet.member?(invited_ms, to_check) do
          [name]
        else
          []
        end
      end)
      |> MapSet.new()
    else
      _ -> MapSet.new([])
    end
  end

  def invited_mapset(_, _), do: MapSet.new([])

  def lineups(show_lineups, tournament_id) when is_integer(show_lineups) or show_lineups == true,
    do: Battlefy.lineups(tournament_id)

  def lineups(_, tournament_id) do
    Backend.Battlefy.LineupFetcher.fetch_async_if_missing(tournament_id)
    []
  end

  defp bracketable_by_default?(%{bracket: %{teams_count: teams_count, type: "elimination"}})
       when is_integer(teams_count) do
    teams_count < 17
  end

  defp bracketable_by_default?(_), do: false

  defp add_bracket(existing, %{"stage_id" => "all_brackets"}) do
    add_all_brackets(existing)
  end

  defp add_bracket(existing, %{"stage_id" => stage_id}) do
    do_add_bracket(existing, stage_id)
  end

  defp add_bracket(%{tournament: tournament} = existing, _) do
    if Enum.all?(tournament.stages, &bracketable_by_default?/1) do
      add_all_brackets(existing)
    else
      stage_id =
        tournament.stages
        |> Enum.reverse()
        |> Enum.find(&Stage.bracketable?/1)

      do_add_bracket(existing, stage_id)
    end
  end

  defp do_add_bracket(existing, stage_id) do
    bracket = Battlefy.get_stage_bracket(stage_id)

    existing
    |> Map.put(:bracket_raw, bracket)
    |> Map.put(:view_mode, "bracket")
  end

  defp add_all_brackets(%{tournament: tournament} = existing) do
    brackets = tournament.stages |> Enum.map(&Battlefy.get_stage_bracket/1)

    existing
    |> Map.put(:brackets_raw, brackets)
    |> Map.put(:view_mode, "bracket")
    |> Map.put(:stage_id, "all_brackets")
  end

  defp add_matches_standings(existing, %{"stage_id" => stage_id} = params) do
    standings = Battlefy.get_stage_standings(stage_id)

    base =
      existing
      |> Map.merge(%{
        standings_raw: standings,
        show_ongoing: ongoing?(params),
        show_matches: matches?(params),
        matches: [],
        view_mode: "standings",
        standings_stage_id: stage_id
      })

    if fetch_matches?(base) do
      base
      |> Map.put(:matches, Battlefy.get_matches(stage_id))
    else
      base
    end
  end

  defp add_matches_standings(%{tournament: tournament} = existing, params) do
    base =
      existing
      |> Map.merge(%{
        standings_raw: [],
        matches: [],
        standings_stage_id: nil,
        view_mode: "standings",
        show_ongoing: ongoing?(params),
        show_matches: matches?(params)
      })

    case Battlefy.get_tournament_standings_and_stage_id(tournament) do
      {:ok, {stage_id, standings}} ->
        matches =
          if fetch_matches?(base) do
            Battlefy.get_tournament_matches(tournament)
          else
            []
          end

        base
        |> Map.merge(%{
          standings_raw: standings,
          matches: matches,
          view_mode: "standings",
          standings_stage_id: stage_id
        })

      _ ->
        base
    end
  end

  defp fetch_matches?(%{show_ongoing: so, show_matches: sm}), do: so or sm
  defp fetch_matches?(_), do: false
  def get_highlight(params), do: multi_select_to_array(params["player"])

  def tournament_decks(conn, %{
        "tournament_id" => tournament_id,
        "team_name" => team_name
      }) do
    tournament_decks =
      Battlefy.get_deckstrings(%{tournament_id: tournament_id, battletag_full: team_name})

    link = Backend.HSDeckViewer.create_link(tournament_decks)
    redirect(conn, external: link)
  end

  # somebody is spamming this, :shrug:
  def tournament_player(_conn, %{"team_name" => "&"}) do
    Components.Helper.empty()
  end

  def tournament_player(
        conn,
        %{
          "tournament_id" => tournament_id,
          "team_name" => team_name_raw
        } = params
      ) do
    team_name = URI.decode_www_form(team_name_raw)
    {opponent_matches, player_matches, stage_id} = future_and_player(params)

    needed_deckcodes = [
      team_name
      | get_battletags(opponent_matches.winner ++ opponent_matches.loser ++ player_matches)
    ]

    all_deckcodes =
      Battlefy.get_deckstrings(
        %{stage_id: stage_id, tournament_id: tournament_id},
        needed_deckcodes
      )

    deckcodes = Map.get(all_deckcodes, team_name, [])

    tournament = Battlefy.get_tournament(tournament_id)

    render(conn, "profile.html", %{
      tournament: tournament,
      opponent_matches: opponent_matches,
      player_matches: player_matches,
      page_title: team_name,
      deckcodes: deckcodes,
      all_deckcodes: all_deckcodes,
      team_name: team_name,
      stage_id: stage_id,
      conn: conn
    })
  end

  defp get_battletags(matches) do
    Enum.reduce(matches, MapSet.new(), fn %{top: top, bottom: bottom}, acc ->
      acc
      |> MapSet.put(MatchTeam.get_name(top))
      |> MapSet.put(MatchTeam.get_name(bottom))
    end)
    |> MapSet.to_list()
  end

  defp future_and_player(%{"stage_id" => stage_id, "team_name" => team_name}) do
    with {[], [], nil} <- Battlefy.get_future_and_player_stage_matches(stage_id, team_name) do
      {Battlefy.empty_opponent_matches(), [], stage_id}
    end
  end

  defp future_and_player(%{"tournament_id" => tournament_id, "team_name" => team_name}),
    do: Battlefy.get_future_and_player_matches(tournament_id, team_name)

  defp future_and_player(_),
    do: {Battlefy.empty_opponent_matches(), [], nil}

  def organization_tournament_stats(conn, %{"stats_slug" => stats_slug}) do
    with %{organization_slug: org_slug, from: from, pattern: pattern, title: title} <-
           Battlefy.stats_config(stats_slug),
         %{id: org_id} <- Api.get_organization(org_slug),
         tournaments when is_list(tournaments) <-
           org_id |> Api.get_organization_tournaments_from_to(from, Date.utc_today()),
         filtered <- tournaments |> Enum.filter(&Regex.match?(pattern, &1.name)) do
      ids = filtered |> Enum.map(fn t -> t.id end)

      redirect(conn,
        to: Routes.battlefy_path(conn, :tournaments_stats, %{tournament_ids: ids, title: title})
      )
    else
      _ ->
        text(
          conn,
          "Something went wrong, did you tamper with the link you naughty " <>
            Enum.random(["boy", "girl", "dog", "thing"])
        )
    end
  end

  def organization_tournaments(conn, %{
        "from" => %Date{} = from,
        "to" => %Date{} = to,
        "slug" => slug
      }) do
    {org, tournaments} =
      slug
      |> Api.get_organization()
      |> case do
        nil ->
          {nil, []}

        org ->
          {
            org,
            org.id
            |> Api.get_organization_tournaments_from_to(from, to)
            |> Enum.filter(fn t -> t.game |> Tournament.Game.hearthstone?() end)
          }
      end

    page_title =
      case org do
        %{name: name} when not is_nil(name) -> "#{name} Tournaments"
        _ -> "3rd Party Tournaments"
      end

    render(conn, "organization_tournaments.html", %{
      from: from,
      to: to,
      org: org,
      page_title: page_title,
      tournaments: tournaments
    })
  end

  def organization_tournaments(conn, %{"from" => %Date{} = from, "to" => %Date{} = to}) do
    render(conn, "organization_tournaments.html", %{
      from: from,
      to: to,
      tournaments: [],
      org: nil,
      page_title: "3rd Party Tournaments"
    })
  end

  def organization_tournaments(conn, %{"from" => from, "to" => to} = params) do
    from_date = Date.from_iso8601!(from)
    to_date = Date.from_iso8601!(to)
    organization_tournaments(conn, %{params | "from" => from_date, "to" => to_date})
  end

  def organization_tournaments(conn, params) do
    today = Date.utc_today()
    from = Date.add(today, -30)
    to = Date.add(today, 30)
    organization_tournaments(conn, Map.merge(params, %{"from" => from, "to" => to}))
  end

  def user_tournaments(conn, %{"slug" => slug} = params) do
    page = params["page"] |> Util.to_int(1)
    tournaments = Api.get_user_tournaments(slug, page)

    render(conn, "user_tournaments.html", %{
      slug: slug,
      page: page,
      page_title: "#{slug}'s Tournaments'",
      tournaments: tournaments
    })
  end

  defp list_or_comma_separated(list) when is_list(list), do: list
  defp list_or_comma_separated(string) when is_binary(string), do: string |> String.split(",")

  def tournaments_stats(conn, %{"tournament_ids" => tournament_ids} = params) do
    direction = direction(params["direction"])
    selected_columns = multi_select_to_array(params["columns"])

    tournaments =
      tournament_ids
      |> list_or_comma_separated()
      |> Enum.filter(&(&1 && &1 != ""))
      |> Enum.take(20)
      |> Enum.map(&Battlefy.get_tournament/1)

    tournaments_stats =
      tournaments
      |> Enum.map(&Battlefy.create_tournament_stats/1)
      |> Enum.filter(fn tts -> not Enum.empty?(tts) end)

    page_title =
      case params["title"] do
        title when is_binary(title) -> "#{title} Stats"
        _ -> "Tournaments Stats"
      end

    render(conn, "tournaments_stats.html", %{
      tournaments: tournaments,
      tournaments_stats: tournaments_stats,
      direction: direction,
      selected_columns: selected_columns,
      min_matches: params["min_matches"] |> Util.to_int_or_orig(),
      min_tournaments: params["min_tournaments"] |> Util.to_int_or_orig(),
      page_title: page_title,
      title: params["title"],
      sort_by: params["sort_by"]
    })
  end

  def tournaments_stats(conn, %{"tournaments" => tournaments_raw} = params) do
    tournaments =
      if is_binary(tournaments_raw),
        do: String.split(tournaments_raw, ["\n", "\r\n"]),
        else: tournaments_raw

    tournament_ids =
      Enum.map(tournaments, &Battlefy.tournament_link_to_id/1) |> Enum.filter(& &1)

    new_params =
      params
      |> Map.delete("tournaments")
      |> Map.put("tournament_ids", tournament_ids |> Enum.join(","))

    new_url = Routes.battlefy_path(conn, :tournaments_stats, new_params)

    conn
    |> Plug.Conn.put_status(302)
    |> redirect(to: new_url)
  end

  def tournaments_stats(conn, params) do
    render(conn, "tournaments_stats_input.html", %{
      conn: conn,
      edit: params["edit"],
      page_title: "Tournaments Stats"
    })
  end
end
