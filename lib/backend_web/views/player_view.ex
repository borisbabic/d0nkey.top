defmodule BackendWeb.PlayerView do
  use BackendWeb, :view

  alias Backend.Blizzard
  alias Backend.MastersTour
  alias Backend.MastersTour.PlayerStats

  def render("player_profile.html", %{
        battletag_full: battletag_full,
        qualifier_stats: qs,
        player_info: pi,
        tournaments: t,
        conn: conn,
        mt_earnings: mt_earnings
      }) do
    stats_rows =
      case qs do
        nil ->
          []

        ps ->
          [
            {"2020 MTQ played", ps |> PlayerStats.with_result()},
            {"2020 MTQ winrate", ps |> PlayerStats.matches_won_percent() |> Float.round(2)}
          ]
      end

    player_rows =
      case {pi.country, pi.region} do
        {nil, nil} -> []
        {country, nil} -> [{"Country", pi.country}]
        {nil, region} -> [{"Region", pi.region |> Blizzard.get_region_name(:long)}]
        {country, region} -> [{"Country", pi.country}, {"Region", pi.region}]
      end

    earnings_rows = [{"2020 MT earnings", mt_earnings}]

    rows =
      (player_rows ++ stats_rows ++ earnings_rows)
      |> Enum.map(fn {title, val} -> "#{title}: #{val}" end)

    table_headers =
      [
        "Tournament",
        "Finish",
        "Wins",
        "Losses"
      ]
      |> Enum.map(fn h -> ~E"<th><%= h %></th>" end)

    table_rows =
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
              ~E"""
              <tr>
                <td><a class="is-link" href="<%=tournament_link%>"><%=tournament_title%></a></td>
                <td><a class="is-link" href="<%=player_link%>"><%=ps.position%></a></td>
                <td><%=ps.wins%></td>
                <td><%=ps.losses%></td>
              </tr>
              """
            ]
        end
      end)

    render("player_profile.html", %{
      title: battletag_full,
      rows: rows,
      table_headers: table_headers,
      table_rows: table_rows
    })
  end
end
