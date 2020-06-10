defmodule Backend.EsportsGold do
  @moduledoc false

  alias Backend.Infrastructure.EsportsGoldCommunicator, as: Api
  alias Backend.Infrastructure.ApiCache

  def create_cache_key(battletag_short) do
    "esports_gold_player_details_#{String.downcase(battletag_short)}"
  end

  def save_to_cache(player_details, cache_key) do
    ApiCache.set(cache_key, player_details)
    player_details
  end

  def get_cached_info(battletag_short) do
    battletag_short
    |> create_cache_key()
    |> ApiCache.get()
  end

  def get_player_info(battletag_short) do
    cache_key = create_cache_key(battletag_short)

    case ApiCache.get(cache_key) do
      nil -> Api.get_player_details(battletag_short) |> save_to_cache(cache_key)
      cached -> cached
    end
  end
end
