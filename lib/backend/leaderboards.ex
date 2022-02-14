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

  @type player_history_entry :: %{
    rank: integer(),
    rating: integer() | nil,
    upstream_updated_at: NaiveDateTime.t(),
    snapshot_id: integer(),
    prev_rank: integer() | nil,
    prev_rating: integer() | nil
  }

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
  defp should_avoid_fetching?(_r, _l, _s), do: false

  def get_leaderboard(region, leaderboard, season) when is_atom(leaderboard), do: get_leaderboard(region, to_string(leaderboard), season)
  def get_leaderboard(region, leaderboard, season) do
    curr_season = Blizzard.get_current_ladder_season(leaderboard) || 0
    if should_avoid_fetching?(region, leaderboard, season) do
      get_by_info(region, leaderboard, season)
    else
      get_and_save(region, leaderboard, season)
      |> get_latest_matching()
      |> case do
        nil -> get_by_info(region, leaderboard, season)
        # if the official site is messed up and is returning an older season
        ldb = %{season_id: s} when s < curr_season and s != curr_season and season == nil ->
          get_newer(region, leaderboard, curr_season, ldb)
        ldb -> ldb
      end
    end
  end

  defp get_newer(region, leaderboard, season, older) do
    case get_leaderboard(region, leaderboard, season) do
      newer = %{season_id: _}  -> newer
      _ -> older
    end
  end

  def get_by_info(region, leaderboard, season) do
    get_criteria(:latest)
    |> Kernel.++([{"leaderboard_id", leaderboard}, {"region", region}])
    |> add_season(season)
    |> snapshots()
    |> Enum.at(0)
  end
  defp add_season(criteria, nil), do: criteria
  defp add_season(criteria, season), do: [{"season_id", season} | criteria]

  def get_comparison(snap = %Snapshot{}, min_ago) do
    get_criteria(snap, [:latest, :season, min_ago])
    |> snapshots()
    |> Enum.at(0)
  end

  def save_current() do
    for region <- Blizzard.qualifier_regions(),
        ldb <- Blizzard.leaderboards() do
      latest_season = Blizzard.get_current_ladder_season(ldb) || 0
      case get_and_save(region, ldb, nil)  do
        ldb = %{season_id: s} when s >= latest_season -> ldb
        _ -> get_and_save(region, ldb, latest_season)
      end
    end
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
  defp create_ldb(l = %{season_id: 95}),
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

  defp get_criteria(:latest), do: [{"order_by", {:desc, :upstream_updated_at}}, {"limit", 1}, {"updated_at_exists"}]

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

  @spec player_history(String.t(), list(), nil | atom()) ::  [player_history_entry()]
  def player_history(player, criteria, dedup_by \\ nil) do
    new_criteria = [{"players", [player]} | criteria]
    base_player_history_query(player)
    |> build_snapshot_query(new_criteria)
    |> add_player_history_previous()
    |> dedup_player_history(dedup_by)
    |> Repo.all()
  end
  def snapshots(criteria) do
    base_snapshots_query()
    |> build_snapshot_query(criteria)
    |> Repo.all()
  end

  defp add_player_history_previous(query) do
    from e in subquery(query),
      windows: [w: [order_by: e.upstream_updated_at]],
      select: %{
        rank: e.rank,
        rating: e.rating,
        upstream_updated_at: e.upstream_updated_at,
        snapshot_id: e.snapshot_id,
        prev_rating: lag(e.rating) |> over(:w),
        prev_rank: lag(e.rank) |> over(:w)
      }
  end
  defp dedup_player_history(query, nil), do: query
  defp dedup_player_history(query, dedup_by) do
    {curr, prev} = dedup_fields(dedup_by)
    from d in subquery(query),
      where: field(d, ^curr) != field(d, ^prev)
  end

  def dedup_fields(:rank), do: {:rank, :prev_rank}
  def dedup_fields(:rating), do: {:rating, :prev_rating}

  @rank_fragment "(?->>'rank')::INTEGER"
  @rating_fragment "(?->>'rating')::INTEGER"
  defp base_player_history_query(player) do
    from s in Snapshot,
      inner_lateral_join: e in fragment("jsonb_array_elements(to_jsonb(?))", s.entries),
      on: fragment("?->>'account_id' LIKE ?", e, ^player),
      select: %{
        rank: fragment(@rank_fragment, e),
        rating: fragment(@rating_fragment, e),
        upstream_updated_at: s.upstream_updated_at,
        snapshot_id: s.id,
      },
      where: not like(s.leaderboard_id, "invalid_%")
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
    |> where([s], s.region == ^to_string(region))
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
    |> where([s], s.leaderboard_id == ^to_string(leaderboard_id))
  end

  defp compose_snapshot_query({"updated_at_exists"}, query) do
    query |> where([s], not is_nil(s.upstream_updated_at))
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

  defp compose_snapshot_query({"after", date = %NaiveDateTime{}}, query) do
    query
    |> where([s], s.upstream_updated_at > ^date)
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
  for unit <- ["minute", "day", "hour", "week", "month", "year"] do
    defp compose_snapshot_query({"period", <<"past_"::binary, unquote(unit)::binary, "s_"::binary, raw::bitstring>>}, query),
      do: past_period(query, raw, unquote(unit))
  end

  defp compose_snapshot_query({"period", <<"season_"::binary, season_id::bitstring>>}, query),
    do: compose_snapshot_query({"season_id", season_id}, query)

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

  defp past_period(query, raw, unit) do
    {val, _} = Integer.parse(raw)
    query
    |> where([s], s.upstream_updated_at > ago(^val, ^unit))
  end

  def finishes_for_battletag(battletag_full),
    do: [{:latest_in_season}, {"battletag_full", battletag_full}] |> snapshots()

  @spec player_history(String.t(), String.t(), integer() | String.t(), String.t()) :: [player_history_entry()]
  def player_history(player, region, period, leaderboard_id, changed_attr \\ :rank) do
    criteria = [{"period", period}, {"region", region}, {"leaderboard_id", leaderboard_id}]
    player_history(player, criteria, changed_attr)
    # |> dedup_player_histories(changed_attr)
  end


  @spec dedup_player_histories([player_history_entry()], atom()) :: [player_history_entry()]
  def dedup_player_histories(histories, changed_attr) do
    histories
    |> Enum.sort_by(& &1.upstream_updated_at, & NaiveDateTime.compare(&1, &2) == :lt)
    |> Enum.dedup_by(& Map.get(&1, changed_attr))
  end
end
