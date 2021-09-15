defmodule BackendWeb.MastersTourView do
  use BackendWeb, :view
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.MastersTour
  alias Backend.MastersTour.TourStop
  alias Backend.Blizzard
  alias Backend.PlayerInfo
  alias Backend.MastersTour.PlayerStats
  alias BackendWeb.MastersTour.MastersToursStats
  alias BackendWeb.ViewUtil

  @type qualifiers_dropdown_link :: %{display: Blizzard.tour_stop(), link: String.t()}
  @min_cups_options [1, 5, 10, 15, 20, 25, 30, 40, 50, 75, 100, 150, 200, 300]

  defp create_region_tag(%{region: nil}), do: ""

  defp create_region_tag(%{region: region}) do
    tag =
      case region do
        :US -> "is-info"
        :EU -> "is-primary"
        :CN -> "is-warning"
        _ -> "is-success"
      end

    region_name = Blizzard.get_region_name(region, :short)

    ~E"""
    <span class="tag <%= tag %> is-family-code"><%= region_name %></span>
    """
  end

  def create_country_tag(%{country: nil}), do: ""
  def create_country_tag(%{country: cc}), do: country_flag(cc)

  def create_name_cell(pr = %{name: name}, conn) do
    region = create_region_tag(pr)
    country = create_country_tag(pr)

    profile_link = Routes.player_path(conn, :player_profile, MastersTour.mt_profile_name(name))

    ~E"""
    <%= region %><%= country %><span> <a class="is-link" href="<%= profile_link %>"> <%= render_player_name(name) %> </a></span>
    """
  end

  def create_headers(tour_stops, show_current_score) do
    ~E"""
    <tr>
      <th>#</th>
      <th>Name</th>
      <%= for ts <- tour_stops do %>
        <th class="is-hidden-mobile"><%=ts%></th>
      <% end %>
      <%= if show_current_score do %>
        <th>Current Score</th>
      <% end %>
      <th>Total</th>
    </tr>
    """
  end

  def warning(warning) when is_binary(warning),
    do: ~E"""
    <span data-balloon-pos="up" aria-label="<%= warning %>" class="icon is-small">
      <i class="fas fa-exclamation"></i>
    </span>
    """

  def warning(_), do: ""

  def create_row_html(
        {pr = %{name: _name, total: total, per_ts: per_ts, region: _region, country: _country},
         place},
        tour_stops,
        show_current_score,
        conn
      ) do
    name_cell = create_name_cell(pr, conn)
    warning = warning(pr.warning)
    tour_stop_cells = tour_stops |> Enum.map(fn ts -> per_ts[ts] || 0 end)

    ~E"""
      <tr>
        <td> <%=place%> </td>
        <td> <%=name_cell%><%= warning %> </td>
        <%= for tsc <- tour_stop_cells do %>
          <td class="is-hidden-mobile"><%=tsc%></td>
        <% end %>
        <%= if show_current_score do %>
          <td><%= pr.current_score %></td>
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

  def get_sort_index(headers, sort_by, default \\ "Winrate %") do
    headers |> Enum.find_index(fn a -> a == sort_by end) ||
      headers |> Enum.find_index(fn a -> a == default end) ||
      0
  end

  def min_cups(total) when total < 5, do: 0

  def min_cups(total),
    do:
      [100, @min_cups_options |> Enum.find(fn a -> a > 4 + total * 0.20 end) || 100] |> Enum.min()

  @doc """
  When there is winrate invites and we don't want the default min cups to exceed that num
  """
  def max_for_mt(min_cups, period) when is_atom(period) do
    case TourStop.get(period, :min_qualifiers_for_winrate) do
      num when is_integer(num) -> Enum.min([min_cups, num])
      nil -> min_cups
    end
  end

  def max_for_mt(min_cups, _period), do: min_cups

  def filter_columns(column_map, columns_to_show) do
    columns_to_show
    |> Enum.map(fn c -> column_map[c] || "" end)
  end

  @spec create_tour_stop_cells(PlayerStats.t(), [Blizzard.tour_stop()], MapSet.t()) :: Map.t()
  def create_tour_stop_cells(player_stats, tour_stops, invited_set) do
    qualified_per_year =
      tour_stops
      |> Enum.flat_map(fn ts ->
        uniq_string = player_stats.battletag_full <> to_string(ts)

        if MapSet.member?(invited_set, uniq_string) && ts |> TourStop.get_year() do
          [ts |> TourStop.get_year()]
        else
          []
        end
      end)
      |> Enum.frequencies()
      |> Enum.map(fn {year, count} ->
        {"#{year} MTs qualified", count}
      end)
      |> Enum.into(%{})

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
    |> Map.merge(qualified_per_year)
  end

  def create_player_rows(
        player_stats,
        eligible_tour_stops,
        invited_set,
        conn,
        _period,
        show_flags
      ) do
    player_stats
    |> Enum.map(fn ps ->
      total = ps |> PlayerStats.with_result()

      ts_cells = create_tour_stop_cells(ps, eligible_tour_stops, invited_set)
      country = Backend.PlayerInfo.get_country(ps.battletag_full)
      flag_part = if show_flags && country, do: country_flag(country), else: ""

      player_cell = ~E"""
      <%= flag_part %>
      <a class="is-link" href="<%=Routes.player_path(conn, :player_profile, ps.battletag_full)%>">
        <%= ps.battletag_full |> InvitedPlayer.shorten_battletag() |> render_player_name() %>
      </a>
      """

      %{
        "Player" => player_cell,
        "_country" => country,
        "Cups" => total,
        "Top 8 %" => if(total > 0, do: (100 * ps.top8 / total) |> Float.round(2), else: 0),
        "Top 8" => ps.top8,
        "Top 16" => ps.top16,
        "Best" => ps |> PlayerStats.best(),
        "Worst" => ps |> PlayerStats.worst(),
        "Median" => ps |> PlayerStats.median(),
        "Only Losses" => ps.only_losses,
        "Only Losses %" => ps |> PlayerStats.only_losses_percent() |> Float.round(2),
        "Cups Won" => ps.num_won,
        "Num 2nd" => ps.positions |> Enum.filter(&(&1 == 2)) |> Enum.count(),
        "Num Matches" => ps |> PlayerStats.matches(),
        "Matches Won" => ps.wins,
        "Matches Lost" => ps.losses,
        "Packs Earned" => ps.positions |> Enum.map(&MastersTour.get_packs_earned/1) |> Enum.sum(),
        "Winrate %" => ps |> PlayerStats.matches_won_percent() |> Float.round(2),
        "Projected % (using 0.5)" =>
          ps |> PlayerStats.projected_matches_won_percent(20, 0.5) |> Float.round(2),
        "Projected % (using 0.6)" =>
          ps |> PlayerStats.projected_matches_won_percent(20, 0.6) |> Float.round(2),
        "Projected % (using 0.65)" =>
          ps |> PlayerStats.projected_matches_won_percent(20, 0.65) |> Float.round(2)
      }
      |> Map.merge(ts_cells)
    end)
  end

  # way too big of a performance hit
  def add_percentile_rows(rows, period) do
    get_val = & &1["Winrate %"]

    qualified =
      rows
      |> Enum.filter(fn m -> m[period] && m[period] != "" end)
      |> Enum.sort_by(get_val, :asc)

    qualified_num = qualified |> Enum.count()

    sorted =
      rows
      |> Enum.sort_by(get_val, :asc)

    rows
    |> Enum.map(fn m ->
      if qualified_num > 0 do
        Map.put(
          m,
          "Winrate percentile (qualified)",
          Util.get_percentile(m, qualified, get_val) |> Float.round(2)
        )
      else
        m
      end
      |> Map.put(
        "Winrate percentile",
        Util.get_percentile(m, sorted, get_val) |> Float.round(2)
      )
    end)
  end

  def process_sorting(sort_by_raw, direction_raw) do
    case {sort_by_raw, direction_raw} do
      {s, d} when is_atom(d and is_binary(s)) -> {s, d}
      {s, _} when is_binary(s) -> {s, :desc}
      _ -> {"Winrate %", :desc}
    end
  end

  def warning(min, 2020) when min < 15, do: warning_triangle()
  # def warning(min, _) when min < 5, do: warning_triangle()
  def warning(_, _), do: ""

  def render("qualifier_stats.html", %{
        period: period,
        total: total,
        stats: stats,
        sort_by: sort_by_raw,
        direction: direction_raw,
        min: min_raw,
        countries: countries,
        show_flags: show_flags,
        hide_qualified: hide_qualified,
        selected_columns: selected_columns,
        invited_players: invited_players,
        conn: conn
      }) do
    min_to_show = min_raw || min_cups(total) |> max_for_mt(period)

    update_link = fn new_params ->
      Routes.masters_tour_path(
        conn,
        :qualifier_stats,
        period,
        conn.query_params |> Map.merge(new_params)
      )
    end

    {sort_by, direction} = process_sorting(sort_by_raw, direction_raw)

    %{
      limit: limit,
      offset: offset,
      prev_button: prev_button,
      next_button: next_button,
      dropdown: limit_dropdown
    } =
      ViewUtil.handle_pagination(conn.query_params, update_link,
        default_limit: 200,
        limit_options: [50, 100, 150, 200, 250, 300, 350, 500, 750, 1000, 2000, 3000, 4000, 5000]
      )

    invited_set =
      invited_players
      |> Enum.filter(&(!(String.downcase(&1.reason) =~ "winrate")))
      |> MapSet.new(fn ip -> String.trim(ip.battletag_full) <> ip.tour_stop end)

    eligible_ts = eligible_tour_stops()

    sortable_headers =
      [
        "Player",
        "Cups",
        "Top 8 %",
        "Top 8",
        "Top 16",
        "Best",
        "Worst",
        "Median",
        "Only Losses",
        "Only Losses %",
        "Cups Won",
        "Num 2nd",
        "Num Matches",
        "Matches Won",
        "Matches Lost",
        "Packs Earned",
        # "Winrate percentile",
        # "Winrate percentile (qualified)",
        "2020 MTs qualified",
        "2021 MTs qualified"
      ] ++
        (eligible_ts |> Enum.map(&to_string/1)) ++
        [
          "Winrate %",
          "Projected % (using 0.5)",
          "Projected % (using 0.6)",
          "Projected % (using 0.65)"
        ]

    is_ts = is_atom(period) and period != :all

    ts =
      if is_ts do
        TourStop.get(period)
      else
        nil
      end

    columns_to_show =
      case {selected_columns, ts} do
        {columns, _} when is_list(columns) ->
          sortable_headers |> Enum.filter(fn c -> Enum.member?(columns, c) end)

        {_, %{id: id, min_qualifiers_for_winrate: min}} when is_integer(min) ->
          ["Player", "Cups", "Best", to_string(id), "Winrate %"]

        {_, %{id: id}} ->
          ["Player", "Cups", "Top 8", to_string(id), "Winrate %"]

        _ ->
          ["Player", "Cups", "Top 8", "Top 16", "Winrate %"]
      end

    headers =
      (["#"] ++ columns_to_show)
      |> Enum.map(fn h -> create_stats_header(h, sort_by, direction, conn, period) end)

    sort_key = sortable_headers |> Enum.find("Winrate %", fn h -> h == sort_by end)

    rows =
      stats
      |> Enum.filter(fn ps -> ps |> PlayerStats.with_result() >= min_to_show end)
      |> filter_countries(countries)
      |> filter_qualified(is_ts, hide_qualified, to_string(period), invited_set)
      |> create_player_rows(eligible_tour_stops(), invited_set, conn, period, show_flags == "yes")
      |> sort_for_qualifier_winrate(ts)
      |> Enum.sort_by(fn row -> row[sort_key] end, direction || :desc)
      |> Enum.with_index(1)
      |> Enum.drop(offset)
      |> Enum.take(limit)
      |> Enum.map(fn {row, pos} -> [pos | filter_columns(row, columns_to_show)] end)

    ts_list =
      ([:all] ++ eligible_years() ++ eligible_tour_stops())
      |> Enum.map(fn ts ->
        %{
          display: ts |> period_title(),
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
        warning = warning(min, period)

        display = ~E"""
        <span><%= warning %>Min <%= min %></span>
        """

        %{
          display: display,
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

    show_flags_list =
      ["Yes", "No"]
      |> Enum.map(fn o ->
        %{
          display: o,
          selected: show_flags == String.downcase(o),
          link:
            Routes.masters_tour_path(
              conn,
              :qualifier_stats,
              period,
              Map.put(conn.query_params, "show_flags", o |> String.downcase())
            )
        }
      end)

    flag_title = ~E"""
    <span class="icon">
      <i class="far fa-flag"></i>
    </span>
    """

    dropdowns =
      [
        limit_dropdown,
        {ts_list, period |> period_title},
        {min_list, "Min #{min_to_show} cups"},
        {show_flags_list, flag_title}
      ]
      |> add_qualified_filter(conn, is_ts, period, hide_qualified)

    columns_options =
      sortable_headers
      |> Enum.map(fn h ->
        %{
          selected: h in columns_to_show,
          display: h,
          name: h,
          value: h
        }
      end)

    render("qualifier_stats.html", %{
      title: "#{period |> period_title()} qualifier stats",
      subtitle: "Total cups: #{total}",
      headers: headers,
      rows: rows,
      columns_options: columns_options,
      selected_countries: countries,
      period: period,
      min: min_to_show,
      conn: conn,
      prev_button: prev_button,
      next_button: next_button,
      dropdowns: dropdowns
    })
  end

  def sort_for_qualifier_winrate(rows, %{min_qualifiers_for_winrate: min}) when is_integer(min) do
    rows
    |> Enum.sort_by(& &1["Cups"], :desc)
    |> Enum.sort_by(& &1["Best"], :asc)
    |> Enum.sort_by(& &1["Winrate %"], :desc)
  end

  def sort_for_qualifier_winrate(rows, _), do: rows

  def filter_qualified(rows, true, "yes", ts, invited_set) do
    rows
    |> Enum.filter(fn p ->
      !MapSet.member?(invited_set, p.battletag_full <> ts)
    end)
  end

  def filter_qualified(rows, _, _, _, _), do: rows

  def add_qualified_filter(dropdowns, _, false, _, _), do: dropdowns

  def add_qualified_filter(dropdowns, conn, _, ts, hide_qualified) do
    options =
      ["yes", "no"]
      |> Enum.map(fn v ->
        %{
          display: Recase.to_title(v),
          selected: v == hide_qualified,
          link:
            Routes.masters_tour_path(
              conn,
              :qualifier_stats,
              ts,
              Map.put(conn.query_params, "hide_qualified", v)
            )
        }
      end)

    dropdowns ++ [{options, "Hide Qualified"}]
  end

  def period_title(:all), do: "2020-2021"
  def period_title(period), do: period

  def filter_countries(target, []), do: target

  def filter_countries(r, countries),
    do:
      r
      |> Enum.filter(fn f ->
        PlayerInfo.get_country(f.battletag_full) in countries
      end)

  def filter_country(target, nil), do: target

  def filter_country(ep, country) do
    ep
    |> Enum.filter(fn %{country: c} -> country == c end)
  end

  def filter_region(earnings_players, nil), do: earnings_players

  def filter_region(earnings_players, region) do
    earnings_players
    |> Enum.filter(fn %{region: r} -> region == r end)
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

  def create_point_system_dropdown(conn) do
    options =
      [{"2020 Earnings", "mt_earnings_2020"}, {"2021 Points", "gm_points_2021"}]
      |> Enum.map(fn {name, val} ->
        %{
          display: name,
          selected: conn.query_params["points_system"] == val,
          link:
            Routes.masters_tour_path(
              conn,
              :earnings,
              Map.put(conn.query_params, "points_system", val)
            )
        }
      end)

    {options, "Points System"}
  end

  def create_country_dropdown(conn, country) do
    all_option = %{
      display: "All",
      selected: country == nil,
      link: Routes.masters_tour_path(conn, :earnings, Map.delete(conn.query_params, "country"))
    }

    options =
      PlayerInfo.get_eligible_countries()
      |> Enum.sort_by(&Util.get_country_name/1)
      |> Enum.map(fn cc ->
        country_name = cc |> Util.get_country_name()

        %{
          display: ~E"""
          <%= country_flag(cc) %> <span> <%= country_name %> </span>
          """,
          link:
            Routes.masters_tour_path(
              conn,
              :earnings,
              Map.put(conn.query_params, "country", cc)
            ),
          selected: cc == country
        }
      end)

    {[all_option | options], "Select Country"}
  end

  def create_season_dropdown(conn, {year, season}) do
    options =
      [{2020, 2}, {2021, 1}, {2021, 2}, {2022, 1}]
      |> Enum.map(fn {y, s} ->
        %{
          display: "#{y} Season #{s}",
          selected: y == year && s == season,
          link:
            Routes.masters_tour_path(
              conn,
              :earnings,
              Map.put(conn.query_params, "season", "#{y}_#{s}")
            )
        }
      end)

    {options, "Select Season"}
  end

  def create_current_score_dropdown(conn, show_current_score) do
    {[
       %{
         display: "Yes",
         selected: show_current_score,
         link:
           Routes.masters_tour_path(
             conn,
             :earnings,
             Map.put(conn.query_params, "show_current_score", "yes")
           )
       },
       %{
         display: "No",
         selected: !show_current_score,
         link:
           Routes.masters_tour_path(
             conn,
             :earnings,
             Map.put(conn.query_params, "show_current_score", "no")
           )
       }
     ], "Show Current Score"}
  end

  def get_player_score(name, standings) do
    standings
    |> Enum.find(fn %{team: %{name: full}} -> InvitedPlayer.shorten_battletag(full) == name end)
    |> case do
      %{wins: wins, losses: losses, disqualified: disqualified} ->
        class =
          cond do
            disqualified -> "has-text-danger"
            losses == 2 -> "has-text-warning"
            losses < 2 -> "has-text-success"
            true -> "has-text-danger"
          end

        ~E"""
        <div class="<%= class %>"> <%= wins %> - <%= losses %> </div>
        """

      _ ->
        ""
    end
  end

  def earnings_warning({2021, 2}, "justsaiyan"), do: "Retired from GM"
  def earnings_warning(_, _), do: nil

  def render("earnings.html", %{
        tour_stops: tour_stops_all,
        earnings: earnings,
        gm_season: gm_season = {year, season},
        show_gms: show_gms,
        conn: conn,
        country: country,
        show_current_score: show_current_score,
        standings: standings,
        region: region,
        gms: gms_list
      }) do
    tour_stops_started = tour_stops_all |> Enum.filter(&TourStop.started?/1)
    headers = create_headers(tour_stops_started, show_current_score)

    gms = MapSet.new(gms_list)

    rows =
      earnings
      |> Enum.filter(fn {name, _, _} -> show_gms == "yes" || !MapSet.member?(gms, name) end)
      |> Enum.map(fn {name, total, per_ts} ->
        current_score = get_player_score(name, standings)

        %{
          name: name,
          total: total,
          current_score: current_score,
          per_ts: per_ts,
          region: PlayerInfo.get_region(name),
          warning: earnings_warning(gm_season, name),
          country: PlayerInfo.get_country(name)
        }
      end)
      |> filter_region(region)
      |> filter_country(country)
      |> Enum.with_index(1)
      |> Enum.map(fn r -> create_row_html(r, tour_stops_started, show_current_score, conn) end)

    title = "GM Promotion for #{year} Season #{season}"

    dropdowns =
      [
        create_show_gms_dropdown(conn, show_gms),
        create_region_dropdown(conn, region),
        create_season_dropdown(conn, gm_season),
        create_point_system_dropdown(conn),
        create_country_dropdown(conn, country)
      ] ++
        if show_current_score_dropdown?(gm_season) do
          [create_current_score_dropdown(conn, show_current_score)]
        else
          []
        end

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

  def show_current_score_dropdown?(gm_season) do
    with current_ts when not is_nil(current_ts) <- MastersTour.TourStop.get_current(),
         {:ok, ts_season} <- Backend.Blizzard.get_promotion_season_for_gm(current_ts) do
      gm_season == ts_season
    else
      _ -> false
    end
  end

  @spec add_qualifier_winner(
          Backend.Battlefy.Communicator.qualifier(),
          [Qualifier.t()],
          Plug.Conn.t()
        ) :: Backend.Battlefy.Communicator.qualifier() | Map.t()
  def add_qualifier_winner(q = %{id: id}, qualifiers, conn) do
    winner =
      qualifiers
      |> Enum.find(&(&1.tournament_id == id))
      |> case do
        %{winner: winner, tournament_id: tournament_id} ->
          ~E"""
          <a href="<%= Routes.battlefy_path(conn, :tournament_player, tournament_id, winner)%>"><%= render_player_name(winner) %></a>
          """

        _ ->
          nil
      end

    q |> Map.put(:winner, winner)
  end

  def render(
        "qualifiers.html",
        params = %{fetched_qualifiers: qualifiers_raw, conn: conn, range: range, db: db}
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
        |> add_qualifier_winner(db, conn)
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
      TourStop.all()
      |> Enum.filter(fn %{qualifiers_period: {start, _}} ->
        :gt ==
          Date.utc_today()
          |> Date.add(14)
          |> Date.compare(start)
      end)
      |> Enum.reverse()
      |> Enum.map(fn ts ->
        %{
          display: ts.id,
          link: ts.qualifiers_period |> create_qualifiers_link(conn)
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

  def eligible_years(), do: [2020, 2021]

  def eligible_tour_stops() do
    Blizzard.tour_stops()
    |> Enum.reverse()
    |> Enum.take_while(fn ts -> ts != :Bucharest end)
  end

  def create_qualifiers_link(range = {%Date{} = _from, %Date{} = _to}, conn) do
    new_params = conn.query_params |> Util.update_from_to_params(range)

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
    tournament_link =
      case invited_player do
        %{tournament_slug: slug, tournament_id: id} when is_binary(slug) and is_binary(id) ->
          Routes.battlefy_path(conn, :tournament_player, id, battletag_full)

        _ ->
          nil
      end

    profile_link = Routes.player_path(conn, :player_profile, battletag_full)

    reason =
      case {invited_player.tournament_slug, reason_raw} do
        {slug, "qualifier"} when is_binary(slug) -> Recase.to_title(slug)
        _ -> reason_raw
      end

    battletag =
      if conn.query_params["show_full_bt"] in ["true", "yes"] do
        battletag_full
      else
        InvitedPlayer.shorten_battletag(battletag_full)
      end

    %{
      tournament_link: tournament_link,
      profile_link: profile_link,
      reason: reason,
      battletag: battletag,
      official: official,
      country: PlayerInfo.get_country(battletag_full),
      invited_at: invited_player.upstream_time
    }
  end

  def render("tour_stops.html", %{conn: conn, tournaments: tournaments}) do
    render("tour_stops.html", %{conn: conn, raw: tournaments, slug: "hsesports"})
  end

  def render(t = "masters_tours_stats.html", params), do: MastersToursStats.render(t, params)
end
