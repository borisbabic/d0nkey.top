defmodule Backend.Leaderboards do
  require Logger

  @moduledoc """
  The Leaderboards context.
  """
  alias Backend.Infrastructure.ApiCache
  alias Backend.Infrastructure.BlizzardCommunicator

  defp get_latest_cached_leaderboard(cache_key) do
    case ApiCache.get(cache_key) do
      nil -> {[], nil}
      lb -> lb
    end
  end

  defp save_latest_cached_leaderboard(to_save, cache_key) do
    ApiCache.set(cache_key, to_save)
    to_save
  end

  def create_cache_key(region_id, leaderboard_id, season_id) do
    "last_leaderboard_#{region_id}_#{leaderboard_id}_#{season_id}"
  end

  def fetch_current_entries(region, leaderboard_id, season_id \\ nil) do
    cache_key = create_cache_key(region, leaderboard_id, season_id)
    cached = {_table, cached_updated_at} = get_latest_cached_leaderboard(cache_key)

    case BlizzardCommunicator.get_leaderboard(region, leaderboard_id, season_id) do
      {:error, _} ->
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
end
