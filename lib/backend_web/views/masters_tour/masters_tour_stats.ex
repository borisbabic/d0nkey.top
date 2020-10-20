defmodule BackendWeb.MastersTour.MastersToursStats do
  @moduledoc false
  use BackendWeb, :view
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.TournamentStats.TournamentTeamStats
  alias Backend.TournamentStats.TeamStats
  alias Backend.MastersTour

  defp opposite(:desc), do: :asc
  defp opposite(_), do: :desc
  defp symbol(:asc), do: "↓"
  defp symbol(_), do: "↑"
  defp create_stats_header("#", _, _, _, _), do: "#"

  defp create_stats_header(header, sort_by, direction, conn) when header == sort_by do
    click_params = %{"sort_by" => header, "direction" => opposite(direction)}

    url =
      Routes.masters_tour_path(
        conn,
        :masters_tours_stats,
        Map.merge(conn.query_params, click_params)
      )

    cell = "#{header}#{symbol(direction)}"

    ~E"""
      <a class="is-text" href="<%= url %>"><%= cell %></a>
    """
  end

  defp create_stats_header(header, _, _, conn) do
    click_params = %{"sort_by" => header, "direction" => :desc}

    url =
      Routes.masters_tour_path(
        conn,
        :masters_tours_stats,
        Map.merge(conn.query_params, click_params)
      )

    ~E"""
      <a class="is-text" href="<%= url %>"><%= header %></a>
    """
  end

  defp get_sort_index(headers, sort_by, default \\ "Winrate %") do
    headers |> Enum.find_index(fn a -> a == sort_by end) ||
      headers |> Enum.find_index(fn a -> a == default end) ||
      0
  end

  defp filter_columns(column_map, columns_to_show) do
    columns_to_show
    |> Enum.map(fn c -> column_map[c] || "" end)
  end

  defp tournament_score_cell(score, name, tournament_id, conn) do
    link = Routes.battlefy_path(conn, :tournament_player, tournament_id, name)

    ~E"""
    <a class="is-link" href="<%= link %>"><%= score %></a>
    """
  end

  defp create_player_rows(player_stats, conn) do
    player_stats
    |> Enum.map(fn {player_name, tts} ->
      total = tts |> Enum.count()

      player_cell = ~E"""
      <a class="is-link" href="<%=Routes.player_path(conn, :player_profile, player_name)%>">
        <%= player_name %>
      </a>
      """

      {stats_list = [first | rest], ts_rows} =
        tts
        |> Enum.map_reduce(%{}, fn ts, acc ->
          swiss = ts |> TournamentTeamStats.filter_stages(:swiss)
          stats = ts |> TournamentTeamStats.total_stats()

          {stats,
           Map.put_new(
             acc,
             ts.tournament_name |> masters_tour_column_name(),
             "#{swiss.wins} - #{swiss.losses}"
             |> tournament_score_cell(ts.team_name, ts.tournament_id, conn)
           )}
        end)

      stats = stats_list |> TeamStats.calculate_team_stats()

      %{
        "Player" => player_cell,
        "Tour Stops" => total,
        "Top 8" => stats.positions |> Enum.filter(fn p -> p < 9 end) |> Enum.count(),
        "Best" => stats |> TeamStats.best(),
        "Worst" => stats |> TeamStats.worst(),
        "Median" => stats |> TeamStats.median(),
        "Tour Stops Won" => stats.positions |> Enum.filter(fn p -> p == 1 end) |> Enum.count(),
        "Num Matches" => stats.wins + stats.losses,
        "Matches Won" => stats.wins,
        "Matches Lost" => stats.losses,
        "Winrate %" => stats |> TeamStats.matches_won_percent() |> Float.round(2)
      }
      |> Map.merge(ts_rows)
    end)
  end

  defp process_sorting(sort_by_raw, direction_raw) do
    case {sort_by_raw, direction_raw} do
      {s, d} when is_atom(d and is_binary(s)) -> {s, d}
      {s, _} when is_binary(s) -> {s, :desc}
      _ -> {"Winrate %", :desc}
    end
  end

  defp masters_tour_column_name(name), do: masters_tour_name_fixer(name) <> " swiss"

  def masters_tour_name_fixer(name),
    do: ~r/^Master(s)? Tour( Online: )?/ |> Regex.replace(to_string(name), "")

  def render("masters_tours_stats.html", %{
        conn: conn,
        sort_by: sort_by_raw,
        direction: direction_raw,
        selected_columns: selected_columns,
        tour_stops: tour_stops,
        tournament_team_stats: tts
      }) do
    {sort_by, direction} = process_sorting(sort_by_raw, direction_raw)

    columns =
      [
        "Player"
      ] ++
        (tour_stops |> Enum.map(&masters_tour_column_name/1)) ++
        [
          "Tour Stops",
          "Won",
          "Top 8",
          "Best",
          "Worst",
          "Median",
          "Num Matches",
          "Matches Won",
          "Matches Lost",
          "Winrate %"
        ]

    columns_to_show =
      if is_list(selected_columns) do
        columns |> Enum.filter(fn c -> Enum.member?(selected_columns, c) end)
      else
        ["Player", "Top 8", "Matches Won", "Matches Lost", "Winrate %"]
      end

    sort_key = columns |> Enum.find("Matches Won", fn h -> h == sort_by end)

    rows =
      tts
      |> Backend.TournamentStats.create_team_stats_collection(fn n ->
        n
        |> InvitedPlayer.shorten_battletag()
        |> MastersTour.fix_name()
      end)
      |> create_player_rows(conn)
      |> Enum.sort_by(fn row -> row[sort_key] end, direction || :desc)
      |> Enum.with_index(1)
      |> Enum.map(fn {row, pos} -> [pos | filter_columns(row, columns_to_show)] end)

    columns_options = columns |> Enum.map(fn h -> {h, Enum.member?(columns_to_show, h)} end)

    headers =
      (["#"] ++ columns_to_show)
      |> Enum.map(fn h -> create_stats_header(h, sort_by, direction, conn) end)

    render("masters_tours_stats.html", %{
      title: "Masters Tours Swiss Stats",
      headers: headers,
      rows: rows,
      columns: columns_options,
      conn: conn,
      dropdowns: []
    })
  end
end
