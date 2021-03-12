defmodule BackendWeb.BattlefyController do
  use BackendWeb, :controller
  alias Backend.Battlefy
  alias Backend.Battlefy.Tournament
  alias Backend.Infrastructure.BattlefyCommunicator, as: Api
  defp direction("desc"), do: :desc
  defp direction("asc"), do: :asc
  defp direction(_), do: nil

  defp is_ongoing(%{"show_ongoing" => ongoing}) when is_binary(ongoing),
    do: String.starts_with?(ongoing, "yes")

  defp is_ongoing(_), do: false

  defp show_earnings?(%{"show_earnings" => earnings}) when is_binary(earnings),
    do: String.starts_with?(earnings, "yes")

  defp show_earnings?(_), do: false

  defp show_lineups(%{"show_lineups" => "yes"}), do: true
  defp show_lineups(_), do: false

  defp earnings(params, tournament_id) do
    with true <- show_earnings?(params),
         ts = %{id: ts_id} <-
           Backend.MastersTour.TourStop.all()
           |> Enum.find(fn ts -> ts.battlefy_id == tournament_id end),
         {:ok, season} <- Backend.Blizzard.get_promotion_season_for_gm(ts_id),
         {:ok, point_system} <- Backend.MastersTour.TourStop.gm_point_system(ts),
         earnings <- Backend.MastersTour.get_gm_money_rankings(season, point_system) do
      {earnings, true}
    else
      _ -> {[], false}
    end
  end

  def tournament(conn, params = %{"tournament_id" => tournament_id}) do
    tournament = Battlefy.get_tournament(tournament_id)
    {earnings, show_earnings} = earnings(params, tournament_id)

    render(
      conn,
      "tournament.html",
      %{
        tournament: tournament,
        show_earnings: show_earnings,
        earnings: earnings,
        show_lineups: show_lineups(params),
        lineups: lineups(params),
        country_highlight: multi_select_to_array(params["country"]),
        page_title: tournament.name,
        stage_id: params["stage_id"],
        highlight: get_highlight(params)
      }
      |> add_matches_standings(params)
    )
  end

  def lineups(%{"show_lineups" => "yes", "tournament_id" => tournament_id}),
    do: Battlefy.lineups(tournament_id)

  def lineups(_), do: []

  defp add_matches_standings(existing, params = %{"stage_id" => stage_id}) do
    standings = Battlefy.get_stage_standings(stage_id)

    {matches, show_ongoing} =
      if is_ongoing(params) do
        {Battlefy.get_matches(stage_id), true}
      else
        {[], false}
      end

    existing |> Map.merge(%{standings: standings, matches: matches, show_ongoing: show_ongoing})
  end

  defp add_matches_standings(existing = %{tournament: tournament}, params) do
    standings = Battlefy.get_tournament_standings(tournament)

    {matches, show_ongoing} =
      if is_ongoing(params) do
        {Battlefy.get_tournament_matches(tournament), true}
      else
        {[], false}
      end

    existing |> Map.merge(%{standings: standings, matches: matches, show_ongoing: show_ongoing})
  end

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
  def tournament_player(conn, %{"team_name" => "&"}) do
    render(conn, BackendWeb.SharedView, "empty.html", %{})
  end

  def tournament_player(conn, %{
        "tournament_id" => tournament_id,
        "team_name" => team_name
      }) do
    deckcodes =
      Battlefy.get_deckstrings(%{tournament_id: tournament_id, battletag_full: team_name})

    tournament = Battlefy.get_tournament(tournament_id)

    {opponent_matches, player_matches} =
      Battlefy.get_future_and_player_matches(tournament_id, team_name)

    render(conn, "profile.html", %{
      tournament: tournament,
      opponent_matches: opponent_matches,
      player_matches: player_matches,
      page_title: team_name,
      deckcodes: deckcodes,
      team_name: team_name,
      conn: conn
    })
  end

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
      something ->
        text(
          conn,
          "Something went wrong, did you tamper with the link you naughty " <>
            Enum.random(["boy", "girl", "dog", "thing"])
        )
    end
  end

  def organization_tournaments(conn, %{
        "from" => from = %Date{},
        "to" => to = %Date{},
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
            |> Enum.filter(fn t -> t.game |> Tournament.Game.is_hearthstone() end)
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

  def organization_tournaments(conn, %{"from" => from = %Date{}, "to" => to = %Date{}}) do
    render(conn, "organization_tournaments.html", %{
      from: from,
      to: to,
      tournaments: [],
      org: nil,
      page_title: "3rd Party Tournaments"
    })
  end

  def organization_tournaments(conn, params = %{"from" => from, "to" => to}) do
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

  def user_tournaments(conn, params = %{"slug" => slug}) do
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

  def tournaments_stats(conn, params = %{"tournament_ids" => tournament_ids}) do
    direction = direction(params["direction"])
    selected_columns = multi_select_to_array(params["columns"])

    tournaments =
      tournament_ids
      |> list_or_comma_separated()
      |> Enum.map(&Battlefy.get_tournament/1)

    tournaments_stats =
      tournaments
      |> Enum.map(&Battlefy.create_tournament_stats/1)
      |> Enum.filter(fn tts -> Enum.count(tts) > 0 end)

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

  def tournaments_stats(conn, params = %{"tournaments" => tournaments}) do
    tournament_ids =
      tournaments
      |> String.split("\n")
      |> Enum.map(&Battlefy.tournament_link_to_id/1)

    new_params =
      params
      |> Map.delete("tournaments")
      |> Map.put("tournament_ids", tournament_ids |> Enum.join(","))

    new_url = Routes.battlefy_path(conn, :tournaments_stats, new_params)
    redirect(conn, to: new_url)
  end

  def tournaments_stats(conn, params) do
    render(conn, "tournaments_stats_input.html", %{
      conn: conn,
      edit: params["edit"],
      page_title: "Tournaments Stats"
    })
  end
end
