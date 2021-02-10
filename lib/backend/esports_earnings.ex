defmodule Backend.EsportsEarnings do
  @moduledoc false
  alias Backend.Infrastructure.ApiCache
  alias Backend.Repo
  alias Backend.EsportsEarnings.GamePlayerDetails
  alias Backend.Infrastructure.EsportsEarningsCommunicator, as: Api
  import Ecto.Query, warn: false

  def get_game_id(:Hearthstone), do: 328

  def update_game(game_id) when is_integer(game_id) do
    player_details = game_id |> Api.get_all_highest_earnings_for_game()

    case game_player_details(game_id, :fresh) do
      nil -> save_game_details(player_details, game_id)
      existing -> update_game_details(player_details, existing)
    end
  end

  def save_game_details(player_details, game_id) do
    %GamePlayerDetails{}
    |> GamePlayerDetails.changeset(%{
      game_id: game_id,
      player_details: player_details
    })
    |> Repo.insert()
  end

  def update_game_details(player_details, existing) do
    # stupid hack because I'm too lazy to figure out how to do it properly
    delete_cache(existing.game_id)
    save_resp = save_game_details(player_details, existing.game_id)
    delete_cache(existing.game_id)
    Repo.delete(existing)
    save_resp
  end

  def delete_cache(game_id) do
    game_id
    |> create_cache_key()
    |> ApiCache.delete()
  end

  def get_player_country(handle, game \\ :Hearthstone) do
    game_id = game |> get_game_id()
    cache_key = "esports_earnings_#{game}_player_country_#{handle}}"

    with nil <- ApiCache.get(cache_key),
         %{player_details: player_details} <- game_player_details(game_id),
         %{country_code: country_code} <-
           player_details |> Enum.find(fn pd -> pd.handle == handle end) do
      ApiCache.set(cache_key, country_code)
      country_code
    else
      cc -> cc
    end
  end

  def auto_update(), do: update_hearthstone()

  def update_hearthstone(), do: :Hearthstone |> get_game_id() |> update_game()

  def create_cache_key(game_id) do
    "esports_earnings_game_player_details_#{game_id}"
  end

  @spec cache_game_player_details(nil, integer) :: nil
  def cache_game_player_details(nil, _), do: nil
  @spec cache_game_player_details(GamePlayerDetails, integer) :: [GamePlayerDetails]
  def cache_game_player_details(details, game_id) do
    game_id
    |> create_cache_key()
    |> ApiCache.set(details)

    # so we can pipe
    details
  end

  @spec game_player_details(integer) :: GamePlayerDetails.t() | nil
  def game_player_details(game_id) when is_integer(game_id) do
    case game_player_details(game_id, :cache) do
      nil -> game_player_details(game_id, :fresh) |> cache_game_player_details(game_id)
      cached -> cached
    end
  end

  @spec game_player_details(integer, :cache) :: GamePlayerDetails | nil
  def game_player_details(game_id, :cache) when is_integer(game_id) do
    game_id
    |> create_cache_key()
    |> ApiCache.get()
  end

  @spec game_player_details(integer, :fresh) :: GamePlayerDetails | nil
  def game_player_details(game_id, :fresh) when is_integer(game_id) do
    Repo.one(
      from gpd in GamePlayerDetails,
        where: gpd.game_id == ^game_id,
        limit: 1,
        order_by: [desc: gpd.inserted_at],
        select: gpd
    )
  end
end
