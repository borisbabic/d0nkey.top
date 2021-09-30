defmodule Backend.Leaderboards do
  require Logger
  require Backend.Blizzard

  @moduledoc """
  The Leaderboards context.
  """
  import Ecto.Query
  alias Backend.Repo
  alias Backend.Blizzard
  alias Backend.Leaderboards.Snapshot
  alias Backend.Leaderboards.PlayerStats

  @type entry :: %{
          battletag: String.t(),
          position: number,
          rating: number | nil
        }
  @type timestamped_leaderboard :: {[Entry], NaiveDateTime.t()}

  @type categorized_entries :: [{[entry], Blizzard.region(), Blizzard.leaderboard()}]

  defp should_avoid_fetching?(r, l, s) when is_binary(s),
    do: should_avoid_fetching?(r, l, Util.to_int(s, nil))

  defp should_avoid_fetching?(r, l, s) when not is_binary(r) or not is_binary(l),
    do: should_avoid_fetching?(to_string(r), to_string(l), s)

  # OLD BG Seasons get updated post patch with people playing on old patches
  defp should_avoid_fetching?(_r, "BG", s) when Blizzard.is_old_bg_season(s), do: true

  # Auguest 2021 constructed EU+AM leaderboards were overwritten by the first few days of september
  defp should_avoid_fetching?(r, l, 94) when r in ["EU", "US"] and l != "BG", do: true
  # September 2021
  # defp should_avoid_fetching?(r, l, 95) when r in ["AP"] and l != "BG", do: true
  defp should_avoid_fetching?(_r, _l, _s), do: false

  def get_leaderboard(region, leaderboard, season) do
    if should_avoid_fetching?(region, leaderboard, season) do
      get_by_info(region, leaderboard, season)
    else
      get_and_save(region, leaderboard, season)
      |> get_latest_matching()
      |> case do
        nil -> get_by_info(region, leaderboard, season)
        ldb -> ldb
      end
    end
  end

  def get_by_info(region, leaderboard, season) do
    [
      {"order_by", {:desc, :upstream_updated_at}},
      {"limit", 1},
      {"leaderboard_id", leaderboard},
      {"season_id", season},
      {"region", region}
    ]
    |> snapshots()
    |> Enum.at(0)
  end

  def get_comparison(snap = %Snapshot{}, min_ago) do
    get_criteria(snap, [:latest, :season, min_ago])
    |> snapshots()
    |> Enum.at(0)
  end

  def save_current() do
    for region <- Blizzard.qualifier_regions(),
        ldb <- Blizzard.leaderboards(),
        do: get_and_save(region, ldb, nil)
  end

  def save_old() do
    for region <- Blizzard.qualifier_regions(),
        ldb <- ["STD", "WLD"],
        season_id <- 64..80,
        do: get_and_save(region, ldb, season_id)
  end

  defp get_and_save(r, l, s) do
    case Blizzard.get_leaderboard(r, l, s) do
      l = %Blizzard.Leaderboard{} -> l |> get_or_create_ldb()
      _ -> nil
    end
  end

  def get_latest_matching(l = %Snapshot{}) do
    get_criteria(l, [:latest, :season])
    |> snapshots()
    |> Enum.at(0)
  end

  def get_latest_matching(_), do: nil

  def get_or_create_ldb(l = %Blizzard.Leaderboard{}) do
    case l |> get_criteria([:updated_at, :season]) |> snapshots() do
      [existing] -> existing
      _ -> create_ldb(l)
    end
  end

  def create_snapshot_attrs(l = %Blizzard.Leaderboard{}) do
    %{
      entries: l.entries |> Enum.map(&Map.from_struct/1),
      season_id: l.season_id,
      leaderboard_id: l.leaderboard_id,
      region: l.region,
      upstream_updated_at: l.updated_at
    }
  end

  # TEMPORARY FIX, october 2021 entries are being added to September 2021
  defp create_ldb(l = %{season_id: 95, region: r}) when r in ["AP", :AP, "EU", :EU],
    do: l |> Map.put(:season_id, 96) |> create_ldb()

  defp create_ldb(l = %Blizzard.Leaderboard{}) do
    attrs = create_snapshot_attrs(l)

    %Snapshot{}
    |> Snapshot.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, inserted} ->
        inserted

      {:error, _reason} ->
        Logger.warn(
          "Error saving #{attrs.season_id} #{attrs.leaderboard_id} #{attrs.region} #{
            attrs.upstream_updated_at
          }"
        )

        nil
    end
  end

  defp get_criteria(:latest), do: [{"order_by", {:desc, :upstream_updated_at}}, {"limit", 1}]

  defp get_criteria(l, criteria) when is_list(criteria),
    do: criteria |> Enum.flat_map(fn c -> get_criteria(l, c) end)

  defp get_criteria(_, :latest), do: get_criteria(:latest)

  defp get_criteria(_, <<"min_ago_"::binary, min_ago::bitstring>>),
    do: [{"until", {min_ago |> Util.to_int_or_orig(), "minute"}}]

  defp get_criteria(
         %{leaderboard_id: leaderboard_id, season_id: season_id, region: region},
         :season
       ) do
    [
      {"leaderboard_id", leaderboard_id},
      {"season_id", season_id},
      {"region", region}
    ]
  end

  defp get_criteria(%{upstream_updated_at: updated_at}, :updated_at),
    do: [{"updated_at", updated_at}]

  defp get_criteria(%{updated_at: updated_at}, :updated_at), do: [{"updated_at", updated_at}]

  @spec get_player_entries([String.t()]) :: categorized_entries
  def get_player_entries(battletags_short) do
    short_set = MapSet.new(battletags_short)

    for region <- Backend.Blizzard.qualifier_regions(),
        ldb <- Backend.Blizzard.leaderboards(),
        into: [],
        do: {get_player_entries(short_set, region, ldb), region, ldb}
  end

  @spec get_player_entries(
          [String.t()] | MapSet.t(),
          Blizzard.region(),
          Blizzard.leaderboard(),
          number | nil
        ) :: [Entry]
  def get_player_entries(battletags_short, region, leaderboard_id, season_id \\ nil)

  def get_player_entries(battletags_short = [_ | _], region, leaderboard_id, season_id) do
    get_player_entries(MapSet.new(battletags_short), region, leaderboard_id, season_id)
  end

  def get_player_entries(short_set, region, leaderboard_id, season_id) do
    %{entries: table} = get_leaderboard(region, leaderboard_id, season_id)
    table |> Enum.filter(fn e -> MapSet.member?(short_set, e.account_id) end)
  end

  def stats(criteria), do: snapshots(criteria) |> PlayerStats.create_collection()

  def latest_up_to(region, leaderboard, date) do
    ([
       {"region", region},
       {"leaderboard_id", leaderboard},
       {"up_to", date}
     ] ++
       get_criteria(:latest))
    |> snapshots()
    |> Enum.at(0)
  end

  def snapshot(id), do: [{"id", id}] |> snapshots() |> Enum.at(0)

  def snapshots(criteria) do
    base_snapshots_query()
    |> build_snapshot_query(criteria)
    |> Repo.all()
  end

  defp base_snapshots_query() do
    from s in Snapshot,
      where: not like(s.leaderboard_id, "invalid_%")
  end

  defp build_snapshot_query(query, criteria),
    do: Enum.reduce(criteria, query, &compose_snapshot_query/2)

  defp compose_snapshot_query({"latest_in_season", _}, query),
    do: compose_snapshot_query({"latest_in_season"}, query)

  defp compose_snapshot_query({"latest_in_season"}, query),
    do: compose_snapshot_query({:latest_in_season}, query)

  defp compose_snapshot_query({:latest_in_season}, query) do
    season_end_subquery =
      from e in Snapshot,
        select: %{
          season_id: e.season_id,
          leaderboard_id: e.leaderboard_id,
          region: e.region,
          upstream_updated_at: max(e.upstream_updated_at)
        },
        group_by: [:season_id, :leaderboard_id, :region]

    query
    |> join(
      :inner,
      [s],
      e in subquery(season_end_subquery),
      on:
        s.upstream_updated_at == e.upstream_updated_at and
          s.season_id == e.season_id and
          s.leaderboard_id == e.leaderboard_id and
          s.region == e.region
    )
  end

  defp compose_snapshot_query({:not_current_season, leaderboards}, query) do
    leaderboards
    |> Enum.reduce(query, fn ldb, q ->
      season_id = Blizzard.get_current_ladder_season(ldb)

      q
      |> where([s], not (s.season_id == ^season_id and s.leaderboard_id == ^ldb))
    end)
  end

  defp compose_snapshot_query({"id", id}, query) do
    query
    |> where([s], s.id == ^id)
  end

  defp compose_snapshot_query({"region", regions}, query) when is_list(regions) do
    query
    |> where([s], s.region in ^regions)
  end

  defp compose_snapshot_query({"region", region}, query) do
    query
    |> where([s], s.region == ^region)
  end

  defp compose_snapshot_query({"season_id", season_id}, query) do
    query
    |> where([s], s.season_id == ^season_id)
  end

  defp compose_snapshot_query({"leaderboard_id", leaderboards}, query)
       when is_list(leaderboards) do
    query
    |> where([s], s.leaderboard_id in ^leaderboards)
  end

  defp compose_snapshot_query({"leaderboard_id", leaderboard_id}, query) do
    query
    |> where([s], s.leaderboard_id == ^leaderboard_id)
  end

  defp compose_snapshot_query({"updated_at", nil}, query) do
    query
    |> where([s], is_nil(s.upstream_updated_at))
  end

  defp compose_snapshot_query({"updated_at", updated_at}, query) do
    query
    |> where([s], s.upstream_updated_at == ^updated_at)
  end

  defp compose_snapshot_query({"order_by", {direction, field}}, query) do
    query
    |> order_by([{^direction, ^field}])
  end

  defp compose_snapshot_query({"limit", limit}, query) do
    query
    |> limit(^limit)
  end

  defp compose_snapshot_query({"up_to", date = %NaiveDateTime{}}, query) do
    query
    |> where([s], s.upstream_updated_at < ^date)
  end

  defp compose_snapshot_query({"until", {string_num, unit}}, query) when is_binary(string_num) do
    string_num
    |> Integer.parse()
    |> case do
      {num, _} -> compose_snapshot_query({"until", {num, unit}}, query)
      :error -> raise "Invalid until, can't parse string_num"
    end
  end

  defp compose_snapshot_query({"until", {num, unit}}, query) do
    query
    |> where([s], s.upstream_updated_at < ago(^num, ^unit))
  end

  defp compose_snapshot_query({"battletag_full", battletag_full}, query) do
    players = Backend.PlayerInfo.leaderboard_names(battletag_full)
    compose_snapshot_query({"players", players}, query)
  end

  defp compose_snapshot_query({"players", players}, query) do
    similar_search = "%(#{Enum.join(players, "|")})%"

    query
    # it's over 100 times faster when first converting to jsonb, DO NOT REMOVE IT unless you test the speed
    |> where([s], fragment("to_jsonb(?)::text SIMILAR TO ?", s.entries, ^similar_search))
  end

  def finishes_for_battletag(battletag_full),
    do: [{:latest_in_season}, {"battletag_full", battletag_full}] |> snapshots()
end
