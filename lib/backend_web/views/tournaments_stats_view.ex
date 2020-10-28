defmodule BackendWeb.TournamentStatsView do
  use BackendWeb, :view
  alias Backend.Battlef
  alias Backend.TournamentStats.TournamentTeamStats
  alias Backend.TournamentStats.TeamStats
  import BackendWeb.SortHelper
  @type header :: %{name: String.t(), sortable: boolean}

  def link_creator(conn) do
    fn params ->
      Routes.battlefy_path(conn, :tournaments_stats, conn.query_params |> Map.merge(params))
    end
  end

  def render("tournaments_stats.html", params = %{tournaments_stats: _}) do
    render("tournaments_stats_table.html", params)
  end

  def render(
        "tournaments_stats_table.html",
        p = %{
          conn: conn,
          tournaments_stats: tournaments_stats,
          selected_columns: selected_columns_raw,
          sort_by: sort_by,
          direction: direction
        }
      ) do
    create_link = p[:create_link] || link_creator(conn)
    additional_columns = p[:additional_columns] || []

    all_columns =
      additional_columns ++
        [
          "Player",
          "Num Played",
          "Num Won",
          "Best",
          "Worst",
          "Median",
          "Matches Won",
          "Matches Lost",
          "Winrate %"
        ]

    selected_columns =
      if selected_columns_raw && selected_columns_raw != [] do
        all_columns |> Enum.filter(fn c -> c in selected_columns_raw end)
      else
        ["Player", "Matches Won", "Matches Lost", "Winrate %"]
      end

    additional_context = p[:additional_context] || (&Util.id/1)

    sort_index =
      selected_columns
      |> Enum.with_index()
      |> Enum.find_value(Enum.count(selected_columns) - 1, fn {c, pos} -> c == sort_by && pos end)

    rows =
      tournaments_stats
      |> Backend.TournamentStats.create_team_stats_collection()
      |> Enum.map(fn {name, tts} ->
        total = tts |> Enum.count()

        stats =
          tts |> Enum.map(&TournamentTeamStats.total_stats/1) |> TeamStats.calculate_team_stats()

        context =
          %{
            total: total,
            tts: tts,
            stats: stats,
            stats_type: :actual,
            conn: conn,
            name: name
          }
          |> additional_context.()

        selected_columns
        |> Enum.reverse()
        |> Enum.reduce({context, []}, &add_cell/2)
        |> elem(1)
      end)
      |> Enum.sort_by(fn r -> r |> Enum.at(sort_index) end, direction || :desc)
      |> Enum.with_index(1)
      |> Enum.map(fn {row, pos} -> [pos | row] end)

    headers_raw = selected_columns |> Enum.map(fn h -> %{name: h, sortable: true} end)

    headers =
      [%{name: "#", sortable: false} | headers_raw]
      |> Enum.map(fn h -> create_header(h, create_link, sort_by, direction) end)

    columns =
      all_columns
      |> Enum.map(fn c -> %{column: c, selected: c in selected_columns} end)

    render("tournaments_stats_table.html", %{
      headers: headers,
      rows: rows,
      conn: conn,
      columns: columns,
      curr_url: create_link.(%{}),
      dropdown_row: p[:dropdown_row]
    })
  end

  defp create_header(%{name: name, sortable: false}, _, _, _), do: name

  defp create_header(%{name: name, sortable: true}, create_link, sort_by, direction) do
    {new_direction, cell} =
      if sort_by == name do
        {opposite(direction), "#{name}#{symbol(direction)}"}
      else
        {:desc, name}
      end

    click_params = %{"sort_by" => name, "direction" => new_direction}
    url = create_link.(click_params)

    ~E"""
      <a class="is-text" href="<%= url %>"><%= cell %></a>
    """
  end

  defp add_cell("Player", {c = %{conn: conn, name: player_name}, row}) do
    player_cell = ~E"""

    <a class="is-link" href="<%=Routes.player_path(conn, :player_profile, player_name)%>">
    <%= player_name %>
    </a>
    """

    {c, [player_cell | row]}
  end

  defp add_cell("Num Played", {c = %{total: total}, row}), do: {c, [total | row]}

  defp add_cell("Num Won", {c = %{stats: stats}, row}),
    do: {c, [stats |> TeamStats.num_won() | row]}

  defp add_cell("Median", {c = %{stats: stats}, row}),
    do: {c, [stats |> TeamStats.median() | row]}

  defp add_cell("Worst", {c = %{stats: stats}, row}), do: {c, [stats |> TeamStats.worst() | row]}
  defp add_cell("Best", {c = %{stats: stats}, row}), do: {c, [stats |> TeamStats.best() | row]}

  defp add_cell("Num Matches", {c = %{stats: stats, stats_type: st}, row}),
    do: {c, [TeamStats.matches(stats, st) | row]}

  defp add_cell("Matches Won", {c = %{stats: stats, stats_type: st}, row}),
    do: {c, [stats |> TeamStats.wins(st) | row]}

  defp add_cell("Matches Lost", {c = %{stats: stats, stats_type: st}, row}),
    do: {c, [stats |> TeamStats.losses(st) | row]}

  defp add_cell("Winrate %", {c = %{stats: stats}, row}),
    do: {c, [stats |> TeamStats.matches_won_percent() |> Float.round(2) | row]}
end
