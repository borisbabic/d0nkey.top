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

  defp earnings(params, tournament_id) do
    with true <- show_earnings?(params),
         %{id: tour_stop} <-
           Backend.MastersTour.TourStop.all()
           |> Enum.find(fn ts -> ts.battlefy_id == tournament_id end),
         {:ok, season} <- Backend.Blizzard.get_promotion_season_for_gm(tour_stop),
         earnings <- Backend.MastersTour.get_gm_money_rankings(season) do
      {earnings, true}
    else
      _ -> {[], false}
    end
  end

  def tournament(conn, params = %{"tournament_id" => tournament_id, "stage_id" => stage_id}) do
    tournament = Battlefy.get_tournament(tournament_id)
    standings = Battlefy.get_stage_standings(stage_id)

    {matches, show_ongoing} =
      if is_ongoing(params) do
        {Battlefy.get_matches(stage_id), true}
      else
        {[], false}
      end

    {earnings, show_earnings} = earnings(params, tournament_id)

    render(conn, "tournament.html", %{
      standings: standings,
      tournament: tournament,
      matches: matches,
      show_ongoing: show_ongoing,
      show_earnings: show_earnings,
      earnings: earnings,
      country_highlight: multi_select_to_array(params["country"]),
      highlight: get_highlight(params),
      stage_id: stage_id
    })
  end

  def tournament(conn, params = %{"tournament_id" => tournament_id}) do
    tournament = Battlefy.get_tournament(tournament_id)
    standings = Battlefy.get_tournament_standings(tournament)

    {matches, show_ongoing} =
      if is_ongoing(params) do
        {Battlefy.get_tournament_matches(tournament), true}
      else
        {[], false}
      end

    {earnings, show_earnings} = earnings(params, tournament_id)

    render(conn, "tournament.html", %{
      standings: standings,
      tournament: tournament,
      matches: matches,
      show_ongoing: show_ongoing,
      show_earnings: show_earnings,
      earnings: earnings,
      country_highlight: multi_select_to_array(params["country"]),
      highlight: get_highlight(params)
    })
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

  def tournament_player(conn, %{
        "tournament_id" => tournament_id,
        "team_name" => team_name
      }) do
    tournament = Battlefy.get_tournament(tournament_id)

    {opponent_matches, player_matches} =
      Battlefy.get_future_and_player_matches(tournament_id, team_name)

    render(conn, "profile.html", %{
      tournament: tournament,
      opponent_matches: opponent_matches,
      player_matches: player_matches,
      team_name: team_name,
      conn: conn
    })
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

    render(conn, "organization_tournaments.html", %{
      from: from,
      to: to,
      org: org,
      tournaments: tournaments
    })
  end

  def organization_tournaments(conn, %{"from" => from = %Date{}, "to" => to = %Date{}}) do
    render(conn, "organization_tournaments.html", %{from: from, to: to, tournaments: [], org: nil})
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

    render(conn, "tournaments_stats.html", %{
      tournaments: tournaments,
      tournaments_stats: tournaments_stats,
      direction: direction,
      selected_columns: selected_columns,
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
    render(conn, "tournaments_stats_input.html", %{conn: conn, edit: params["edit"]})
  end
end
