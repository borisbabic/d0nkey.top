defmodule BackendWeb.LeaderboardView do
  use BackendWeb, :view
  import Backend.Blizzard
  alias Backend.PlayerInfo
  alias Backend.Blizzard
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.Leaderboards.PlayerStats
  alias BackendWeb.ViewUtil

  @type selectable_season :: {String.t(), integer()}
  @min_finishes_options [1, 2, 3, 5, 7, 10, 15, 20]

  def render("player_history.html", %{player_history: player_history, attr: attr, player: player, conn: conn}) do
    has_rating = player_history |> Enum.any?(& &1.rating)
    dropdowns = player_history_dropdowns(has_rating, conn, attr)
    sorted_history = Enum.sort_by(player_history, & &1.upstream_updated_at, :desc)
    render("player_history.html", %{dropdowns: dropdowns, player: player, player_history: sorted_history, conn: conn, has_rating: has_rating})
  end

  def player_history_dropdowns(true, conn, current) do
    options =
      [:rank, :rating]
      |> Enum.map(fn attr ->
        %{
          display: attr |> to_string() |> Macro.camelize(),
          selected: attr == current,
          link: update_player_history_link(conn, attr)
        }

      end)
    [{options, dropdown_title(options, "Attribute")}]
  end
  def update_player_history_link(conn, attr) do
    %{"season_id" => s, "region" => r, "leaderboard_id" => l, "player" => p} = conn.path_params
    Routes.leaderboard_path(conn, :player_history, r, s, l, p, attr: attr)
  end
  def player_history_dropdowns(false, _, _), do: []

  def render("index.html", params = %{leaderboard: nil}) do
    render("empty.html", %{dropdowns: create_dropdowns(params)})
  end

  def render(
        "index.html",
        params = %{
          conn: conn,
          invited: invited_raw,
          ladder_invite_num: ladder_invite_num,
          highlight: highlight,
          other_ladders: other_ladders,
          leaderboard: leaderboard,
          show_flags: show_flags,
          comparison: comparison
        }
      ) do
    invited =
      leaderboard
      |> process_invited(invited_raw)
      |> add_other_ladders(other_ladders, ladder_invite_num)

    entries =
      leaderboard |> process_entries(invited, comparison, show_flags == "yes", ladder_invite_num)

    show_ratings = Enum.any?(entries, & &1.rating)

    render("leaderboard.html", %{
      entries: entries,
      crystal: get_crystal("STD"),
      show_mt_column: show_mt_column?(leaderboard),
      leaderboard_id: leaderboard.leaderboard_id,
      updated_at: leaderboard.upstream_updated_at,
      dropdowns: create_dropdowns(params),
      old: old?(leaderboard),
      season_id: leaderboard && leaderboard.season_id,
      show_ratings: show_ratings,
      conn: conn,
      ladder_invite_num: ladder_invite_num,
      highlighted: process_highlighted(highlight, entries)
    })
  end

  def create_dropdowns(params = %{leaderboard: nil}) do
    params
    |> Map.put(:leaderboard, %{leaderboard_id: nil, region: nil, season_id: nil})
    |> create_dropdowns()
  end

  def create_dropdowns(%{
        conn: conn,
        leaderboard: %{
          leaderboard_id: leaderboard_id,
          region: region,
          season_id: season_id
        },
        show_flags: show_flags,
        ladder_mode: ladder_mode,
        compare_to: compare_to
      }) do
    [
      create_region_dropdown(conn, region),
      create_leaderboard_dropdown(conn, leaderboard_id),
      create_season_dropdown(conn, season_id, leaderboard_id),
      create_ladder_mode_dropdown(conn, ladder_mode),
      create_show_flags_dropdown(conn, show_flags),
      create_compare_to_dropdown(conn, compare_to)
    ]
  end

  def create_region_dropdown(conn, region) do
    options =
      Backend.Blizzard.qualifier_regions_with_name()
      |> Enum.map(fn {r, name} ->
        %{
          display: name,
          selected: to_string(r) == to_string(region),
          link: Routes.leaderboard_path(conn, :index, Map.put(conn.query_params, "region", r))
        }
      end)

    {options, dropdown_title(options, "Region")}
  end

  def create_leaderboard_dropdown(conn, leaderboard_id) do
    options =
      Backend.Blizzard.leaderboards_with_name()
      |> Enum.map(fn {id, name} ->
        %{
          display: name,
          selected: to_string(id) == to_string(leaderboard_id),
          link:
            Routes.leaderboard_path(conn, :index, Map.put(conn.query_params, "leaderboardId", id))
        }
      end)

    {options, dropdown_title(options, "Leaderboard")}
  end

  def create_season_dropdown(conn, season, "BG") do
    options =
      Blizzard.get_current_ladder_season(:BG)..0
      |> Enum.map(fn s ->
        %{
          display: Blizzard.get_season_name(s, :BG),
          selected: to_string(s) == to_string(season),
          link: Routes.leaderboard_path(conn, :index, Map.put(conn.query_params, "seasonId", s))
        }
      end)

    {options, dropdown_title(options, "Season")}
  end

  def create_season_dropdown(conn, season, ldb) do
    options =
      create_selectable_seasons(Date.utc_today(), ldb)
      |> Enum.map(fn {name, s} ->
        %{
          display: name,
          selected: to_string(s) == to_string(season),
          link: Routes.leaderboard_path(conn, :index, Map.put(conn.query_params, "seasonId", s))
        }
      end)

    {options, dropdown_title(options, "Season")}
  end

  def create_ladder_mode_dropdown(conn, ladder_mode) do
    options =
      ["yes", "no"]
      |> Enum.map(fn mode ->
        %{
          display: Recase.to_title(mode),
          selected: mode == ladder_mode,
          link:
            Routes.leaderboard_path(conn, :index, Map.put(conn.query_params, "ladder_mode", mode))
        }
      end)

    {options, "Ladder Mode"}
  end

  def create_show_flags_dropdown(conn, show_flags) do
    options =
      [{"Show country flags", "yes"}, {"Hide country flags", "no"}]
      |> Enum.map(fn {title, mode} ->
        %{
          display: title,
          selected: mode == show_flags,
          link:
            Routes.leaderboard_path(conn, :index, Map.put(conn.query_params, "show_flags", mode))
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
          link:
            Routes.leaderboard_path(conn, :index, Map.put(conn.query_params, "compare_to", id))
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

  def show_mt_column?(%{leaderboard_id: "STD", season_id: season_id}),
    do: elem(get_ladder_tour_stop(season_id), 0) == :ok

  def show_mt_column?(_), do: false

  def old?(%{upstream_updated_at: updated_at, season_id: 94, leaderboard_id: "STD", region: "US"}) do
    updated_at && DateTime.diff(DateTime.utc_now(), updated_at) &&
      DateTime.diff(DateTime.utc_now(), ~U[2021-09-01T07:00:00Z]) < 0
  end

  def old?(%{upstream_updated_at: updated_at, season_id: season_id, leaderboard_id: ldb}) do
    updated_at && DateTime.diff(DateTime.utc_now(), updated_at) > 3600 &&
      season_id >= get_season_id(Date.utc_today(), ldb)
  end

  def old?(_), do: false

  def add_other_ladders(invited, other_ladders, ladder_invite_num) do
    other_ladders
    |> Enum.flat_map(fn leaderboard ->
      process_entries(leaderboard, invited, nil, false, ladder_invite_num)
      |> Enum.filter(fn e -> e.qualifying |> elem(0) end)
      |> Enum.with_index(1)
      |> Enum.map(fn {e, pos} -> {e.account_id, {:other_ladder, leaderboard.region, pos}} end)
    end)
    |> Map.new()
    |> Map.merge(invited)
  end

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

  def process_invited(nil, invited_raw), do: process_invited(invited_raw, NaiveDateTime.utc_now())

  def process_invited(%{upstream_updated_at: updated_at}, invited_raw),
    do: process_invited(invited_raw, updated_at)

  def process_invited(invited_raw, updated_at) do
    not_invited_afterwards = fn ip ->
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
  def process_entries(nil, _, _, _, _), do: []

  def process_entries(
        snapshot = %{entries: entries, upstream_updated_at: upstream_updated_at},
        invited,
        comparison,
        show_flags,
        num_invited
      ) do
    Enum.map_reduce(entries, 1, fn le = %{account_id: account_id}, acc ->
      warning = warning(snapshot, account_id)
      qualified = !warning && Map.get(invited, account_id)

      ineligible = Blizzard.ineligible?(account_id, upstream_updated_at)
      qualifying = {!qualified && !ineligible && acc <= num_invited, acc}

      {prev_rank, prev_rating} = prev(comparison, account_id)

      flag =
        with true <- show_flags,
             cc when is_binary(cc) <- Backend.PlayerInfo.get_country(account_id) do
          country_flag(cc)
        else
          _ -> ""
        end

      {
        le
        |> Map.put_new(:qualified, qualified)
        |> Map.put_new(:qualifying, qualifying)
        |> Map.put_new(:ineligible, ineligible)
        |> Map.put_new(:prev_rank, prev_rank)
        |> Map.put_new(:warning, warning)
        |> Map.put_new(:flag, flag)
        |> Map.put_new(:prev_rating, prev_rating),
        if qualified || ineligible do
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
      _ -> {201, nil}
    end
  end

  def process_sorting(sort_by_raw, direction_raw) do
    case {sort_by_raw, direction_raw} do
      {s, d} when is_atom(d and is_binary(s)) -> {s, d}
      {s, _} when is_binary(s) -> {s, :desc}
      _ -> {"Total Finishes", :desc}
    end
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
      flag_part = if show_flags && country, do: country_flag(country), else: ""

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
        "Best" => ps.ranks |> Enum.min(),
        "Worst" => ps.ranks |> Enum.max(),
        "Average Finish" => avg,
        "Total Finishes" => total
      }
    end)
  end
end
