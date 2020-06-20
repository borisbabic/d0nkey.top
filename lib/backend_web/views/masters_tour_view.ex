defmodule BackendWeb.MastersTourView do
  use BackendWeb, :view
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.MastersTour
  alias Backend.Blizzard
  alias Backend.PlayerInfo
  @type qualifiers_dropdown_link :: %{display: Blizzard.tour_stop(), link: String.t()}
  @min_cups_options [0, 5, 10, 15, 20, 25, 30, 40, 50, 75, 100]

  def create_name_cell(name, nil) do
    name
  end

  def create_name_cell(name, region) do
    tag =
      case region do
        :US -> "is-info"
        :EU -> "is-primary"
        :CN -> "is-warning"
        _ -> "is-success"
      end

    region_name = Blizzard.get_region_name(region, :short)

    ~E"""
    <span class="tag <%= tag %> is-family-code"><%= region_name %></span> <%= name %>
    """
  end

  def create_headers(tour_stops) do
    ~E"""
    <tr>
      <th>#</th>
      <th>Name</th>
      <%= for ts <- tour_stops do %>
        <th class="is-hidden-mobile"><%=ts%></th>
      <% end %>
      <th>Total</th>
    </tr>
    """
  end

  def create_row_html({{name, total, per_ts, region}, place}, tour_stops) do
    name_cell = create_name_cell(name, region)
    tour_stop_cells = tour_stops |> Enum.map(fn ts -> per_ts[ts] || 0 end)

    ~E"""
      <tr>
        <td> <%=place%> </td>
        <td> <%=name_cell%> </td>
        <%= for tsc <- tour_stop_cells do %>
          <td class="is-hidden-mobile"><%=tsc%></td>
        <% end %>
        <td><%=total%></td>
      </tr>
    """
  end

  def opposite(:desc), do: :asc
  def opposite(_), do: :desc
  def symbol(:asc), do: "↓"
  def symbol(_), do: "↑"
  def create_stats_header("#", _, _, _, _), do: "#"

  def create_stats_header(header, sort_by, direction, conn, period) when header == sort_by do
    click_params = %{"sort_by" => header, "direction" => opposite(direction)}

    url =
      Routes.masters_tour_path(
        conn,
        :qualifier_stats,
        period,
        Map.merge(conn.query_params, click_params)
      )

    cell = "#{header}#{symbol(direction)}"

    ~E"""
      <a class="is-text" href="<%= url %>"><%= cell %></a>
    """
  end

  def create_stats_header(header, _, _, conn, period) do
    click_params = %{"sort_by" => header, "direction" => :desc}

    url =
      Routes.masters_tour_path(
        conn,
        :qualifier_stats,
        period,
        Map.merge(conn.query_params, click_params)
      )

    ~E"""
      <a class="is-text" href="<%= url %>"><%= header %></a>
    """
  end

  def get_sort_index(headers, sort_by, default \\ "%") do
    headers |> Enum.find_index(fn a -> a == sort_by end) ||
      headers |> Enum.find_index(fn a -> a == default end) ||
      0
  end

  def min_cups(total) when total < 5, do: 0
  def min_cups(total), do: @min_cups_options |> Enum.find(fn a -> a > 4 + total * 0.20 end) || 100

  def filter_columns(column_map, columns_to_show) do
    columns_to_show
    |> Enum.map(fn c -> column_map[c] || "" end)
  end

  def percent(_, 0), do: 0

  def percent(num, total) do
    (100 * num / total) |> Float.round(2)
  end

  @spec create_tour_stop_cells(PlayerStats.t(), [Blizzard.tour_stop()], MapSet.t()) :: Map.t()
  def create_tour_stop_cells(player_stats, tour_stops, invited_set) do
    tour_stops
    |> Enum.map(fn tour_stop ->
      cell =
        if MapSet.member?(invited_set, player_stats.battletag_full <> to_string(tour_stop)) do
          ~E" <span class=\"tag is-success\">✓</span>"
        else
          ""
        end

      {to_string(tour_stop), cell}
    end)
    |> Map.new()
  end

  def create_player_rows(player_stats, eligible_tour_stops, invited_set) do
    player_stats
    |> Enum.map(fn ps ->
      total = Enum.count(ps.positions) - ps.no_results

      ts_cells = create_tour_stop_cells(ps, eligible_tour_stops, invited_set)

      %{
        "Player" => InvitedPlayer.shorten_battletag(ps.battletag_full),
        "Cups" => total,
        "Top 8" => ps.top8,
        "Top 16" => ps.top16,
        "Best" => ps.positions |> Enum.min(),
        "Worst" => ps.positions |> Enum.max(),
        "Median" => ps.positions |> Enum.sort() |> Enum.at(Enum.count(ps.positions) |> div(2)),
        "No Wins" => ps.no_wins,
        "No Wins %" => percent(ps.no_wins, total),
        "Cups Won" => ps.num_won,
        "Num Matches" => ps.wins + ps.losses,
        "Matches Won" => ps.wins,
        "Matches Lost" => ps.losses,
        "Packs Earned" => ps.positions |> Enum.map(&MastersTour.get_packs_earned/1) |> Enum.sum(),
        "%" => percent(ps.wins, ps.wins + ps.losses)
      }
      |> Map.merge(ts_cells)
    end)
  end

  def process_sorting(sort_by_raw, direction_raw) do
    case {sort_by_raw, direction_raw} do
      {s, d} when is_atom(d and is_binary(s)) -> {s, d}
      {s, _} when is_binary(s) -> {s, :desc}
      _ -> {"%", :desc}
    end
  end

  def render("qualifier_stats.html", %{
        period: period,
        total: total,
        stats: stats,
        sort_by: sort_by_raw,
        direction: direction_raw,
        min: min_raw,
        selected_columns: selected_columns,
        invited_players: invited_players,
        conn: conn
      }) do
    min_to_show = min_raw || min_cups(total)

    {sort_by, direction} = process_sorting(sort_by_raw, direction_raw)

    invited_set =
      invited_players
      |> MapSet.new(fn ip -> String.trim(ip.battletag_full) <> ip.tour_stop end)

    eligible_ts = eligible_tour_stops()

    sortable_headers =
      [
        "Player",
        "Cups",
        "Top 8",
        "Top 16",
        "Best",
        "Worst",
        "Median",
        "No Wins",
        "No Wins %",
        "Cups Won",
        "Num Matches",
        "Matches Won",
        "Matches Lost",
        "Packs Earned"
      ] ++
        (eligible_ts |> Enum.map(&to_string/1)) ++
        ["%"]

    columns_to_show =
      case {selected_columns, period} do
        {columns, _} when is_list(columns) ->
          sortable_headers |> Enum.filter(fn c -> Enum.member?(columns, c) end)

        {_, ts} when is_atom(period) ->
          ["Player", "Cups", "Top 8", to_string(ts), "%"]

        _ ->
          ["Player", "Cups", "Top 8", "Top 16", "%"]
      end

    headers =
      (["#"] ++ columns_to_show)
      |> Enum.map(fn h -> create_stats_header(h, sort_by, direction, conn, period) end)

    sort_key = sortable_headers |> Enum.find("%", fn h -> h == sort_by end)

    rows =
      stats
      |> Enum.filter(fn ps -> (Enum.count(ps.positions) - ps.no_results) >= min_to_show end)
      |> create_player_rows(eligible_tour_stops, invited_set)
      |> Enum.sort_by(fn row -> row[sort_key] end, direction || :desc)
      |> Enum.with_index(1)
      |> Enum.map(fn {row, pos} -> [pos | filter_columns(row, columns_to_show)] end)

    ts_list =
      (eligible_years() ++ eligible_tour_stops())
      |> Enum.map(fn ts ->
        %{
          display: ts,
          selected: to_string(ts) == to_string(period),
          link:
            Routes.masters_tour_path(
              conn,
              :qualifier_stats,
              ts,
              Map.delete(conn.query_params, "min")
            )
        }
      end)

    min_list =
      @min_cups_options
      |> Enum.map(fn min ->
        %{
          display: "Min #{min}",
          selected: min == min_to_show,
          link:
            Routes.masters_tour_path(
              conn,
              :qualifier_stats,
              period,
              Map.put(conn.query_params, "min", min)
            )
        }
      end)

    dropdowns = [
      {ts_list, period},
      {min_list, "Min #{min_to_show} cups"}
    ]

    columns_options =
      sortable_headers |> Enum.map(fn h -> {h, Enum.member?(columns_to_show, h)} end)

    render("qualifier_stats.html", %{
      title: "#{period} qualifier stats",
      subtitle: "Total cups: #{total}",
      headers: headers,
      rows: rows,
      columns: columns_options,
      period: period,
      min: min_to_show,
      conn: conn,
      dropdowns: dropdowns
    })
  end

  def filter_region(earnings_players, nil), do: earnings_players

  def filter_region(earnings_players, region) do
    earnings_players
    |> Enum.filter(fn {_, _, _, r, _} -> region == r end)
  end

  def create_show_gms_dropdown(conn, show_gms) do
    title = "Show gms"

    options =
      ["yes", "no"]
      |> Enum.map(fn v ->
        %{
          display: Recase.to_title(v),
          selected: v == show_gms,
          link:
            Routes.masters_tour_path(conn, :earnings, Map.put(conn.query_params, "show_gms", v))
        }
      end)

    {options, title}
  end

  def create_region_dropdown(conn, region) do
    title =
      case region do
        nil -> "Region"
        r -> Blizzard.get_region_name(r, :long)
      end

    all_option = %{
      display: "All",
      selected: region == nil,
      link: Routes.masters_tour_path(conn, :earnings, Map.delete(conn.query_params, "region"))
    }

    region_options =
      Blizzard.regions()
      |> Enum.map(fn r ->
        %{
          display: Blizzard.get_region_name(r, :long),
          selected: region == r,
          link: Routes.masters_tour_path(conn, :earnings, Map.put(conn.query_params, "region", r))
        }
      end)

    {[all_option | region_options], title}
  end

  def get_player_score(name, standings) do
    standings
    |> Enum.find(fn %{team: %{name: full}} -> InvitedPlayer.shorten_battletag(full) == name end)
    |> case do
      %{wins: wins, losses: losses} -> "#{wins} - #{losses}"
      _ -> "N/A"
    end
  end

  def render("earnings.html", %{
        tour_stops: tour_stops,
        earnings: earnings,
        gm_season: {year, season},
        show_gms: show_gms,
        conn: conn,
        region: region,
        gms: gms_list
      }) do
    headers = create_headers(tour_stops)

    gms = MapSet.new(gms_list)

    rows =
      earnings
      |> Enum.filter(fn {name, _, _} -> show_gms == "yes" || !MapSet.member?(gms, name) end)
      |> Enum.map(fn {name, total, per_ts} ->
        {name, total, per_ts, PlayerInfo.get_region(name)}
      end)
      |> filter_region(region)
      |> Enum.with_index(1)
      |> Enum.map(fn r -> create_row_html(r, tour_stops) end)

    title = "Earnings for #{year} Season #{season}"

    dropdowns = [
      create_show_gms_dropdown(conn, show_gms),
      create_region_dropdown(conn, region)
    ]

    render("earnings.html", %{
      title: title,
      year: year,
      season: season,
      dropdowns: dropdowns,
      headers: headers,
      show_gms: show_gms,
      conn: conn,
      rows: rows
    })
  end

  def render(
        "qualifiers.html",
        params = %{fetched_qualifiers: qualifiers_raw, conn: conn, range: range}
      ) do
    region = params[:region]
    {before_range, after_range} = Util.get_surrounding_ranges(range)
    before_link = create_qualifiers_link(before_range, conn)
    after_link = create_qualifiers_link(after_range, conn)

    signed_up_ids =
      case params[:user_tournaments] do
        nil -> []
        uts -> uts |> Enum.map(fn ut -> ut.id end)
      end
      |> MapSet.new()

    qualifiers =
      qualifiers_raw
      |> Enum.filter(fn q ->
        region == nil || region == q.region
      end)
      |> Enum.map(fn q ->
        q
        |> Map.put_new(:link, MastersTour.create_qualifier_link(q))
        |> Map.put_new(:standings_link, Routes.battlefy_path(conn, :tournament, q.id))
        |> Map.put_new(:signed_up, MapSet.member?(signed_up_ids, q.id))
      end)

    region_links =
      Backend.Battlefy.regions()
      |> Enum.map(fn r ->
        %{
          display: r,
          link:
            Routes.masters_tour_path(conn, :qualifiers, Map.put(conn.query_params, "region", r))
        }
      end)
      |> Enum.concat([
        %{
          display: "All",
          link:
            Routes.masters_tour_path(
              conn,
              :qualifiers,
              Map.drop(conn.query_params, ["region", :region])
            )
        }
      ])

    render("qualifiers.html", %{
      qualifiers: qualifiers,
      before_link: before_link,
      after_link: after_link,
      show_signed_up: MapSet.size(signed_up_ids) > 0,
      dropdown_links: create_dropdown_qualifier_links(conn),
      region_links: region_links,
      conn: conn,
      region: region
    })
  end

  def render("invited_players.html", %{invited: invited, tour_stop: selected_ts, conn: conn}) do
    latest = Enum.find_value(invited, fn ip -> ip.upstream_time end)

    invited_players =
      invited
      |> InvitedPlayer.prioritize()
      |> Enum.map(fn ip -> process_invited_player(ip, conn) end)
      |> Enum.sort_by(fn ip -> ip.invited_at |> NaiveDateTime.to_iso8601() end, :desc)

    tour_stop_list =
      Backend.Blizzard.tour_stops()
      |> Enum.map(fn ts ->
        %{
          ts: ts,
          selected: to_string(ts) == to_string(selected_ts),
          link: Routes.masters_tour_path(conn, :invited_players, ts)
        }
      end)

    render("invited_players.html", %{
      invited_players: invited_players,
      ts_list: tour_stop_list,
      selected_ts: selected_ts,
      latest: latest
    })
  end

  @spec create_dropdown_qualifier_links(any) :: [qualifiers_dropdown_link]
  def create_dropdown_qualifier_links(conn) do
    tour_stop_ranges =
      eligible_tour_stops()
      |> Enum.map(fn ts ->
        %{
          display: ts,
          link: ts |> MastersTour.guess_qualifier_range() |> create_qualifiers_link(conn)
        }
      end)

    date_ranges =
      [{:week, "Week"}, {:month, "Month"}]
      |> Enum.map(fn {range, display} ->
        %{
          display: display,
          link: MastersTour.get_masters_date_range(range) |> create_qualifiers_link(conn)
        }
      end)

    date_ranges ++ tour_stop_ranges
  end

  def eligible_years(), do: [2020]

  def eligible_tour_stops() do
    Blizzard.tour_stops()
    |> Enum.reverse()
    |> Enum.take_while(fn ts -> ts != :Bucharest end)
  end

  def create_qualifiers_link({%Date{} = from, %Date{} = to}, conn) do
    # Routes.masters_tour_path(conn, :qualifiers, %{"from" => from, "to" => to})
    # Routes.masters_tour_path(conn, :qualifiers, %{from: from, to: to})
    new_params =
      Map.merge(conn.query_params, %{"from" => Date.to_iso8601(from), "to" => Date.to_iso8601(to)})

    Routes.masters_tour_path(conn, :qualifiers, new_params)
  end

  @spec process_invited_player(
          %{
            battletag_full: Blizzard.battletag(),
            reason: String.t() | nil,
            tournament_slug: String.t() | nil,
            tournament_id: String.t() | nil,
            upstream_time: Calendar.datetime()
          },
          Plug.Conn
        ) :: %{
          battletag: String.t(),
          invited_at: String.t(),
          link: nil | String.t(),
          profile_link: nil | String.t(),
          reason: String.t() | nil
        }
  def process_invited_player(
        invited_player = %{battletag_full: battletag_full, reason: reason_raw, official: official},
        conn
      ) do
    {link, profile_link} =
      case invited_player do
        %{tournament_slug: slug, tournament_id: id} when is_binary(slug) and is_binary(id) ->
          {
            MastersTour.create_qualifier_link(slug, id),
            Routes.battlefy_path(conn, :tournament_player, id, battletag_full)
          }

        _ ->
          {nil, nil}
      end

    reason =
      case {invited_player.tournament_slug, reason_raw} do
        {slug, "qualifier"} when is_binary(slug) -> Recase.to_title(slug)
        _ -> reason_raw
      end

    battletag = InvitedPlayer.shorten_battletag(battletag_full)

    %{
      link: link,
      profile_link: profile_link,
      reason: reason,
      battletag: battletag,
      official: official,
      invited_at: invited_player.upstream_time
    }
  end
end
