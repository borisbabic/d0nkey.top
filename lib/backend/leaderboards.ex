defmodule Backend.Leaderboards do
  require Logger

  @moduledoc """
  The Leaderboards context.
  """
  alias Backend.Infrastructure.ApiCache
  alias Backend.Infrastructure.BlizzardCommunicator
  alias Backend.Blizzard

  @type entry :: %{
          battletag: String.t(),
          position: number,
          rating: number | nil
        }
  @type timestamped_leaderboard :: {[Entry], NaiveDateTime.t()}

  @type categorized_entries :: [{[entry], Blizzard.region(), Blizzard.leaderboard()}]

  @spec get_latest_cached_leaderboard(String.t()) :: timestamped_leaderboard
  defp get_latest_cached_leaderboard(cache_key) do
    case ApiCache.get(cache_key) do
      nil -> {[], nil}
      lb -> lb
    end
  end

  @spec save_latest_cached_leaderboard(timestamped_leaderboard, String.t()) ::
          timestamped_leaderboard
  defp save_latest_cached_leaderboard(to_save, cache_key) do
    ApiCache.set(cache_key, to_save)
    to_save
  end

  @spec fetch_current_entries(Blizzard.region(), Blizzard.leaderboard(), number | nil) ::
          String.t()
  def create_cache_key(region_id, leaderboard_id, season_id) do
    "last_leaderboard_#{region_id}_#{leaderboard_id}_#{season_id}"
  end

  @spec fetch_current_entries(Blizzard.region(), Blizzard.leaderboard(), number | nil) :: [entry]
  def fetch_current_entries(region, leaderboard_id, season_id \\ nil) do
    cache_key = create_cache_key(region, leaderboard_id, season_id)
    cached = {_table, cached_updated_at} = get_latest_cached_leaderboard(cache_key)

    case BlizzardCommunicator.get_leaderboard(region, leaderboard_id, season_id) do
      {:error, _} ->
        cached

      {:ok, {_table, nil}} ->
        Logger.info("Got nil updated at, using cached leaderboard")
        cached

      {:ok, leaderboard = {_table, updated_at}} ->
        if !cached_updated_at || DateTime.diff(updated_at, cached_updated_at) >= 0 do
          Logger.debug(
            "Using blizzard leaderboard, updated_at: #{updated_at}, cached_updated_at: #{
              cached_updated_at
            }"
          )

          save_latest_cached_leaderboard(leaderboard, cache_key)
        else
          Logger.debug(
            "USING CACHED LEADERBOARD! updated_at: #{updated_at}, cached_updated_at: #{
              cached_updated_at
            }"
          )

          cached
        end
    end
  end

  @spec get_player_entries([String.t()]) :: categorized_entries
  def get_player_entries(battletags_short) do
    short_set = MapSet.new(battletags_short)

    for region <- Backend.Blizzard.regions(),
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
    {table, _updated_at} = fetch_current_entries(region, leaderboard_id, season_id)
    table |> Enum.filter(fn e -> MapSet.member?(short_set, e.battletag) end)
  end
end
