defmodule BackendWeb.LeaderboardController do
  use BackendWeb, :controller
  alias Backend.Blizzard
  alias Backend.Leaderboards
  alias Backend.MastersTour
  alias Backend.LeaderboardsPoints
  alias Backend.LeaderboardsPoints.HsEsports2025
  require Backend.LobbyLegends
  require Logger

  defp parse_use_current(%{"use_current_season" => "no"}), do: false
  defp parse_use_current(_), do: true

  def points(conn, params = %{"points_season" => ps, "leaderboard_id" => ldb}) do
    use_current = parse_use_current(params)
    points = LeaderboardsPoints.calculate(ps, ldb, use_current)

    render(conn, "points.html", %{
      conn: conn,
      use_current: use_current,
      points_season: ps,
      leaderboard_id: ldb,
      region: params["region"],
      countries: multi_select_to_array(params["country"]),
      points: points,
      page_title: "HSEsports Leaderboards Points"
    })
  end

  def points(conn, params_raw) do
    params =
      params_raw
      |> Map.put_new("points_season", HsEsports2025.current_points_season())
      |> Map.put_new("leaderboard_id", "STD")

    points(conn, params)
  end

  @needs_login ["compare_to", "up_to"]
  defp needs_login?(params) do
    Enum.any?(["compare_to", "up_to"], &Map.has_key?(params, &1))
  end

  def index(conn, params = %{"region" => _, "leaderboardId" => _}) do
    if needs_login?(params) && !BackendWeb.AuthUtils.user(conn) do
      viewable_url = Routes.leaderboard_path(conn, :index, Map.drop(params, @needs_login))
      {:error, :needs_login, viewable_url}
    else
      criteria = create_criteria(params)
      leaderboard = get_shim(criteria, params)
      compare_to = params["compare_to"]
      comparison = get_comparison(criteria, compare_to)
      ladder_mode = parse_ladder_mode(params)
      show_flags = parse_show_flags(params)
      skip_cn = parse_skip_cn(params, leaderboard)
      {invited, ladder_invite_num, ladder_points} = leaderboard |> get_season_info()

      render(conn, "index.html", %{
        conn: conn,
        invited: invited,
        ladder_invite_num: ladder_invite_num,
        highlight: parse_highlight(params),
        other_ladders: get_other_ladders(leaderboard, ladder_mode, criteria),
        leaderboard: leaderboard,
        compare_to: params["compare_to"],
        show_flags: show_flags,
        page_title: "Ladder Leaderboard",
        search: params["search"],
        skip_cn: skip_cn,
        comparison: comparison,
        ladder_points: ladder_points,
        show_ratings: show_ratings(params, leaderboard),
        ladder_mode: ladder_mode
      })
    end
  end

  def index(conn, params) do
    new_params =
      params
      |> Map.put_new("region", "EU")
      |> Map.put_new("leaderboardId", "STD")

    index(conn, new_params)
  end

  defp create_criteria(params) do
    [:latest_in_season, {"order_by", "rank"}]
    |> parse_up_to(params)
    |> parse_season(params)
    |> parse_offset(params)
    |> parse_limit(params)
    |> parse_search(params)

    # keep freshest after season
  end

  defp get_shim(criteria, params) do
    criteria
    |> Leaderboards.get_shim()
    |> hack_lobby_legends_season(params)
  end

  defp parse_offset(criteria, params) do
    offset = Map.get(params, "offset", 0)

    [
      {"offset", offset}
      | criteria
    ]
  end

  defp parse_limit(criteria, params) do
    limit = Map.get(params, "limit", 200)

    [
      {"limit", limit}
      | criteria
    ]
  end

  defp parse_search(criteria, %{"search" => search}), do: [{"search", search} | criteria]
  defp parse_search(criteria, _), do: criteria

  defp parse_up_to(criteria, %{"up_to" => raw}) do
    case Timex.parse(raw, "{RFC3339z}") do
      {:ok, date} ->
        [{"up_to", date} | criteria]

      _ ->
        criteria
    end
  end

  defp parse_up_to(criteria, _), do: criteria

  defp parse_season(criteria, params) do
    from_params = create_season(params)

    case Leaderboards.get_season(from_params) do
      {:ok, s} -> [{"season", s} | criteria]
      _ -> [{"season", from_params} | criteria]
    end
  end

  defp show_ratings(%{"show_ratings" => sr}, _leaderboard) when sr in ["yes", "true"], do: true
  defp show_ratings(%{"show_ratings" => sr}, _leaderboard) when sr in ["no", "false"], do: false

  defp show_ratings(_params, leaderboard),
    do: to_string(leaderboard.leaderboard_id) in ["MRC", "BG", "BG_LL", "arena", "DUO"]

  defp hack_lobby_legends_season(ldb = %{}, %{"seasonId" => new_season = "lobby_legends" <> _}),
    do: Map.put(ldb, :season_id, new_season)

  defp hack_lobby_legends_season(ldb, _), do: ldb

  def parse_skip_cn(%{"skip_cn" => skip}, _) when skip in ["all", "previously_skipped", "none"],
    do: skip

  def parse_skip_cn(_, _), do: "all"

  def parse_show_flags(%{"show_flags" => "no"}), do: "no"
  def parse_show_flags(_), do: "yes"

  def parse_ladder_mode(%{"ladder_mode" => "no"}), do: "no"
  def parse_ladder_mode(_), do: "yes"

  def get_season_info(nil), do: {[], 0, nil}

  def get_season_info(%{leaderboard_id: "BG", season_id: s})
      when Backend.LobbyLegends.is_lobby_legends_points(s),
      do: {
        [],
        0,
        [
          {{1, 1}, 8},
          {{2, 5}, 7},
          {{6, 10}, 6},
          {{11, 20}, 5},
          {{21, 30}, 4},
          {{31, 40}, 3},
          {{41, 50}, 2},
          {{51, 100}, 1}
        ]
      }

  def get_season_info(%{leaderboard_id: "BG", season_id: s})
      when Backend.LobbyLegends.is_lobby_legends(s),
      do: {[], 16, nil}

  def get_season_info(%{season_id: season_id}), do: get_season_info(season_id)

  def get_season_info(season_id) do
    with {:ok, ts} <- Blizzard.get_ladder_tour_stop(season_id),
         %{ladder_points: points} <- MastersTour.TourStop.get(ts) do
      {[], 0, points}
    else
      {:ok, tour_stop} ->
        {MastersTour.list_invited_players(tour_stop),
         MastersTour.TourStop.ladder_invites(tour_stop), nil}

      _ ->
        {[], 0, nil}
    end
  end

  def get_other_ladders(ldb, other_ladders, criteria) do
    with {{"season", s}, p} <- List.keytake(criteria, "season", 0) do
      ladders_to_check(ldb, other_ladders)
      |> Enum.map(fn r ->
        new_season = %Hearthstone.Leaderboards.Season{
          season_id: s.season_id,
          leaderboard_id: s.leaderboard_id,
          region: to_string(r)
        }

        [{"season", new_season} | p]
        |> Leaderboards.get_shim()
      end)
    end
  end

  def ladders_to_check(%{season_id: s, leaderboard_id: ldb = "BG", region: r}, "yes") do
    Blizzard.ladders_to_check(s, ldb, r)
  end

  def ladders_to_check(%{season_id: s, leaderboard_id: ldb = "STD", region: r}, "yes") do
    s
    |> MastersTour.TourStop.get_by_ladder()
    |> case do
      {:ok, _} ->
        Blizzard.ladders_to_check(s, ldb, r)

      _ ->
        []
    end
  end

  def ladders_to_check(_, _), do: []

  def parse_highlight(params) do
    case params["highlight"] do
      string when is_binary(string) -> MapSet.new([string])
      list when is_list(list) -> MapSet.new(list)
      _ -> nil
    end
  end

  defp create_season(params) do
    %Hearthstone.Leaderboards.Season{
      region: params["region"],
      leaderboard_id: params["leaderboard_id"] || params["leaderboardId"],
      season_id: (params["season_id"] || params["seasonId"]) |> Util.to_int_or_orig()
    }
    |> Hearthstone.Leaderboards.Season.ensure_region()
    |> Hearthstone.Leaderboards.Season.ensure_leaderboard_id()
  end

  defp get_comparison(criteria, "season_" <> season_id) do
    {{"season", season}, no_season} = List.keytake(criteria, "season", 0)

    base_season = %{
      leaderboard_id: season.leaderboard_id,
      region: season.region,
      season_id: Util.to_int_or_orig(season_id)
    }

    new_season =
      case Leaderboards.get_season(base_season) do
        {:ok, s} -> s
        _ -> base_season
      end

    new_criteria =
      [{"season", new_season} | no_season]
      |> List.keydelete("limit", 0)
      |> List.keydelete("offset", 0)

    Leaderboards.get_shim(new_criteria)
  end

  defp get_comparison(criteria, "min_ago_" <> min_ago) do
    case Integer.parse(min_ago) do
      {min, _} ->
        {base_time, partial} =
          case List.keytake(criteria, "up_to", 0) do
            {{"up_to", time}, p} -> {time, p}
            _ -> {NaiveDateTime.utc_now(), criteria}
          end

        comparison_time = NaiveDateTime.add(base_time, -60 * min)

        [{"up_to", comparison_time} | partial]
        |> Leaderboards.get_shim()

      _ ->
        nil
    end
  end

  defp get_comparison(_, _), do: nil

  def player_stats(conn, params) do
    direction =
      case params["direction"] do
        "desc" -> :desc
        "asc" -> :asc
        _ -> nil
      end

    regions = multi_select_to_array(params["regions"])
    leaderboards = multi_select_to_array(params["leaderboards"])

    min = with raw when is_binary(raw) <- params["min"], {val, _} <- Integer.parse(raw), do: val

    criteria =
      [:latest_in_season]
      |> add_region_criteria(regions)
      |> add_leaderboard_criteria(leaderboards)
      |> add_min_rating_criteria()

    stats = Leaderboards.stats(criteria, 60_000)

    render(conn, "stats.html", %{
      conn: conn,
      leaderboards: leaderboards,
      regions: regions,
      direction: direction,
      min: min,
      sort_by: params["sort_by"],
      countries: multi_select_to_array(params["country"]),
      show_flags: parse_yes_no(params["show_flags"], "yes"),
      page_title: "Leaderboard Stats",
      stats: stats
    })
  end

  def history_attr(%{"attr" => "rating"}), do: :rating
  def history_attr(_), do: :rank
  @default_ignore_rank nil
  def ignore_rank(%{"ignore_rank_changes" => "less_than_equal_" <> num_part}),
    do: Util.to_int(num_part, @default_ignore_rank)

  def ignore_rank(_), do: @default_ignore_rank

  def player_history_old(
        conn,
        params = %{
          "leaderboard_id" => ldb,
          "region" => region,
          "season_id" => season,
          "player" => player
        }
      ) do
    attr = history_attr(params)

    link =
      Routes.leaderboard_path(conn, :player_history, region, "season_#{season}", ldb, player,
        attr: attr
      )

    conn
    |> Plug.Conn.put_status(302)
    |> redirect(to: link)
  end

  def player_history(
        conn,
        params = %{
          "leaderboard_id" => ldb,
          "region" => region,
          "period" => period,
          "player" => player
        }
      ) do
    attr = history_attr(params)
    min_max_criteria = extract_min_max_criteria(params)
    ignore_rank = ignore_rank(params)

    player_history =
      Backend.Leaderboards.player_history(player, region, period, ldb, attr, min_max_criteria)

    render(conn, "player_history.html", %{
      player_history: player_history,
      player: player,
      attr: attr,
      min_max_criteria: min_max_criteria,
      ignore_rank: ignore_rank
    })
  end

  def rank_history(
        conn,
        %{
          "leaderboard_id" => ldb,
          "region" => region,
          "period" => period,
          "rank" => rank_raw
        }
      ) do
    rank = Util.to_int(rank_raw, 1)
    history = Backend.Leaderboards.rank_history(rank, region, period, ldb)

    render(conn, "rank_history.html", %{
      rank_history: history,
      conn: conn,
      rank: rank
    })
  end

  def extract_min_max_criteria(params) do
    for key <- ["min_rank", "max_rank", "min_rating", "max_rating"],
        val = Map.get(params, key),
        val != "" do
      {key, Util.to_int_or_orig(val)}
    end
  end

  defp add_leaderboard_criteria(criteria, []), do: add_leaderboard_criteria(criteria, nil)
  defp add_leaderboard_criteria(criteria, nil), do: [{"leaderboard_id", ["STD"]} | criteria]
  defp add_leaderboard_criteria(criteria, ids), do: [{"leaderboard_id", ids} | criteria]

  defp add_min_rating_criteria(criteria) do
    with {"leaderboard_id", ids} <- List.keyfind(criteria, "leaderboard_id", 0),
         true <- "BG" in ids or "BG_LL" in ids or "DUO" in ids do
      [{"conditional_min_rating", 8000} | criteria]
    else
      _ -> criteria
    end
  end

  defp add_region_criteria(criteria, []), do: criteria
  defp add_region_criteria(criteria, nil), do: criteria
  defp add_region_criteria(criteria, regions), do: [{"region", regions} | criteria]
end
