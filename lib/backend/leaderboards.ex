defmodule Backend.Leaderboards do
  require Logger
  require Backend.Blizzard

  @moduledoc """
  The Leaderboards context.
  """
  import Ecto.Query
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.Blizzard
  alias Backend.LobbyLegends.LobbyLegendsSeason
  alias Backend.Leaderboards.PageFetcher
  alias Backend.Leaderboards.Snapshot
  alias Backend.Leaderboards.PlayerStats
  alias Backend.Leaderboards.Entry
  alias Backend.Leaderboards.Season
  alias Backend.Leaderboards.SeasonBag
  alias Hearthstone.Leaderboards.Season, as: ApiSeason
  alias Hearthstone.Leaderboards.Api
  alias Hearthstone.Leaderboards.Response
  alias Hearthstone.Leaderboards.Response.Row

  @type history_entry :: %{
          rank: integer(),
          rating: integer() | nil,
          upstream_updated_at: NaiveDateTime.t(),
          prev_rank: integer() | nil,
          prev_rating: integer() | nil
        }

  @type entry :: %{
          battletag: String.t(),
          position: number,
          rating: number | nil
        }

  @type categorized_entries :: [{[entry], Blizzard.region(), Blizzard.leaderboard()}]

  defp should_avoid_fetching?(_r, _l, "lobby_legends_" <> _), do: true

  defp should_avoid_fetching?(r, l, s) when is_binary(s),
    do: should_avoid_fetching?(r, l, Util.to_int(s, nil))

  defp should_avoid_fetching?(r, l, s) when not is_binary(r) or not is_binary(l),
    do: should_avoid_fetching?(to_string(r), to_string(l), s)

  # OLD BG Seasons get updated post patch with people playing on old patches
  defp should_avoid_fetching?(_r, "BG", s) when Blizzard.is_old_bg_season(s), do: true

  # Auguest 2021 constructed EU+AM leaderboards were overwritten by the first few days of september
  defp should_avoid_fetching?(r, l, 94) when r in ["EU", "US"] and l != "BG", do: true
  defp should_avoid_fetching?(_r, _l, _s), do: false

  def get_shim(criteria) do
    {"season", season} =
      List.keyfind(
        criteria,
        "season",
        0,
        {"season", %{season_id: nil, region: nil, leaderboard_id: nil}}
      )

    entries = entries(criteria)
    updated_at = updated_at(entries)

    %{
      season_id: season.season_id,
      leaderboard_id: season.leaderboard_id,
      region: season.region,
      upstream_updated_at: updated_at,
      entries: entries
    }
  end

  def get_leaderboard_shim(s) do
    with {:ok, season} <- get_season(s) do
      criteria = [:latest_in_season, {"season", season}, {"limit", 200}, {"order_by", "rank"}]
      entries = entries(criteria)

      updated_at = updated_at(entries)

      %{
        season_id: season.season_id,
        leaderboard_id: season.leaderboard_id,
        region: season.region,
        upstream_updated_at: updated_at,
        entries: entries
      }
    end
  end

  def updated_at(entries) do
    with [_ | _] <- entries,
         %{inserted_at: naive_updated_at} <-
           Enum.max_by(entries, &NaiveDateTime.to_iso8601(&1.inserted_at)),
         {:ok, updated_at} <- DateTime.from_naive(naive_updated_at, "Etc/UTC") do
      updated_at
    else
      _ -> nil
    end
  end

  def get_leaderboard(region, leaderboard, season) when is_atom(leaderboard),
    do: get_leaderboard(region, to_string(leaderboard), season)

  def get_leaderboard(region, leaderboard, season) do
    curr_season = Blizzard.get_current_ladder_season(leaderboard) || 0

    if should_avoid_fetching?(region, leaderboard, season) do
      get_by_info(region, leaderboard, season)
    else
      get_and_save(region, leaderboard, season)
      |> get_latest_matching()
      |> case do
        nil ->
          get_by_info(region, leaderboard, season)

        # if the official site is messed up and is returning an older season
        ldb = %{season_id: s} when s < curr_season and s != curr_season and season == nil ->
          get_newer(region, leaderboard, curr_season, ldb)

        ldb ->
          ldb
      end
    end
  end

  defp get_newer(region, leaderboard, season, older) do
    case get_leaderboard(region, leaderboard, season) do
      newer = %{season_id: _} -> newer
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

  def save_current(num \\ nil) do
    tasks_per_current_api_season(&save_all(&1, num))
    |> Task.await_many(:infinity)

    # refresh_latest()
  end

  defp do_per_current_api_season(func) do
    for region <- Blizzard.qualifier_regions(),
        ldb <- Blizzard.active_leaderboards() do
      season = %ApiSeason{
        region: region,
        leaderboard_id: to_string(ldb)
      }

      func.(season)
    end
  end

  defp tasks_per_current_api_season(func) do
    do_per_current_api_season(fn season ->
      Task.async(fn ->
        func.(season)
      end)
    end)
  end

  def save_current_for_region_with_delay(
        region,
        leaderboards,
        between_pages_delay_ms,
        between_leaderboards_delay_ms \\ 300_000
      ) do
    for l <- leaderboards do
      save_all_with_delay(
        %ApiSeason{region: region, leaderboard_id: to_string(l)},
        between_pages_delay_ms
      )

      Process.sleep(between_leaderboards_delay_ms)
    end
  end

  def save_current_with_delay(delay_ms, max_num) do
    do_per_current_api_season(&save_all_with_delay(&1, delay_ms, max_num))
  end

  def save_current_with_retry(max_num \\ nil, min_num \\ 1) do
    tasks_per_current_api_season(&save_with_retry(&1, max_num, min_num))
    |> Task.await_many(:infinity)
  end

  def save_with_retry(season, max_num \\ nil, min_num \\ 1) do
    max_page = count_to_page_num(max_num)
    min_page = count_to_page_num(min_num)

    with {:ok, response} <- Api.get_page(season) do
      PageFetcher.enqueue_all(response, max_page, min_page)
    end
  end

  @page_size 25
  def count_to_page_num(nil), do: nil
  def count_to_page_num(count), do: ceil(count / @page_size)

  def save_all(s, num \\ nil) do
    with {:ok, rows, season} <- fetch_pages(s, num) do
      handle_rows(rows, season)
    end
  end

  @spec save_all_with_delay(
          partial_or_full_season :: ApiSeason.t(),
          delay_milliseconds :: integer(),
          integer() | nil
        ) ::
          {:ok, {[Row.t()], season_from_response :: ApiSeason.t()}}
          | {:error, error :: any(),
             rows_prior_to_error :: {Row.t(), season_from_response :: ApiSeason.t()}}
  def save_all_with_delay(season, delay_ms, num \\ nil) do
    with {:ok, response} <- Api.get_page(season),
         {:ok, total_pages} <- Response.total_pages(response) do
      rows = Response.rows(response)
      Task.start(fn -> handle_rows(rows, season) end)

      opts = %{
        season: season,
        num_entries: num,
        delay_ms: delay_ms,
        total_pages: total_pages,
        page_to_fetch: 2,
        previous: rows
      }

      do_save_rows(opts)
    else
      _ ->
        Logger.warn("Couldn't get first page for #{inspect(season)}")
        {:error, "Could not fetch initial page", {[], season}}
    end
  end

  # just in case something is messed up in the api, don't wanna infinite this if they stop returning total pages correctly
  defp do_save_rows(%{page_to_fetch: page_to_fetch, previous: previous, season: season})
       when page_to_fetch >= 1_000_000 / @page_size,
       do:
         {:error,
          "Trying to fetch an insane number of pages on the leaderboards, up to #{page_to_fetch}",
          {previous, season}}

  defp do_save_rows(%{
         page_to_fetch: page_to_fetch,
         total_pages: total_pages,
         previous: previous,
         season: season
       })
       when page_to_fetch > total_pages do
    {:ok, {previous, season}}
  end

  defp do_save_rows(%{previous: previous, num_entries: num_entries, season: season})
       when is_integer(num_entries) and length(previous) >= num_entries do
    {:ok, {previous, season}}
  end

  defp do_save_rows(
         %{season: season, delay_ms: delay_ms, previous: previous, page_to_fetch: page} = opts
       ) do
    Process.sleep(delay_ms)

    with {:ok, response} <- Api.get_page(season, page),
         {:ok, total_pages} <- Response.total_pages(response) do
      rows = Response.rows(response)

      new_opts =
        Map.merge(opts, %{
          previous: rows ++ previous,
          total_pages: total_pages,
          page_to_fetch: 1 + page
        })

      Task.start(fn ->
        handle_rows(rows, season)
      end)

      do_save_rows(new_opts)
    else
      _ ->
        Logger.warn("Couldn't get #{page} page for #{inspect(season)}")
        {:error, "Could not fetch page #{page}", {previous, season}}
    end
  end

  def fetch_pages(season, num_entries \\ nil) do
    case Api.get_page(season) do
      {:ok, response = %{leaderboard: %{pagination: %{total_pages: total_pages}}}} ->
        pages = ceil(min(total_pages * @page_size, num_entries) / @page_size)

        extra_pages = fetch_extra_pages(response.season, pages)

        all =
          [response | extra_pages]
          |> Enum.flat_map(&Response.rows/1)

        {:ok, all, response.season}

      _ ->
        Logger.warn("Couldn't get first page for #{inspect(season)}")
        :error
    end
  end

  defp fetch_extra_pages(season, pages) when pages > 1 do
    Enum.map(2..pages, fn page ->
      Task.async(fn ->
        with {:ok, response} <- Api.get_page(season, page) do
          response
        end
      end)
    end)
    |> Task.await_many(:infinity)
  end

  defp fetch_extra_pages(_, _), do: []

  def handle_page(season, page, repetitions) when repetitions > 5,
    do: handle_page(season, page + 1, 0)

  def handle_page(season, page, repetitions) do
    task = Task.async(fn -> Api.get_page(season, page) end)

    case Task.await(task, :infinity) do
      {:ok, response} ->
        handle_response(response)
        continue?(response) && handle_page(season, page + 1, 0)

      _ ->
        handle_page(season, page, repetitions + 1)
    end
  end

  defp continue?(%{leaderboard: %{rows: [_ | _], pagination: p}}), do: p != nil
  defp continue?(_), do: false

  def handle_rows(rows, season), do: create_entries(rows, season)

  defp handle_response(%{leaderboard: %{rows: rows = [_ | _]}, season: season}),
    do: handle_rows(rows, season)

  defp handle_response(_) do
    nil
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
      entries: l.entries |> Enum.map(&to_attrs/1),
      season_id: l.season_id,
      leaderboard_id: l.leaderboard_id,
      region: l.region,
      upstream_updated_at: l.updated_at
    }
  end

  def to_attrs(struct) when is_struct(struct), do: Map.from_struct(struct)
  def to_attrs(a), do: a

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
          "Error saving #{attrs.season_id} #{attrs.leaderboard_id} #{attrs.region} #{attrs.upstream_updated_at}"
        )

        nil
    end
  end

  defp get_criteria(:latest),
    do: [{"order_by", {:desc, :upstream_updated_at}}, {"limit", 1}, {"updated_at_exists"}]

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

  @spec get_current_player_entries([String.t()], list()) :: categorized_entries
  def get_current_player_entries(players, extra_criteria \\ []) do
    seasons = current_ladder_seasons()

    [
      :latest_in_season,
      :preload_season,
      {"seasons", seasons},
      {"players", players},
      {"order_by", "rank"}
      | extra_criteria
    ]
    |> entries()
    |> Enum.group_by(& &1.season_id)
    |> Enum.map(fn {_, entries = [%{season: %{leaderboard_id: l, region: r}} | _]} ->
      {entries, r, l}
    end)
  end

  def current_ladder_seasons() do
    for region <- Backend.Blizzard.qualifier_regions(),
        ldb <- Backend.Blizzard.leaderboards(),
        into: [] do
      season_id = Blizzard.get_current_ladder_season(ldb)
      %Hearthstone.Leaderboards.Season{season_id: season_id, leaderboard_id: ldb, region: region}
    end
  end

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

  def stats(criteria, timeout \\ nil),
    do: entries(criteria, timeout) |> PlayerStats.create_collection()

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

  @spec entries_player_history(String.t(), list(), nil | atom()) :: [history_entry()]
  def entries_player_history(player, criteria, dedup_by \\ nil) do
    [{"players", [player]} | criteria]
    |> entries_history(dedup_by)
  end

  @spec entries_player_history(integer(), list(), nil | atom()) :: [history_entry()]
  def entries_rank_history(rank, criteria, dedup_by \\ nil) do
    [{"rank", rank} | criteria]
    |> entries_history(dedup_by)
  end

  @spec entries_player_history(integer(), list(), nil | atom()) :: [history_entry()]
  def entries_history(criteria, dedup_by \\ nil) do
    base_entries_query()
    |> build_entries_query(criteria)
    |> entries_history_previous()
    |> dedup_history(dedup_by)
    |> Repo.all()
  end

  defp entries_history_previous(query) do
    from e in subquery(query),
      windows: [w: [order_by: e.inserted_at]],
      select: %{
        rank: e.rank,
        rating: e.rating,
        upstream_updated_at: e.inserted_at,
        account_id: e.account_id,
        prev_rating: lag(e.rating) |> over(:w),
        prev_rank: lag(e.rank) |> over(:w)
      }
  end

  @spec player_history(String.t(), list(), nil | atom()) :: [history_entry()]
  def player_history(player, criteria, dedup_by \\ nil) do
    new_criteria = [{"players", [player]} | criteria]

    base_player_history_query(player)
    |> build_snapshot_query(new_criteria)
    |> add_player_history_previous()
    |> dedup_history(dedup_by)
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

  defp dedup_history(query, nil), do: query

  defp dedup_history(query, dedup_by) do
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
        snapshot_id: s.id
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

  defp compose_snapshot_query({"season_id", season = "lobby_legends_" <> _}, query) do
    case LobbyLegendsSeason.get(season) do
      %{ladder: %{ap: ap_end, eu: eu_end, us: us_end, season_id: season_id}} ->
        new_query =
          query
          |> where(
            [s],
            (s.region == "AP" and s.upstream_updated_at <= ^ap_end) or
              (s.region == "EU" and s.upstream_updated_at <= ^eu_end) or
              (s.region == "US" and s.upstream_updated_at <= ^us_end)
          )

        compose_snapshot_query({"season_id", season_id}, new_query)

      _ ->
        query
    end
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
    defp compose_snapshot_query(
           {"period", <<"past_"::binary, unquote(unit)::binary, "s_"::binary, raw::bitstring>>},
           query
         ),
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

  def entries(criteria, timeout \\ nil) do
    {q, new_criteria} = base_entries_query(criteria)

    query =
      q
      |> build_entries_query(new_criteria)
      |> preload_entries(new_criteria)

    if timeout do
      Repo.all(query, timeout: timeout)
    else
      Repo.all(query)
    end
  end

  defp preload_entries(query, criteria) do
    [{:preload_season, &preload_entries_season/1}]
    |> Enum.reduce(query, fn {crit, func}, q ->
      if Enum.any?(criteria, &(&1 == crit)) do
        func.(q)
      else
        q
      end
    end)
  end

  defp preload_entries_season(query) do
    query
    |> add_season_join()
    |> preload([entry: e, season: s], season: s)
  end

  defp base_current_entries_query() do
    from e in {"leaderboards_current_entries", Entry},
      as: :entry
  end

  defp base_entries_query() do
    from e in Entry,
      as: :entry
  end

  defp add_season_join(query) do
    if has_named_binding?(query, :season) do
      query
    else
      join_season(query)
    end
  end

  defp join_season(query),
    do: query |> join(:inner, [entry: e], s in Season, on: s.id == e.season_id, as: :season)

  defp build_entries_query(query, criteria),
    do: Enum.reduce(criteria, query, &compose_entries_query/2)

  defp compose_entries_query({season_shorthand, season_id}, query)
       when season_shorthand in ["s", "ssn"],
       do: compose_entries_query({"season_id", season_id}, query)

  defp compose_entries_query({region_shorthand, region}, query)
       when region_shorthand in ["r", "rgn"],
       do: compose_entries_query({"region", region}, query)

  defp compose_entries_query({ldb_shorthand, leaderboard_id}, query)
       when ldb_shorthand in ["l", "ldb", "ldb_id"],
       do: compose_entries_query({"leaderboard_id", leaderboard_id}, query)

  defp compose_entries_query({"season", %{id: id}}, query) when is_integer(id) do
    query
    |> where([entry: e], e.season_id == ^id)
  end

  defp compose_entries_query({"season", s = %{season_id: nil}}, query) do
    case get_season(s) do
      {:ok, season = %{id: id}} when is_integer(id) ->
        compose_entries_query({"season", season}, query)

      {:ok, season} ->
        do_season_criteria(query, season)
    end
  end

  defp compose_entries_query({"season", season}, query), do: do_season_criteria(query, season)

  defp compose_entries_query({"seasons", seasons = [%{} | _]}, query) do
    ids =
      Enum.flat_map(seasons, fn s ->
        case get_season(s) do
          {:ok, %{id: id}} when is_integer(id) -> [id]
          _ -> []
        end
      end)

    query
    |> where([entry: e], e.season_id in ^ids)
  end

  defp compose_entries_query({"seasons", _seasons = []}, query), do: query |> where(1 == 2)

  defp compose_entries_query({"season_id", season = "lobby_legends_" <> _}, query) do
    case LobbyLegendsSeason.get(season) do
      %{ladder: %{ap: ap_end, eu: eu_end, us: us_end, season_id: season_id}} ->
        new_query =
          query
          |> add_season_join()
          |> where(
            [entry: e, season: s],
            (s.region == "AP" and e.inserted_at <= ^ap_end) or
              (s.region == "EU" and e.inserted_at <= ^eu_end) or
              (s.region == "US" and e.inserted_at <= ^us_end)
          )

        compose_entries_query({"season_id", season_id}, new_query)

      _ ->
        query
    end
  end

  defp compose_entries_query({"season_id", ids}, query) when is_list(ids) do
    query
    |> add_season_join()
    |> where([season: s], s.season_id in ^ids)
  end

  defp compose_entries_query({"season_id", id}, query) do
    query
    |> add_season_join()
    |> where([season: s], s.season_id == ^id)
  end

  defp compose_entries_query({"leaderboard_id", ids}, query) when is_list(ids) do
    query
    |> add_season_join()
    |> where([season: s], s.leaderboard_id in ^ids)
  end

  defp compose_entries_query({"leaderboard_id", id}, query) do
    query
    |> add_season_join()
    |> where([season: s], s.leaderboard_id == ^to_string(id))
  end

  defp compose_entries_query({"region", regions}, query) when is_list(regions) do
    query
    |> add_season_join()
    |> where([season: s], s.region in ^regions)
  end

  defp compose_entries_query({"region", region}, query) do
    query
    |> add_season_join()
    |> where([season: s], s.region == ^to_string(region))
  end

  defp compose_entries_query({"min_rank", rank}, query) do
    query
    |> add_season_join()
    |> where([entry: s], s.rank >= ^Util.to_int_or_orig(rank))
  end

  defp compose_entries_query({"max_rank", rank}, query) do
    query
    |> add_season_join()
    |> where([entry: s], s.rank <= ^Util.to_int_or_orig(rank))
  end

  defp compose_entries_query({"min_rating", rank}, query) do
    query
    |> add_season_join()
    |> where([entry: s], s.rating >= ^Util.to_int_or_orig(rank))
  end

  defp compose_entries_query({"conditional_min_rating", rank}, query) do
    query
    |> add_season_join()
    |> where([entry: e], is_nil(e.rating) or e.rating >= ^Util.to_int_or_orig(rank))
  end

  defp compose_entries_query({"max_rating", rank}, query) do
    query
    |> add_season_join()
    |> where([entry: s], s.rating <= ^Util.to_int_or_orig(rank))
  end

  defp compose_entries_query({"conditional_max_rating", rank}, query) do
    query
    |> add_season_join()
    |> where([entry: s], is_nil(s.rating) or s.rating <= ^Util.to_int_or_orig(rank))
  end

  defp compose_entries_query({"order_by", {direction, field}}, query) do
    query
    |> order_by([{^direction, ^field}])
  end

  defp compose_entries_query({"order_by", "rank"}, query),
    do: compose_entries_query({"order_by", {:asc, :rank}}, query)

  defp compose_entries_query({"order_by", "inserted_at"}, query),
    do: compose_entries_query({"order_by", {:desc, :inserted_at}}, query)

  defp compose_entries_query({"limit", limit}, query) do
    query
    |> limit(^limit)
  end

  defp compose_entries_query({"offset", offset}, query) do
    query
    |> offset(^offset)
  end

  defp compose_entries_query({"after", date = %NaiveDateTime{}}, query) do
    query
    |> where([entry: e], e.inserted_at > ^date)
  end

  defp compose_entries_query({"up_to", date = %NaiveDateTime{}}, query) do
    query
    |> where([entry: e], e.inserted_at < ^date)
  end

  defp compose_entries_query({"search", search}, query) do
    s = "%#{search}%"

    query
    |> where([entry: e], ilike(e.account_id, ^s))
  end

  defp compose_entries_query({"until", {string_num, unit}}, query) when is_binary(string_num) do
    string_num
    |> Integer.parse()
    |> case do
      {num, _} -> compose_entries_query({"until", {num, unit}}, query)
      :error -> raise "Invalid until, can't parse string_num"
    end
  end

  defp compose_entries_query({"until", {num, unit}}, query) do
    query
    |> where([entry: e], e.inserted_at < ago(^num, ^unit))
  end

  defp compose_entries_query({"use_freshest_data", _}, query), do: query

  defp compose_entries_query({:not_current_season, leaderboards}, query) do
    leaderboards
    |> Enum.reduce(query, fn ldb, q ->
      season_id = Blizzard.get_current_ladder_season(ldb)

      q
      |> add_season_join()
      |> where([season: s], not (s.season_id == ^season_id and s.leaderboard_id == ^ldb))
    end)
  end

  for unit <- ["minute", "day", "hour", "week", "month", "year"] do
    defp compose_entries_query(
           {"period", <<"past_"::binary, unquote(unit)::binary, "s_"::binary, raw::bitstring>>},
           query
         ),
         do: entries_past_period(query, raw, unquote(unit))
  end

  defp compose_entries_query({"period", <<"season_"::binary, season_id::bitstring>>}, query),
    do: compose_entries_query({"season_id", season_id}, query)

  defp compose_entries_query({"battletag_full", battletag_full}, query) do
    players = Backend.PlayerInfo.leaderboard_names(battletag_full)
    compose_entries_query({"players", players}, query)
  end

  defp compose_entries_query({"players", players}, query) do
    query
    |> where([entry: e], e.account_id in ^players)
  end

  defp compose_entries_query({"rank", rank}, query) do
    query
    |> where([entry: e], e.rank == ^rank)
  end

  defp compose_entries_query(:preload_season, query), do: query

  defp compose_entries_query(:latest_in_season, query), do: query

  defp do_season_criteria(query, season) do
    criteria = season_criteria(season)
    build_entries_query(query, criteria)
  end

  def season_criteria(%{season_id: s, leaderboard_id: l, region: r}) do
    [
      {"season_id", s},
      {"region", r},
      {"leaderboard_id", l}
    ]
  end

  defp needs_regular_base?({criteria, _value}),
    do: to_string(criteria) in ["up_to", "after", "until"]

  defp needs_regular_base?(_), do: false

  defp base_entries_query(criteria) do
    latest = Enum.any?(criteria, &(&1 == :latest_in_season))
    regular = Enum.any?(criteria, &needs_regular_base?/1)

    cond do
      latest && regular -> latest_via_regular_base(criteria)
      latest -> {base_current_entries_query(), criteria}
      true -> {base_entries_query(), criteria}
    end
  end

  defp latest_via_regular_base(criteria) do
    new_criteria = filter_not_latest_in_season(criteria)
    remaining_criteria = remove_filtered_in_latest(criteria)

    subquery =
      base_entries_query()
      |> build_entries_query(new_criteria)
      |> group_by([entry: e], [e.rank, e.season_id])
      |> select([entry: e], %{
        rank: e.rank,
        season_id: e.season_id,
        inserted_at: max(e.inserted_at)
      })

    {
      base_entries_query()
      |> join(
        :inner,
        [entry: e],
        sub in subquery(subquery),
        on:
          e.season_id == sub.season_id and
            e.rank == sub.rank and
            e.inserted_at == sub.inserted_at
      ),
      remaining_criteria
    }
  end

  defp remove_filtered_in_latest(criteria) do
    Enum.reject(criteria, fn
      {crit, _}
      when crit in [
             "min_rank",
             "max_rank",
             "seasons",
             "season_id",
             "season",
             "s",
             "ssn",
             "r",
             "rgn",
             "region",
             "l",
             "ldb",
             "ldb_id",
             "leaderboard_id"
           ] ->
        true

      _ ->
        false
    end)
  end

  defp filter_not_latest_in_season(criteria) do
    Enum.filter(criteria, fn
      {"search", _} -> false
      {"players", _} -> false
      {"battletag_full", _} -> false
      {"offset", _} -> false
      {"limit", _} -> false
      {"conditional_min_rating", _} -> false
      {"conditional_max_rating", _} -> false
      {"min_rating", _} -> false
      {"max_rating", _} -> false
      _ -> true
    end)
  end

  defp entries_past_period(query, raw, unit) do
    {val, _} = Integer.parse(raw)

    query
    |> where([entry: e], e.inserted_at > ago(^val, ^unit))
  end

  defp past_period(query, raw, unit) do
    {val, _} = Integer.parse(raw)

    query
    |> where([s], s.upstream_updated_at > ago(^val, ^unit))
  end

  def finishes_for_battletag(battletag_full, extra_criteria \\ []),
    do:
      [:latest_in_season, :preload_season, {"battletag_full", battletag_full} | extra_criteria]
      |> entries()

  @spec player_history(String.t(), String.t(), integer() | String.t(), String.t(), List.t()) :: [
          history_entry()
        ]
  def player_history(
        player,
        region,
        period,
        leaderboard_id,
        changed_attr \\ :rank,
        additional_criteria \\ []
      ) do
    criteria = [
      {"period", period},
      {"region", region},
      {"leaderboard_id", leaderboard_id} | additional_criteria
    ]

    entries_player_history(player, criteria, changed_attr)
    # |> dedup_player_histories(changed_attr)
  end

  def rank_history(rank, region, period, leaderboard_id, additional_criteria \\ []) do
    criteria = [
      {"period", period},
      {"region", region},
      {"leaderboard_id", leaderboard_id} | additional_criteria
    ]

    entries_rank_history(rank, criteria, nil)
  end

  @spec dedup_player_histories([history_entry()], atom()) :: [history_entry()]
  def dedup_player_histories(histories, changed_attr) do
    histories
    |> Enum.sort_by(& &1.upstream_updated_at, &(NaiveDateTime.compare(&1, &2) == :lt))
    |> Enum.dedup_by(&Map.get(&1, changed_attr))
  end

  @conflict_options [
    on_conflict: {:replace_all_except, [:inserted_at, :id]},
    stale_error_field: :stale,
    conflict_target: [:season_id, :rank]
  ]
  def create_entries(r, %Season{id: id}) do
    r
    |> prepare_rows(id)
    |> Enum.chunk_every(1000)
    |> Enum.each(&insert_prepared_entries/1)
  end

  def create_entries(rows, s) do
    with {:ok, season = %{id: _id}} <- get_season(s) do
      create_entries(rows, season)
    end
  end

  defp insert_prepared_entries(vals) do
    Repo.insert_all(
      Entry.current(),
      vals,
      @conflict_options
    )
  end

  defp prepare_rows(rows, id) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    for row <- rows, {:ok, data} <- [row_to_value(row, id, now)], do: data
  end

  defp row_to_value(row, season_id, inserted_at) do
    attrs = row |> to_attrs() |> Map.put(:season_id, season_id)

    with {:ok, data} <- %Entry{} |> Entry.changeset(attrs) |> Ecto.Changeset.apply_action(:insert) do
      {:ok,
       Map.from_struct(data)
       |> Map.drop([:__meta__, :season, :id])
       |> Map.put(:inserted_at, inserted_at)}
    end
  end

  def season(db_id) do
    Repo.get(Season, db_id)
  end

  def all_seasons() do
    Repo.all(Season)
  end

  defp ensure_season_full(season),
    do:
      season
      |> ApiSeason.ensure_region()
      |> ApiSeason.ensure_leaderboard_id()
      |> Map.put_new(:season_id, nil)

  def get_season(%Season{id: id} = season) when is_integer(id), do: {:ok, season}

  def get_season(%{season_id: nil} = base) do
    %{leaderboard_id: leaderboard_id, region: region} = ensure_season_full(base)

    query =
      from s in Season,
        where: s.leaderboard_id == ^to_string(leaderboard_id),
        where: s.region == ^to_string(region),
        order_by: [desc: s.season_id],
        limit: 1

    {:ok, Repo.one(query)}
  end

  def get_season(%{season_id: season_id, leaderboard_id: leaderboard_id, region: region} = season)
      when is_integer(season_id) do
    query =
      from s in Season,
        where: s.season_id == ^season_id,
        where: s.leaderboard_id == ^to_string(leaderboard_id),
        where: s.region == ^to_string(region)

    case Repo.one(query) do
      nil when not is_nil(leaderboard_id) and not is_nil(region) -> create_season(season)
      nil -> {:error, :no_season}
      result -> {:ok, result}
    end

    {:ok, Repo.one(query)}
  end

  def get_season(season), do: {:ok, ensure_season_full(season)}

  def create_season(season = %Season{id: _}), do: season

  def create_season(season) do
    %Season{}
    |> Season.changeset(to_attrs(season))
    |> Repo.insert()
  end

  def convert_snapshots(snapshots) do
    Enum.reduce(snapshots, Multi.new(), &snapshot_conversion/2)
    |> Repo.transaction()
  end

  def snapshot_conversion(snapshot, multi) do
    with {:ok, season = %{id: id}} <-
           get_season(%{
             season_id: snapshot.season_id,
             leaderboard_id: snapshot.leaderboard_id,
             region: snapshot.region
           }) do
      Enum.reduce(snapshot.entries, multi, fn e, m ->
        attrs =
          e
          |> to_attrs()
          |> Map.put(:season_id, id)
          |> Map.put(:inserted_at, snapshot.upstream_updated_at)

        cs = %Entry{} |> Entry.changeset(attrs)
        Multi.insert(m, "#{Season.uniq_string(season)}_#{e.rank}_#{e.account_id}", cs)
      end)
    end
  end

  @alter_ratings_ldbs ["STD", :STD, "CLS", :CLS, "WLD", :WLD]
  @preserve_ratings [:arena, "arena"]

  @spec rating_display(nil | number, any) :: nil | integer
  def rating_display(nil, _ldb), do: nil

  def rating_display(rating, ldb) when ldb in @preserve_ratings, do: rating

  def rating_display(rating, ldb) when ldb in @alter_ratings_ldbs do
    trunc_rating(1000 * rating)
  end

  def rating_display(rating, _), do: trunc_rating(rating)

  def trunc_rating(rating), do: (1.0 * rating) |> Float.round(0) |> trunc()

  def refresh_latest() do
    # Repo.query!(
    #   "
    # DO $$
    # DECLARE cnt int;
    # declare r record;
    # begin
    #   SELECT count(1) INTO cnt FROM pg_stat_activity WHERE query LIKE '%REFRESH MATERIALIZED VIEW CONCURRENTLY leaderboards_entry_latest%' and pid != pg_backend_pid();
    #   IF cnt < 1 then
    #     REFRESH MATERIALIZED VIEW CONCURRENTLY leaderboards_entry_latest WITH DATA ;
    #   END IF;
    # END $$;
    # ",
    #   [],
    #   timeout: 666_000
    # )
  end

  def prune(%Season{id: id}) when is_integer(id) do
    Repo.query!(
      "DELETE FROM public.leaderboards_entry WHERE season_id = ? AND id NOT IN (SELECT le.id FROM public.leaderboards_entry le INNER JOIN (SELECT i.rank as r, MAX(i.inserted_at) as ia FROM public.leaderboards_entry i WHERE i.season_id = ? GROUP BY i.rank) AS inn ON inn.r = rank AND inn.ia = inserted_at WHERE season_id = ?);",
      [id, id, id],
      timeout: 120_000
    )
  end

  def prune_old_query(curr_constructed, curr_mercs, curr_bgs, curr_arena) do
    """
    do $$
      declare arrow record;
      begin
        for arrow in (SELECT id FROM public.leaderboards_seasons WHERE (leaderboard_id = 'arena' AND season_id < #{curr_arena}) OR (leaderboard_id = 'MRC' AND season_id < #{curr_mercs}) OR (leaderboard_id in ('CLS', 'WLD', 'STD') AND season_id < #{curr_constructed}) OR (leaderboard_id = 'BG' AND season_id < #{curr_bgs}) OR (leaderboard_id = 'DUO' and seson_id < #{curr_bgs})) loop
          DELETE FROM public.leaderboards_entry WHERE season_id = arrow.id AND id NOT IN (SELECT le.id FROM public.leaderboards_entry le INNER JOIN (SELECT i.rank as r, MAX(i.inserted_at) as ia FROM public.leaderboards_entry i WHERE i.season_id = arrow.id GROUP BY i.rank) AS inn ON inn.r = rank AND inn.ia = inserted_at WHERE season_id = arrow.id);
        end loop;
      end; $$
      ;
    """
  end

  def prune_old(curr_constructed, curr_mercs, curr_bgs, curr_arena) do
    Repo.query!(
      prune_old_query(curr_constructed, curr_mercs, curr_bgs, curr_arena),
      [],
      timeout: 666_000
    )
  end

  @doc """
  Copy entries from bgs to bg lobby legends
  """
  def copy_to_bg_lobby_legends(date, bg_season_id \\ nil)

  def copy_to_bg_lobby_legends(year, month) when is_integer(year) and is_integer(month) do
    with {:ok, date} <- Date.new(year, month, 1) do
      copy_to_bg_lobby_legends(date)
    end
  end

  def copy_to_bg_lobby_legends(date = %Date{}, bg_season_id) do
    for {r, timezone} <- regions_with_timezone() do
      up_to =
        DateTime.new!(date, ~T[00:00:00], timezone)
        |> Timex.beginning_of_month()
        |> Timex.shift(months: 1)
        # small buffer
        |> Timex.shift(minutes: 2)
        |> Timex.Timezone.convert("UTC")
        |> DateTime.to_naive()

      criteria = [
        {"season", %ApiSeason{leaderboard_id: "BG", region: r, season_id: bg_season_id}},
        {"max_rank", 200},
        {"order_by", "rank"},
        {"up_to", up_to},
        :latest_in_season
      ]

      entries =
        entries(criteria, 600_000)
        |> Enum.sort_by(& &1.rank, :desc)
        |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
        |> Enum.uniq_by(&{&1.rank, &1.account_id, &1.rating})

      season_id = Blizzard.get_season_id(date)

      create_entries(entries, %ApiSeason{
        season_id: season_id,
        region: to_string(r),
        leaderboard_id: "BG_LL"
      })
    end
  end

  def prune_empty_seasons() do
    Repo.query!(
      "DELETE FROM public.leaderboards_seasons WHERE id NOT IN (SELECT DISTINCT(season_id) FROM public.leaderboards_entry) AND inserted_at < now() - INTERVAL '2 min';",
      [],
      timeout: 69_666_000
    )
  end

  def copy_last_month_to_lobby_legends() do
    Date.utc_today() |> Timex.shift(months: -1) |> copy_to_bg_lobby_legends()
  end

  @spec regions_with_timezone :: [{:AP, <<_::80>>} | {:EU, <<_::24>>} | {:US, <<_::80>>}, ...]
  def regions_with_timezone(), do: [{:US, "US/Pacific"}, {:AP, "Asia/Seoul"}, {:EU, "CET"}]
end
