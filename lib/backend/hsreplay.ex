defmodule Backend.HSReplay do
  alias Backend.Infrastructure.HSReplayCommunicator, as: Api
  alias Backend.Infrastructure.HSReplayLatestCache, as: Cache
  alias Backend.Infrastructure.ApiCache
  @type archetype_id :: integer

  def update_latest() do
    Api.get_replay_feed()
    |> Enum.map(fn rf -> {rf.id, rf} end)
    |> Cache.add_multiple()
  end

  def get_archetype_matchups() do
    Api.get_archetype_matchups()
  end

  def get_archetypes() do
    case get_archetypes(:cache) do
      nil -> get_archetypes(:fresh) |> cache_archetypes()
      cache -> cache
    end
  end

  def get_archetypes(:cache) do
    ApiCache.get(:hsreplay_archetypes)
  end

  def get_archetypes(:fresh) do
    Api.get_archetypes()
  end

  def cache_archetypes(archetypes) do
    ApiCache.set(:hsreplay_archetypes, archetypes)
    archetypes
  end

  def get_latest() do
    Cache.list()
  end

  def get_latest(filters) do
    get_latest()
    |> filter_latest(filters)
  end

  def filter_latest(latest, filters) do
    filter_func = create_filter(filters)
    latest |> Enum.filter(filter_func)
  end

  defp normalize_ranks(rank, legend_rank) do
    case {rank, legend_rank} do
      {nil, l} when not is_nil(l) -> normalize_legend(l)
      {r, nil} when not is_nil(r) -> normalize_regular(r)
      _ -> nil
    end
  end

  def normalize_legend(num) do
    -1 * num
  end

  def normalize_regular(num) do
    -1 * (999_999_999 + num)
  end

  def normalize_ranks(replay_feed_entry) do
    p1rank =
      normalize_ranks(replay_feed_entry.player1_rank, replay_feed_entry.player1_legend_rank)

    p2rank =
      normalize_ranks(replay_feed_entry.player2_rank, replay_feed_entry.player2_legend_rank)

    {p1rank, p2rank}
  end

  def normalize_rank_filter_value(value) do
    case Integer.parse(value) do
      {legend_rank, "L"} -> normalize_legend(legend_rank)
      {rank, ""} -> normalize_regular(rank)
      _ -> nil
    end
  end

  def create_filter_func(name, value) do
    rank_filter_val = normalize_rank_filter_value(value)

    case name do
      "max_rank" when not is_nil(rank_filter_val) ->
        fn re ->
          {p1, p2} = normalize_ranks(re)
          p1 && p1 <= rank_filter_val && (p2 && p2 <= rank_filter_val)
        end

      "max_rank_any" when not is_nil(rank_filter_val) ->
        fn re ->
          {p1, p2} = normalize_ranks(re)
          (p1 && p1 <= rank_filter_val) || (p2 && p2 <= rank_filter_val)
        end

      "min_rank" when not is_nil(rank_filter_val) ->
        fn re ->
          {p1, p2} = normalize_ranks(re)
          p1 && p1 >= rank_filter_val && (p2 && p2 >= rank_filter_val)
        end

      "min_rank_any" when not is_nil(rank_filter_val) ->
        fn re ->
          {p1, p2} = normalize_ranks(re)
          (p1 && p1 >= rank_filter_val) || (p2 && p2 >= rank_filter_val)
        end

      _ ->
        nil
    end
  end

  def create_filter(filter_values) do
    filter_funcs =
      filter_values
      |> Enum.flat_map(fn {key, value} ->
        case create_filter_func(to_string(key), value) do
          nil -> []
          func -> [func]
        end
      end)

    fn a -> filter_funcs |> Enum.reduce(true, fn ff, acc -> ff.(a) && acc end) end
  end

  @spec create_replay_link(String.t()) :: String.t()
  def create_replay_link(match_id) do
    "https://hsreplay.net/replay/#{match_id}"
  end

  @spec create_archetype_link(Archetype.t() | %{url: String.t()} | String.t()) :: String.t()
  def create_archetype_link(%{url: url}) do
    create_archetype_link(url)
  end

  def create_archetype_link(<<url::binary>>) do
    "https://hsreplay.net#{url}"
  end
end
