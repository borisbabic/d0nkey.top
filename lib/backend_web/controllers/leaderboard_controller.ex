defmodule BackendWeb.LeaderboardController do
  require Logger
  use BackendWeb, :controller
  alias Backend.Blizzard
  alias Backend.Leaderboards
  alias Backend.MastersTour
  require Backend.LobbyLegends

  def index(conn, params = %{"region" => _, "leaderboardId" => _}) do
    leaderboard = get_leaderboard(params) |> hack_lobby_legends_season(params)
    compare_to = params["compare_to"]
    comparison = get_comparison(leaderboard, compare_to)
    ladder_mode = parse_ladder_mode(params)
    show_flags = parse_show_flags(params, leaderboard)
    skip_cn = parse_skip_cn(params, leaderboard)
    {invited, ladder_invite_num} = leaderboard |> get_season_info()

    render(conn, "index.html", %{
      conn: conn,
      invited: invited,
      ladder_invite_num: ladder_invite_num,
      highlight: parse_highlight(params),
      other_ladders: leaderboard |> get_other_ladders(ladder_mode),
      leaderboard: leaderboard,
      compare_to: params["compare_to"],
      show_flags: show_flags,
      page_title: "Ladder Leaderboard",
      skip_cn: skip_cn,
      comparison: comparison,
      show_ratings: show_ratings(params, leaderboard),
      ladder_mode: ladder_mode
    })
  end

  defp show_ratings(%{"show_ratings" => sr}, _leaderboard) when sr in ["yes", "true"], do: true
  defp show_ratings(%{"show_ratings" => sr}, _leaderboard) when sr in ["no", "false"], do: false

  defp show_ratings(_params, leaderboard),
    do: to_string(leaderboard.leaderboard_id) in ["MRC", "BG"]

  defp hack_lobby_legends_season(ldb = %{}, %{"seasonId" => new_season = "lobby_legends" <> _}),
    do: Map.put(ldb, :season_id, new_season)

  defp hack_lobby_legends_season(ldb, _), do: ldb

  def parse_skip_cn(%{"skip_cn" => skip}, _) when skip in ["all", "previously_skipped", "none"],
    do: skip

  def parse_skip_cn(_, _), do: "all"

  def index(conn, params) do
    new_params =
      params
      |> Map.put_new("region", "EU")
      |> Map.put_new("leaderboardId", "STD")

    index(conn, new_params)
  end

  def parse_show_flags(%{"show_flags" => sf}, _) when sf in ["no", "yes"], do: sf

  def parse_show_flags(_, %{leaderboard_id: "BG", season_id: s})
      when Backend.LobbyLegends.is_lobby_legends(s),
      do: "yes"

  def parse_show_flags(_, %{leaderboard_id: "STD"}), do: "yes"
  def parse_show_flags(_, _), do: "no"

  def parse_ladder_mode(%{"ladder_mode" => "no"}), do: "no"
  def parse_ladder_mode(_), do: "yes"

  def get_season_info(nil), do: {[], 0}

  def get_season_info(%{leaderboard_id: "BG", season_id: s})
      when Backend.LobbyLegends.is_lobby_legends(s),
      do: {[], 16}

  def get_season_info(%{season_id: season_id}), do: get_season_info(season_id)

  def get_season_info(season_id) do
    case Blizzard.get_ladder_tour_stop(season_id) do
      {:ok, tour_stop} ->
        {MastersTour.list_invited_players(tour_stop),
         MastersTour.TourStop.ladder_invites(tour_stop)}

      {:error, _} ->
        {[], 0}
    end
  end

  def get_other_ladders(%{season_id: s, leaderboard_id: ldb = "BG", region: r}, "yes") do
    Blizzard.ladders_to_check(s, ldb, r)
    |> other_ladders(ldb, s)
  end

  def get_other_ladders(%{season_id: s, leaderboard_id: ldb = "STD", region: r}, "yes") do
    s
    |> MastersTour.TourStop.get_by_ladder()
    |> case do
      {:ok, _} ->
        Blizzard.ladders_to_check(s, ldb, r)
        |> other_ladders(ldb, s)

      _ ->
        []
    end
  end

  def get_other_ladders(_, _), do: []

  defp other_ladders(regions, ldb, s) do
    regions
    |> Enum.flat_map(fn region ->
      case get_leaderboard(region, ldb, s) do
        nil -> []
        leaderboard -> [leaderboard]
      end
    end)
  end

  def parse_highlight(params) do
    case params["highlight"] do
      string when is_binary(string) -> MapSet.new([string])
      list when is_list(list) -> MapSet.new(list)
      _ -> nil
    end
  end

  def get_leaderboard(%{"database_id" => id}), do: Leaderboards.snapshot(id)

  def get_leaderboard(%{
        "up_to" => string_date,
        "region" => region,
        "leaderboardId" => leaderboard
      }) do
    case string_date |> Timex.parse("{RFC3339z}") do
      {:error, _} ->
        nil

      {:ok, date} ->
        Leaderboards.latest_up_to(region, leaderboard, date)
    end
  end

  def get_leaderboard(params) do
    create_season(params)
    |> Leaderboards.get_leaderboard_shim()
  end

  def get_leaderboard(params = %{"region" => region, "leaderboardId" => leaderboard_id}) do
    get_leaderboard(region, leaderboard_id, params["seasonId"])
  end

  defp get_leaderboard(r, l, s) do
    try do
      Leaderboards.get_leaderboard(r, l, s)
    rescue
      _ -> nil
    end
  end

  defp create_season(params) do
    %Hearthstone.Leaderboards.Season{
      region: params["region"],
      leaderboard_id: params["leaderboard_id"] || params["leaderboardId"],
      season_id: params["season_id"] || params["seasonId"]
    }
    |> Hearthstone.Leaderboards.Season.ensure_region()
    |> Hearthstone.Leaderboards.Season.ensure_leaderboard_id()
  end

  defp get_comparison(_, nil), do: nil

  defp get_comparison(l, c_t) do
    try do
      Leaderboards.get_comparison(l, c_t)
    rescue
      _ -> nil
    end
  end

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
      [{:latest_in_season}]
      |> add_not_current_season_critera(leaderboards)
      |> add_region_criteria(regions)
      |> add_leaderboard_criteria(leaderboards)

    stats = Leaderboards.stats(criteria)

    render(conn, "stats.html", %{
      conn: conn,
      leaderboards: leaderboards,
      regions: regions,
      direction: direction,
      min: min,
      sort_by: params["sort_by"],
      countries: multi_select_to_array(params["country"]),
      show_flags: parse_yes_no(params["show_flags"]),
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
    ignore_rank = ignore_rank(params)
    player_history = Backend.Leaderboards.player_history(player, region, period, ldb, attr)

    render(conn, "player_history.html", %{
      player_history: player_history,
      player: player,
      attr: attr,
      ignore_rank: ignore_rank
    })
  end

  defp add_not_current_season_critera(criteria, []),
    do: add_not_current_season_critera(criteria, ["STD"])

  defp add_not_current_season_critera(criteria, ids), do: [{:not_current_season, ids} | criteria]

  defp add_leaderboard_criteria(criteria, []), do: add_leaderboard_criteria(criteria, nil)
  defp add_leaderboard_criteria(criteria, nil), do: [{"leaderboard_id", ["STD"]} | criteria]
  defp add_leaderboard_criteria(criteria, ids), do: [{"leaderboard_id", ids} | criteria]

  defp add_region_criteria(criteria, []), do: criteria
  defp add_region_criteria(criteria, nil), do: criteria
  defp add_region_criteria(criteria, regions), do: [{"region", regions} | criteria]
end
