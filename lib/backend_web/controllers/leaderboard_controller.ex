defmodule BackendWeb.LeaderboardController do
  require Logger
  use BackendWeb, :controller
  alias Backend.Blizzard
  alias Backend.Leaderboards
  alias Backend.MastersTour

  def index(conn, params = %{"region" => region, "leaderboardId" => leaderboard_id}) do
    # seasonId can be nil
    {entry, updated_at} =
      try do
        Leaderboards.fetch_current_entries(region, leaderboard_id, params["seasonId"])
      rescue
        _ -> {[], nil}
      end

    ladder_mode =
      case params["ladder_mode"] do
        "yes" -> "yes"
        "no" -> "no"
        _ -> "auto"
      end

    season_id =
      case Integer.parse(to_string(conn.query_params["seasonId"])) do
        :error -> Blizzard.get_season_id(Date.utc_today())
        {id, _} -> id
      end

    invited =
      case Blizzard.get_ladder_tour_stop(season_id) do
        {:ok, tour_stop} -> MastersTour.list_invited_players(tour_stop)
        {:error, _} -> []
      end

    highlight =
      case params["highlight"] do
        string when is_binary(string) -> MapSet.new([string])
        list when is_list(list) -> MapSet.new(list)
        _ -> nil
      end

    other_ladders = get_other_ladders(season_id, leaderboard_id, ladder_mode, region)

    render(conn, "index.html", %{
      entry: entry,
      invited: invited,
      region: region,
      leaderboard_id: leaderboard_id,
      updated_at: updated_at,
      highlight: highlight,
      other_ladders: other_ladders,
      ladder_mode: ladder_mode,
      season_id: season_id
    })
  end

  def index(conn, params) do
    new_params =
      params
      |> Map.put_new("region", "EU")
      |> Map.put_new("leaderboardId", "STD")

    index(conn, new_params)
  end

  def get_other_ladders(season_id, leaderboard_id, ladder_mode, region) do
    if include_other_ladders?(season_id, leaderboard_id, ladder_mode) do
      Blizzard.ladders_to_check(season_id, region)
      |> Enum.map(fn r ->
        {entry, _} =
          try do
            Leaderboards.fetch_current_entries(r, leaderboard_id, season_id)
          rescue
            _ -> {[], nil}
          end

        %{region: r, entries: entry}
      end)
    else
      []
    end
  end

  @spec include_other_ladders?(integer, String.t() | atom, String.t()) :: boolean
  def include_other_ladders?(_, _, "yes") do
    true
  end

  def include_other_ladders?(_, _, "no") do
    false
  end

  def include_other_ladders?(season_id, leaderboard_id, "auto") do
    today = Date.utc_today()
    season_start = Blizzard.get_month_start(season_id)
    date_diff = Date.diff(today, season_start)
    date_diff > 26 && date_diff < 33 && to_string(leaderboard_id) == "STD"
  end
end
