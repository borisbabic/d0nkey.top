defmodule BackendWeb.MastersTourView do
  use BackendWeb, :view
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.MastersTour
  alias Backend.Blizzard
  @type qualifiers_dropdown_link :: %{display: Blizzard.tour_stop(), link: String.t()}

  def create_name_cell(name) do
    create_name_cell(name, Backend.PlayerInfo.get_region(name))
  end

  def create_name_cell(name, nil) do
    name
  end

  def create_name_cell(name, region) do
    tag =
      case region do
        "AM" -> "is-info"
        "EU" -> "is-primary"
        "CN" -> "is-warning"
        _ -> "is-success"
      end

    ~E"""
    <span class="tag <%= tag %> is-family-code"><%= region %></span> <%= name %>
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

  def create_row_html({{name, total, per_ts}, place}, tour_stops) do
    name_cell = create_name_cell(name)
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

  def render("qualifier_stats.html", %{
        tour_stop: tour_stop,
        stats: nil
      }) do
    ~E"""
    No stats for <%= tour_stop %>. Only tour stops with 100% single elim tourneys are supported. If this is one of
    them them contact me somewhere
    """
  end

  def opposite(:desc), do: :asc
  def opposite(_), do: :desc
  def symbol(:asc), do: "↓"
  def symbol(_), do: "↑"
  def create_stats_header("#", _, _, _, _), do: "#"

  def create_stats_header(header, sort_by, direction, conn, period) when header == sort_by do
    IO.inspect(direction)
    IO.inspect(opposite(direction))
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

  def render("qualifier_stats.html", %{
        period: period,
        total: total,
        stats: stats,
        sort_by: sort_by_raw,
        direction: direction_raw,
        conn: conn
      }) do
    min_to_show = (5 + total * 0.20) |> ceil()

    {sort_by, direction} =
      case {sort_by_raw, direction_raw} do
        {s, d} when is_atom(d and is_binary(s)) -> {s, d}
        {s, _} when is_binary(s) -> {s, :desc}
        _ -> {"%", :desc}
      end

    sortable_headers = ["Player", "Cups", "Top 8", "Top16", "%"]

    headers =
      (["#"] ++ sortable_headers)
      |> Enum.map(fn h -> create_stats_header(h, sort_by, direction, conn, period) end)

    sort_index = get_sort_index(sortable_headers, sort_by)

    rows =
      stats
      |> Enum.filter(fn ps -> Enum.count(ps.positions) >= min_to_show end)
      |> Enum.map(fn ps ->
        [
          InvitedPlayer.shorten_battletag(ps.battletag_full),
          Enum.count(ps.positions),
          ps.top8,
          ps.top16,
          (100 * ps.wins / (ps.wins + ps.losses)) |> Float.round(2)
        ]
      end)
      |> Enum.sort_by(fn row -> Enum.at(row, sort_index) end, direction || :desc)
      |> Enum.with_index(1)
      |> Enum.map(fn {row, pos} -> [pos | row] end)

    ts_list =
      (eligible_years() ++ eligible_tour_stops())
      |> Enum.map(fn ts ->
        %{
          ts: ts,
          selected: to_string(ts) == to_string(period),
          link: Routes.masters_tour_path(conn, :qualifier_stats, ts)
        }
      end)

    render("qualifier_stats.html", %{
      title: "#{period} qualifier stats",
      headers: headers,
      rows: rows,
      ts_list: ts_list,
      selected_ts: period,
      min: min_to_show
    })
  end

  def render("earnings.html", %{
        tour_stops: tour_stops,
        earnings: earnings,
        gm_season: {year, season},
        show_gms: show_gms,
        conn: conn,
        gms: gms_list
      }) do
    headers = create_headers(tour_stops)

    gms = MapSet.new(gms_list)

    rows =
      earnings
      |> Enum.filter(fn {name, _, _} -> show_gms == "yes" || !MapSet.member?(gms, name) end)
      |> Enum.with_index(1)
      |> Enum.map(fn row_data -> create_row_html(row_data, tour_stops) end)

    title = "Earnings for #{year} Season #{season}"

    render("earnings.html", %{
      title: title,
      year: year,
      season: season,
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
