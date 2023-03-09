defmodule BackendWeb.LeaderboardView do
  use BackendWeb, :view
  import Backend.Blizzard
  alias Backend.PlayerInfo
  alias Backend.Blizzard
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.LobbyLegends.LobbyLegendsSeason
  alias Backend.Leaderboards
  alias Backend.Leaderboards.Snapshot
  alias Backend.Leaderboards.PlayerStats
  alias BackendWeb.ViewUtil
  require Backend.LobbyLegends

  @type selectable_season :: {String.t(), integer()}
  @min_finishes_options [1, 2, 3, 5, 7, 10, 15, 20]

  def history_graph([], _), do: ""

  def history_graph(player_history, attr) do
    data = Enum.map(player_history, &{&1.upstream_updated_at, player_history_data(&1, attr)})
    dataset = Contex.Dataset.new(data)
    y_scale = yscale(data)

    point_plot =
      Contex.PointPlot.new(dataset,
        custom_y_scale: y_scale,
        custom_y_formatter: &(&1 |> trunc() |> abs())
      )

    Contex.Plot.new(900, 200, point_plot)
    |> Contex.Plot.to_svg()
  end

  # Ensure th that the interval size is never below 1
  defp yscale(data) do
    {min, max} = data |> Enum.map(&elem(&1, 1)) |> Enum.filter(& &1) |> Enum.min_max()
    distance = abs(max - min)

    scale =
      Contex.ContinuousLinearScale.new()
      |> Contex.ContinuousLinearScale.domain(min, max)

    if distance < 10 do
      scale |> Contex.ContinuousLinearScale.interval_count(distance + 1)
    else
      scale
    end
  end

  defp player_history_data(ph, :rank), do: -1 * ph.rank
  defp player_history_data(ph, attr), do: Map.get(ph, attr)

  def history_dropdowns(%{conn: conn}, history \\ :player) do
    [
      create_region_dropdown(conn.params["region"], history_updater(conn, "region", history)),
      create_leaderboard_dropdown(
        conn.params["leaderboard_id"],
        history_updater(conn, "leaderboard_id", history)
      ),
      create_period_dropdown(
        conn.params["period"],
        conn.params["leaderboard_id"],
        history_updater(conn, "period", history)
      )
    ]
  end

  def create_period_dropdown(period, ldb, update_link) do
    seasons =
      create_selectable_seasons(Date.utc_today(), ldb)
      |> Enum.take(3)
      |> Enum.map(fn {name, val} ->
        {name, "season_#{val}"}
      end)

    options =
      ([
         {"Past 6 Hours", "past_hours_6"},
         {"Past Day", "past_days_1"},
         {"Past 3 Days", "past_days_3"},
         {"Past Week", "past_weeks_1"},
         {"Past 2 Weeks", "past_weeks_2"},
         {"Past Month", "past_months_1"}
       ] ++
         seasons)
      |> Enum.map(fn {name, val} ->
        %{
          display: name,
          selected: val == period,
          link: update_link.(val)
        }
      end)

    {options, dropdown_title(options, "Period")}
  end

  defp add_attr_dropdown(dropdowns, conn, current) do
    options =
      [:rank, :rating]
      |> Enum.map(fn attr ->
        %{
          display: attr |> to_string() |> Macro.camelize(),
          selected: attr == current,
          link: update_player_history_link(conn, "attr", attr)
        }
      end)

    [{options, dropdown_title(options, "Attribute")} | dropdowns]
  end

  defp add_ignore_dropdown(dropdowns, %{conn: conn, attr: :rank, ignore_rank: ignore}) do
    nil_option = %{
      display: "Ignore Nothing",
      selected: ignore == nil,
      link: update_player_history_link(conn, "ignore_rank_changes", "none")
    }

    num_options =
      Enum.map(1..3, fn num ->
        val = ignore_rank_changes_val(num)

        %{
          display: "Ignore <= #{num}",
          selected: ignore == num,
          link: update_player_history_link(conn, "ignore_rank_changes", val)
        }
      end)

    options = [nil_option | num_options]
    dropdowns ++ [{options, dropdown_title(options, "Ignore Rank Changes")}]
  end

  defp add_ignore_dropdown(dropdowns, _attrs), do: dropdowns

  defp ignore_rank_changes_val(val) when is_integer(val), do: "less_than_equal_#{val}"
  defp ignore_rank_changes_val(_), do: "none"

  defp history_updater(conn, key, history \\ :player)
  defp history_updater(conn, key, :player), do: &update_player_history_link(conn, key, &1)
  defp history_updater(conn, key, :rank), do: &update_rank_history_link(conn, key, &1)

  def update_rank_history_link(conn, key, val) do
    params =
      conn.params
      |> Map.put(key, val)

    %{
      "period" => s,
      "region" => r,
      "leaderboard_id" => l,
      "rank" => rank
    } = params

    Routes.leaderboard_path(conn, :rank_history, r, s, l, rank)
  end

  def update_player_history_link(conn, key, val) do
    attr = BackendWeb.LeaderboardController.history_attr(conn.params)

    ignore_rank_changes =
      BackendWeb.LeaderboardController.ignore_rank(conn.params) |> ignore_rank_changes_val()

    params =
      conn.params
      |> Map.put("attr", attr)
      |> Map.put("ignore_rank_changes", ignore_rank_changes)
      |> Map.put(key, val)

    %{
      "period" => s,
      "region" => r,
      "leaderboard_id" => l,
      "player" => p,
      "attr" => a,
      "ignore_rank_changes" => irc
    } = params

    Routes.leaderboard_path(conn, :player_history, r, s, l, p, attr: a, ignore_rank_changes: irc)
  end

  def history_dropdowns(false, _, _), do: []

  defp actual_end(assigns = %{deadline: deadline, other: other}) do
    season_display = Map.get(assigns, :season_display, "The season")

    ~H"""
      <span><%= season_display %> ends at <%= render_datetime(deadline) %> not <%= render_datetime(other) %></span>
    """
  end

  defp other_warning(%{leaderboard_id: "BG", season_id: s, region: "EU"})
       when s in [5, "5", "lobby_legends_2"] do
    now = NaiveDateTime.utc_now()
    %{ladder: %{eu: deadline}} = LobbyLegendsSeason.get("lobby_legends_2")

    if NaiveDateTime.compare(now, deadline) == :lt do
      hour_before = NaiveDateTime.add(deadline, -1 * 60 * 60)

      assigns = %{
        deadline: deadline,
        other: hour_before,
        season_display: "Lobby Legends 2 qualification"
      }

      actual_end(assigns)
    end
  end

  defp other_warning(_), do: nil

  defp filter_history_changes(player_history, %{attr: :rank, ignore_rank: ignore})
       when is_integer(ignore) do
    Enum.filter(player_history, fn ph ->
      abs(ph.rank - ph.prev_rank) > ignore
    end)
  end

  defp filter_history_changes(player_history, _), do: player_history

  defp update_ph_ratings(ph, ldb) do
    rating_display = rating_display_func(ldb)

    ph
    |> Enum.map(fn r ->
      r
      |> Map.put(:rating, rating_display.(r.rating))
      |> Map.put(:prev_rating, rating_display.(r.prev_rating))
    end)
  end

  def render(
        "rank_history.html",
        attrs = %{rank_history: history, rank: rank, conn: conn}
      ) do
    has_rating = history |> Enum.any?(& &1.rating)
    dropdowns = history_dropdowns(attrs, :rank)

    ldb = conn.params["leaderboard_id"]

    sorted_history =
      history
      |> filter_history_changes(attrs)
      |> update_ph_ratings(ldb)
      |> Enum.reverse()

    graph =
      if has_rating do
        history_graph(sorted_history, :rating)
      else
        nil
      end

    title = "Rank ##{rank} History"

    render("history.html", %{
      dropdowns: dropdowns,
      history: sorted_history,
      conn: conn,
      has_rating: has_rating,
      graph: graph,
      title: title
    })
  end

  def render(
        "player_history.html",
        attrs = %{
          player_history: player_history,
          attr: attr,
          player: player,
          conn: conn
        }
      ) do
    has_rating = player_history |> Enum.any?(& &1.rating)

    dropdowns =
      history_dropdowns(attrs)
      |> add_attr_dropdown(conn, attr)
      |> add_ignore_dropdown(attrs)

    ldb = conn.params["leaderboard_id"]

    sorted_history =
      player_history
      |> filter_history_changes(attrs)
      |> update_ph_ratings(ldb)
      |> Enum.reverse()

    graph = history_graph(sorted_history, attr)
    title = "#{player} #{attr |> to_string() |> Macro.camelize()} History"

    render("history.html", %{
      dropdowns: dropdowns,
      history: sorted_history,
      conn: conn,
      has_rating: has_rating,
      graph: graph,
      title: title
    })
  end

  def render("index.html", params = %{leaderboard: nil}) do
    render("empty.html", %{dropdowns: create_dropdowns(params)})
  end

  def render(
        "index.html",
        params = %{
          conn: conn,
          ladder_invite_num: ladder_invite_num,
          highlight: highlight,
          other_ladders: other_ladders,
          leaderboard: leaderboard,
          show_flags: show_flags,
          show_ratings: show_ratings
        }
      ) do
    invited =
      params
      |> process_invited()
      |> add_other_ladders(params)

    entries = process_entries(params, invited)

    update_link = fn new_params ->
      Routes.leaderboard_path(conn, :index, conn.query_params |> Map.merge(new_params))
    end

    %{
      prev_button: prev_button,
      next_button: next_button,
      dropdown: limit_dropdown
    } =
      ViewUtil.handle_pagination(conn.query_params, update_link,
        default_limit: 200,
        limit_options: [50, 100, 150, 200, 250, 300, 350, 500, 750, 1000, 2000, 3000, 4000, 5000]
      )

    render("leaderboard.html", %{
      entries: entries,
      crystal: get_crystal("STD"),
      show_mt_column: show_mt_column?(leaderboard),
      leaderboard_id: leaderboard.leaderboard_id,
      updated_at: leaderboard.upstream_updated_at,
      dropdowns: [limit_dropdown | create_dropdowns(params)],
      old: old?(leaderboard),
      season_id: leaderboard && leaderboard.season_id,
      show_ratings: show_ratings,
      conn: conn,
      prev_button: prev_button,
      next_button: next_button,
      other_warning: other_warning(leaderboard),
      ladder_invite_num: ladder_invite_num,
      official_link: Snapshot.official_link(leaderboard),
      show_flags: show_flags,
      highlighted: process_highlighted(highlight, entries)
    })
  end

  def render("stats.html", %{
        conn: conn,
        leaderboards: leaderboards,
        regions: regions,
        stats: stats,
        min: min_raw,
        countries: countries,
        show_flags: show_flags,
        sort_by: sort_by_raw,
        direction: direction_raw
      }) do
    min_to_show = min_raw || 5
    {sort_by, direction} = process_sorting(sort_by_raw, direction_raw)

    sortable_headers = [
      "Player",
      "Top 1",
      "Top 10",
      "Top 25",
      "Top 50",
      "Top 100",
      "Top 200",
      "Best",
      "Worst",
      "Average Finish",
      "Total Finishes"
    ]

    headers =
      (["#"] ++ sortable_headers)
      |> Enum.map(fn h -> create_stats_header(h, sort_by, direction, conn) end)

    sort_key = sortable_headers |> Enum.find("Total Finishes", fn h -> h == sort_by end)

    update_link = fn new_params ->
      Routes.leaderboard_path(conn, :player_stats, conn.query_params |> Map.merge(new_params))
    end

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

    rows =
      stats
      |> Enum.filter(fn ps -> ps.ranks |> Enum.count() >= min_to_show end)
      |> filter_countries(countries)
      |> create_player_rows(conn, show_flags == "yes")
      |> Enum.sort_by(fn row -> row["Average Finish"] end, :asc)
      |> Enum.sort_by(fn row -> row[sort_key] end, direction || :desc)
      |> Enum.drop(offset)
      |> Enum.take(limit)
      |> Enum.with_index(1 + offset)
      |> Enum.map(fn {row, pos} ->
        [pos | sortable_headers |> Enum.map(fn h -> row[h] || "" end)]
      end)

    region_options =
      Blizzard.qualifier_regions()
      |> Enum.map(fn r ->
        %{
          value: r,
          name: r |> Blizzard.get_region_name(:long),
          display: r |> Blizzard.get_region_name(:long),
          selected: regions == [] || regions |> Enum.member?(to_string(r))
        }
      end)

    min_list =
      @min_finishes_options
      |> Enum.map(fn min ->
        %{
          display: "Min #{min}",
          selected: min == min_to_show,
          link:
            Routes.leaderboard_path(
              conn,
              :player_stats,
              Map.put(conn.query_params, "min", min)
            )
        }
      end)

    leaderboards_options =
      Blizzard.leaderboards()
      |> Enum.map(fn l ->
        %{
          value: to_string(l),
          name: l |> Blizzard.get_leaderboard_name(:long),
          display: l |> Blizzard.get_leaderboard_name(:long),
          selected:
            (leaderboards == [] && "STD" == l) || leaderboards |> Enum.member?(to_string(l))
        }
      end)

    show_flags_list =
      ["Yes", "No"]
      |> Enum.map(fn o ->
        %{
          display: o,
          selected: show_flags == String.downcase(o),
          link:
            Routes.leaderboard_path(
              conn,
              :player_stats,
              Map.put(conn.query_params, "show_flags", o |> String.downcase())
            )
        }
      end)

    dropdowns = [
      limit_dropdown,
      {min_list, min_dropdown_title(min_to_show)},
      {show_flags_list, "Show Country Flags"}
    ]

    render("player_stats.html", %{
      headers: headers,
      rows: rows,
      conn: conn,
      min: min_to_show,
      region_options: region_options,
      dropdowns: dropdowns,
      selected_countries: countries,
      prev_button: prev_button,
      next_button: next_button,
      leaderboards_options: leaderboards_options
    })
  end

  def update_index_link(conn, param, value, to_delete \\ []) do
    new_params =
      conn.query_params
      |> Map.drop(to_delete)
      |> Map.put(param, value)

    Routes.leaderboard_path(conn, :index, new_params)
  end

  def create_dropdowns(params = %{leaderboard: nil}) do
    params
    |> Map.put(:leaderboard, %{leaderboard_id: nil, region: nil, season_id: nil})
    |> create_dropdowns()
  end

  def create_dropdowns(
        params = %{
          conn: conn,
          leaderboard: %{
            leaderboard_id: leaderboard_id,
            region: region,
            season_id: season_id
          },
          show_flags: show_flags,
          compare_to: compare_to
        }
      ) do
    [
      create_region_dropdown(conn, region),
      create_leaderboard_dropdown(conn, leaderboard_id),
      create_season_dropdown(conn, season_id, leaderboard_id),
      create_show_flags_dropdown(conn, show_flags),
      create_compare_to_dropdown(conn, compare_to)
    ]
    |> Enum.filter(& &1)
  end

  def new(text) do
    ~E"""
      <span>
        <p><%= text %><sup class="is-hidden-mobile is-size-7 has-text-danger"> New!</sup></p>
      </span>
    """
  end

  def create_region_dropdown(conn = %Plug.Conn{}, region) do
    create_region_dropdown(
      region,
      &update_index_link(conn, "region", &1, ["offset", "limit"])
    )
  end

  def create_region_dropdown(region, update_link) do
    options =
      Backend.Blizzard.qualifier_regions_with_name()
      |> Enum.map(fn {r, name} ->
        %{
          display: name,
          selected: to_string(r) == to_string(region),
          link: update_link.(r)
        }
      end)

    {options, dropdown_title(options, "Region")}
  end

  def create_leaderboard_dropdown(conn = %Plug.Conn{}, leaderboard_id) do
    create_leaderboard_dropdown(
      leaderboard_id,
      &update_index_link(conn, "leaderboardId", &1, ["offset", "limit", "seasonId"])
    )
  end

  def create_leaderboard_dropdown(leaderboard_id, update_link) do
    options =
      Backend.Blizzard.leaderboards_with_name()
      |> Enum.map(fn {id, name} ->
        %{
          display: name,
          selected: to_string(id) == to_string(leaderboard_id),
          link: update_link.(id)
        }
      end)

    {options, dropdown_title(options, "Leaderboard")}
  end

  def create_season_dropdown(conn, season, ldb) do
    options =
      create_selectable_seasons(Date.utc_today(), ldb)
      |> Enum.map(fn {name, s} ->
        %{
          display: name,
          selected: to_string(s) == to_string(season),
          link: update_index_link(conn, "seasonId", s, ["offset", "limit"])
        }
      end)

    {options, dropdown_title(options, "Season")}
  end

  def create_show_flags_dropdown(conn, show_flags) do
    options =
      [{"Show country flags", "yes"}, {"Hide country flags", "no"}]
      |> Enum.map(fn {title, mode} ->
        %{
          display: title,
          selected: mode == show_flags,
          link: update_index_link(conn, "show_flags", mode)
        }
      end)

    title = ~E"""
    <span class="icon">
      <i class="far fa-flag"></i>
    </span>
    """

    {options, title}
  end

  def create_compare_to_dropdown(conn, compare_to) do
    options =
      [
        {"10 minutes ago", "min_ago_10"},
        {"15 minutes ago", "min_ago_15"},
        {"20 minutes ago", "min_ago_20"},
        {"30 minutes ago", "min_ago_30"},
        {"1 hour ago", "min_ago_60"},
        {"6 hours ago", "min_ago_360"},
        {"1 day ago", "min_ago_1440"},
        {"1 week ago", "min_ago_10080"}
      ]
      |> Enum.map(fn {display, id} ->
        %{
          display: display,
          selected: id && id == compare_to,
          link: update_index_link(conn, "compare_to", id)
        }
      end)

    {[nil_option(conn, "compare_to", "None") | options], dropdown_title(options, "Compare to")}
  end

  def nil_option(conn, query_param, display \\ "Any") do
    %{
      link: Routes.leaderboard_path(conn, :index, Map.delete(conn.query_params, query_param)),
      selected: Map.get(conn.query_params, query_param) == nil,
      display: display
    }
  end

  def show_mt_column?(%{leaderboard_id: "BG", season_id: s})
      when Backend.LobbyLegends.is_lobby_legends(s) or
             Backend.LobbyLegends.is_lobby_legends_points(s) do
    "Lobby Legends"
  end

  def show_mt_column?(%{leaderboard_id: "STD", season_id: season_id}) do
    case elem(get_ladder_tour_stop(season_id), 0) do
      :ok -> "Masters Tour"
      _ -> nil
    end
  end

  def show_mt_column?(_), do: nil

  def old?(%{season_id: s, leaderboard_id: "BG"}) when Backend.LobbyLegends.is_lobby_legends(s),
    do: false

  def old?(%{upstream_updated_at: updated_at, season_id: 94, leaderboard_id: "STD", region: "US"}) do
    updated_at && DateTime.diff(DateTime.utc_now(), updated_at) &&
      DateTime.diff(DateTime.utc_now(), ~U[2021-09-01T07:00:00Z]) < 0
  end

  def old?(%{upstream_updated_at: updated_at, season_id: season_id, leaderboard_id: ldb}) do
    updated_at && DateTime.diff(DateTime.utc_now(), updated_at) > 3600 &&
      season_id >= get_season_id(Date.utc_today(), ldb)
  end

  def old?(_), do: false

  def add_other_ladders(invited, params = %{other_ladders: other}),
    do: add_other_ladders(invited, other, params)

  def add_other_ladders(invited, [current | rest], params) do
    params
    |> Map.put(:leaderboard, current)
    |> process_entries(invited)
    |> Enum.filter(fn e -> e.qualifying |> elem(0) end)
    |> Enum.with_index(1)
    |> Enum.map(fn {e, pos} -> {e.account_id, {:other_ladder, current.region, pos}} end)
    |> Map.new()
    |> add_other_ladders(rest, params)
  end

  def add_other_ladders(invited, _, _), do: invited

  def get_crystal(leaderboard_id) do
    case leaderboard_id do
      "STD" ->
        "https://d2q63o9r0h0ohi.cloudfront.net/images/leaderboards/crystal_standard-add3c953a625a04c8545699c65c338786606c56e770182c236c7ec5229bf5f1e78631e57bcdda6eee820f3a13e57e97fe22f0e39b5777c7e41b75ce28f3bd8c7.png"

      "BG" ->
        "https://d2q63o9r0h0ohi.cloudfront.net/images/leaderboards/crystal_battlegrounds-5cd82d919afcfc5de20e0857cfce3e19ba9bd47d8f02ab977d3fa3a17b9dc7c972a18e0f55eb970ff0639aa69045b3aacb3cc1125d17a9550bd5ed7167a51aea.png"

      "WLD" ->
        "https://d2q63o9r0h0ohi.cloudfront.net/images/leaderboards/crystal_wild-f9075a1fe0a5953b314fab5ca15f7cc83db86764786f590b8d64fb87603f797adbfd75ffd6160d89bf53ae08eb50d032a3d9d6885c0e03b0fcd6f22265aa6a0f.png"

      _ ->
        "https://d2q63o9r0h0ohi.cloudfront.net/images/leaderboards/crystal_standard-add3c953a625a04c8545699c65c338786606c56e770182c236c7ec5229bf5f1e78631e57bcdda6eee820f3a13e57e97fe22f0e39b5777c7e41b75ce28f3bd8c7.png"
    end
  end

  @doc """
    Creates the list of months that will be shown in the dropdown

    Unless it's the first or last of a month then it shows the current month, then the two previous
    If it's the first of a month it put's the previous month in first place
    If it's the last of the month it put's the next month in second place
    (see examples)
    ## Example
    iex> BackendWeb.LeaderboardView.create_selectable_seasons(~D[2020-01-01], "STD")
    [{:January, 75}, {:December, 74}, {:November, 73}, {:October, 72}, {:September, 71}, {:August, 70}]
    iex> BackendWeb.LeaderboardView.create_selectable_seasons(~D[2019-12-31], :WLD)
    [{:January, 75}, {:December, 74}, {:November, 73}, {:October, 72}, {:September, 71}, {:August, 70}]
    iex> BackendWeb.LeaderboardView.create_selectable_seasons(~D[2022-04-11], :MRC)
    [{:April, 6}, {:March, 5}, {:February, 4}, {:January, 3}, {:December, 2}, {:November, 1}]
  """
  @spec create_selectable_seasons(Calendar.date(), String.t() | atom()) :: [selectable_season]
  def create_selectable_seasons(_today, ldb) when ldb in [:BG, "BG"] do
    Blizzard.get_current_ladder_season(:BG)..0
    |> Enum.take(7)
    |> Enum.map(fn s ->
      name = Blizzard.get_season_name(s, :BG)
      {name, s}
    end)
  end

  def create_selectable_seasons(today, ldb) do
    tomorrow = Date.add(today, 1)
    tomorrow_id = get_season_id(tomorrow, ldb)
    # if it's the first day of jan or last day of dec we want to show [dec, jan, nov]
    [0, -1, -2, -3, -4, -5]
    |> Enum.map(fn month_diff ->
      month_num = Util.normalize_month(month_diff + tomorrow.month)
      {Util.get_month_name(month_num), tomorrow_id + month_diff}
    end)
  end

  def process_invited(%{leaderboard: nil, invited: invited_raw}),
    do: process_invited(invited_raw, NaiveDateTime.utc_now())

  def process_invited(%{leaderboard: %{upstream_updated_at: updated_at}, invited: invited_raw}),
    do: process_invited(invited_raw, updated_at)

  def process_invited(invited_raw, updated_at) do
    not_invited_afterwards = fn ip ->
      true

      ip.upstream_time
      |> NaiveDateTime.compare(updated_at)
      |> Kernel.==(:lt)
    end

    case updated_at do
      nil -> invited_raw
      _ -> Enum.filter(invited_raw, not_invited_afterwards)
    end
    |> InvitedPlayer.prioritize(&InvitedPlayer.shorten_battletag/1)
    |> Map.new(fn ip ->
      {InvitedPlayer.shorten_battletag(ip.battletag_full), InvitedPlayer.source(ip)}
    end)
  end

  def process_highlighted(highlighted_raw, entry) do
    is_highlighted = fn %{account_id: account_id} ->
      MapSet.member?(highlighted_raw, to_string(account_id))
    end

    if highlighted_raw && Enum.any?(entry, is_highlighted) do
      Enum.filter(entry, is_highlighted)
    else
      nil
    end
  end

  def warning(%{season_id: 83, region: "US", leaderboard_id: "STD"}, "Jay"),
    do: "I've been told this isn't the same Jay that Finished on APAC so I'm not counting them"

  def warning(%{season_id: 91, region: "AP", leaderboard_id: "STD"}, "Jay"),
    do:
      "This probably isn't the same Jay that Finished on Americas so I'm not counting them as invited"

  def warning(%{season_id: 95, region: "AP", leaderboard_id: "STD"}, "Jay"),
    do:
      "This probably isn't the same Jay that Finished on Americas so I'm not counting them as invited"

  def warning(%{season_id: 94, region: "EU", leaderboard_id: "STD"}, "XiaoT"),
    do: "Has previously gotten a second invite from a ladder finish, so I'm not counting them"

  def warning(_, _), do: nil

  # todo move somewhere else
  # Jay#12424 is banned indefinitely, can appeal after Jan 3rd 2023.
  def banned(%{season_id: season, region: "US", leaderboard_id: "STD"}, "Jay") when season >= 99,
    do: "Jay#12424 is banned from competitive HS"

  def banned(%{season_id: season, region: "US", leaderboard_id: "STD"}, "notjayhuang")
      when season >= 99,
      do:
        "This is a Jay#12424 alt and theyare banned from competitive HS. Come on Jay, if you have any hope of redemption in the future stop with this. It'll also make it easier on me :)"

  # EpicMingo#1244 is banned until Apr 3, 2022
  def banned(%{season_id: season, region: "US", leaderboard_id: "STD"}, "EpicMingo")
      when season in 99..102,
      do: "EpicMingo#1244 is banned from competitive HS until 2022-04-03"

  def banned(snapshot, name) when name in ["ADVO", "SilverName"] do
    banned_deadline(name, snapshot, ~D[2022-03-30], ~D[2022-10-01])
  end

  def banned(snapshot, name) when name in ["Mirko", "iziboulbi", "Enki"] do
    banned_deadline(name, snapshot, ~D[2022-01-05], ~D[2023-03-01])
  end

  def banned(snapshot, name) when name in ["Jekyll"] do
    banned_deadline(name, snapshot, ~D[2022-01-18], ~D[2023-01-18])
  end

  def banned(snapshot, name) when name in ["MrF2P"] do
    banned_deadline(name, snapshot, ~D[2021-07-15], ~D[2022-07-15])
  end

  def banned(snapshot, name) when name in ["Matador"] do
    banned_deadline(name, snapshot, ~D[2021-08-12], ~D[2022-08-12])
  end

  def banned(snapshot, name) when name in ["Moritz20099", "Orange"],
    do: banned_deadline(name, snapshot, ~D[2022-05-13], ~D[2023-06-01])

  def banned(_snapshot, name) when name in ["Zalae", "Purple"] do
    "#{name} is banned from hsesports"
  end

  def banned(_, _),
    do: nil

  defp banned_deadline(name, %{upstream_updated_at: updated_at}, start_date, end_date) do
    with {:ok, time} <- Time.new(12, 0, 0),
         {:ok, deadline} <- NaiveDateTime.new(end_date, time),
         {:ok, start} <- NaiveDateTime.new(start_date, time),
         :gt <- NaiveDateTime.compare(updated_at, start),
         :lt <- NaiveDateTime.compare(updated_at, deadline) do
      "#{name} is banned until #{end_date}"
    else
      _ -> nil
    end
  end

  # this rule has been changed
  # defp wrong_region(%{leaderboard_id: "BG", season_id: s, region: region}, account) when Backend.LobbyLegends.is_lobby_legends(s) do
  #   case Backend.PlayerInfo.get_country(account) do
  #     nil -> false
  #     cc -> region != Backend.PlayerInfo.country_to_region() |> to_string()
  #   end
  # end
  @confirmed_std_chinese [
    # https://www.d0nkey.top/leaderboard?region=EU&seasonId=99
    "XiaoT",
    # https://www.d0nkey.top/leaderboard?region=EU&seasonId=99
    "Jiuqianyu",
    # https://www.d0nkey.top/leaderboard?region=EU&seasonId=99
    "WEYuansu",
    # https://www.d0nkey.top/leaderboard?region=EU&seasonId=99
    "Wolfrider"
  ]
  defp wrong_region(%{leaderboard_id: "STD", season_id: s}, account, "previously_skipped")
       when s > 98 and account in @confirmed_std_chinese do
    true
  end

  defp wrong_region(%{leaderboard_id: "BG", season_id: s}, account, "all") when s > 4 do
    is_chinese?(account)
  end

  defp wrong_region(%{leaderboard_id: "STD", season_id: s}, account, "all") when s > 98 do
    is_chinese?(account) || account in @confirmed_std_chinese
  end

  defp wrong_region(_, _, _), do: false

  def is_chinese?(account) do
    case Backend.PlayerInfo.get_country(account) do
      nil -> false
      cc -> :CN == Backend.PlayerInfo.country_to_region(cc)
    end
  end

  def process_entries(%{leaderboard: nil}, _), do: []

  def process_entries(
        %{
          leaderboard:
            snapshot = %{
              entries: entries,
              upstream_updated_at: upstream_updated_at,
              leaderboard_id: ldb
            },
          comparison: comparison,
          ladder_invite_num: num_invited,
          ladder_points: ladder_points,
          skip_cn: skip_cn
        },
        invited
      ) do
    rating_display = rating_display_func(ldb)

    Enum.map_reduce(entries, 1, fn le = %{account_id: account_id}, acc ->
      warning = warning(snapshot, account_id)
      qualified = !warning && Map.get(invited, account_id)
      banned = banned(snapshot, account_id)
      wrong_region = wrong_region(snapshot, account_id, skip_cn)

      ineligible = Blizzard.ineligible?(account_id, upstream_updated_at)
      skip_for_invite = qualified || ineligible || banned || wrong_region

      qualifying =
        with [_ | _] <- ladder_points,
             {_, points} <-
               Enum.find(ladder_points, fn {{min, max}, _} -> le.rank >= min && le.rank <= max end) do
          {:points, points}
        else
          _ ->
            {!skip_for_invite && acc <= num_invited, acc}
        end

      {prev_rank, prev_rating} = prev(comparison, account_id)

      history_attr = if le.rating, do: "rating", else: "rank"

      player_history_link =
        BackendWeb.PlayerView.history_link(
          BackendWeb.Endpoint,
          snapshot,
          account_id,
          history_attr,
          "past_weeks_1"
        )

      rank_history_link =
        %{
          link:
            Routes.leaderboard_path(
              BackendWeb.Endpoint,
              :rank_history,
              snapshot.region,
              "past_weeks_1",
              snapshot.leaderboard_id,
              le.rank
            )
        }
        |> BackendWeb.PlayerView.history_link()

      {
        le
        |> Map.update(:rating, le.rating, rating_display)
        |> Map.put_new(:qualified, qualified)
        |> Map.put_new(:qualifying, qualifying)
        |> Map.put_new(:ineligible, ineligible)
        |> Map.put_new(:prev_rank, prev_rank)
        |> Map.put_new(:warning, warning)
        |> Map.put_new(:wrong_region, wrong_region)
        |> Map.put_new(:banned, banned)
        |> Map.put_new(:player_history_link, player_history_link)
        |> Map.put_new(:rank_history_link, rank_history_link)
        |> Map.put_new(:prev_rating, rating_display.(prev_rating)),
        if skip_for_invite do
          acc
        else
          acc + 1
        end
      }
    end)
    |> elem(0)
  end

  defp prev(nil, _), do: {nil, nil}

  defp prev(comparison, account_id) do
    comparison.entries
    |> Enum.filter(fn e -> e.account_id == account_id end)
    |> Enum.sort_by(fn e -> e.rank end, :asc)
    |> case do
      [e | _] -> {e.rank, e.rating}
      _ -> {nil, nil}
    end
  end

  def process_sorting(sort_by_raw, direction_raw) do
    case {sort_by_raw, direction_raw} do
      {s, d} when is_atom(d and is_binary(s)) -> {s, d}
      {s, _} when is_binary(s) -> {s, :desc}
      _ -> {"Total Finishes", :desc}
    end
  end

  def min_dropdown_title(1), do: "Min 1 Finish"
  def min_dropdown_title(min), do: "Min #{min} Finishes"

  def opposite(:desc), do: :asc
  def opposite(_), do: :desc
  def symbol(:asc), do: "↓"
  def symbol(_), do: "↑"
  def create_stats_header("#", _, _, _), do: "#"

  def create_stats_header(header, sort_by, direction, conn) when header == sort_by do
    click_params = %{"sort_by" => header, "direction" => opposite(direction)}

    url =
      Routes.leaderboard_path(
        conn,
        :player_stats,
        Map.merge(conn.query_params, click_params)
      )

    cell = "#{header}#{symbol(direction)}"

    ~E"""
      <a class="is-text" href="<%= url %>"><%= cell %></a>
    """
  end

  def create_stats_header(header, _, _, conn) do
    click_params = %{"sort_by" => header, "direction" => :desc}

    url =
      Routes.leaderboard_path(
        conn,
        :player_stats,
        Map.merge(conn.query_params, click_params)
      )

    ~E"""
      <a class="is-text" href="<%= url %>"><%= header %></a>
    """
  end

  def filter_countries(target, []), do: target

  def filter_countries(r, countries),
    do: r |> Enum.filter(fn p -> (p.account_id |> PlayerInfo.get_country()) in countries end)

  def create_player_rows(player_stats, conn, show_flags) do
    player_stats
    |> Enum.map(fn ps ->
      total = ps.ranks |> Enum.count()
      avg = ((ps.ranks |> Enum.sum()) / total) |> Float.round(2)

      country = Backend.PlayerInfo.get_country(ps.account_id)
      flag_part = if show_flags && country, do: country_flag(country, %{}), else: ""

      %{
        "Player" => ~E"""
          <%= flag_part %> <a href="<%= Routes.player_path(conn, :player_profile, ps.account_id)%>"><%= ps.account_id %></a>
        """,
        "_country" => country,
        "Top 1" => ps |> PlayerStats.num_top(1),
        "Top 10" => ps |> PlayerStats.num_top(10),
        "Top 25" => ps |> PlayerStats.num_top(25),
        "Top 50" => ps |> PlayerStats.num_top(50),
        "Top 100" => ps |> PlayerStats.num_top(100),
        "Top 200" => ps |> PlayerStats.num_top(200),
        "Best" => ps.ranks |> Enum.min(),
        "Worst" => ps.ranks |> Enum.max(),
        "Average Finish" => avg,
        "Total Finishes" => total
      }
    end)
  end

  def rating_display_func(ldb) do
    fn rating ->
      Leaderboards.rating_display(rating, ldb)
    end
  end
end
