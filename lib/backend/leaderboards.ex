defmodule Backend.Leaderboards do
  @moduledoc """
  The Leaderboards context.
  """

  import Ecto.Query, warn: false

  @last_leaderboard_key "last_leaderboard"

  defp get_latest_cached_leaderboard() do
    case Backend.ApiCache.get(@last_leaderboard_key) do
      nil -> {[], nil}
      lb -> lb
    end
  end
  defp save_latest_cached_leaderboard(to_save) do
    Backend.ApiCache.set(@last_leaderboard_key, to_save)
    to_save
  end

  defp process_current_entries(raw_snapshot = %{"leaderboard" => %{"metadata" => _}}) do
    updated_at = get_updated_at(raw_snapshot)
    {cached_leaderboard, cached_updated_at} = get_latest_cached_leaderboard()
    if is_nil(cached_updated_at) || DateTime.diff(updated_at, cached_updated_at) do
      entries = Enum.map(raw_snapshot["leaderboard"]["rows"], fn row ->
        %{
          battletag: row["accountid"],
          position: row["rank"],
          rating: row["rating"]
        }
      end)
      save_latest_cached_leaderboard({entries, updated_at})
    else
      {cached_leaderboard, cached_updated_at}
    end
  end

  defp process_current_entries(_raw_snapshot) do
    get_latest_cached_leaderboard()
  end

  defp get_updated_at(%{"leaderboard" => %{"metadata" => metadata}}) do
    metadata["last_updated_time"]
    |> String.split(" ")
    |> Enum.take(2)
    |> Enum.join(" ")
    |> Kernel.<>("+00:00")
    |> DateTime.from_iso8601()
    |> case do
      {:ok, time, _} -> time
      {:error, _} -> nil
    end
  end

  def fetch_current_entries(region, leaderboard_id, season_id) do
    case HTTPoison.get(
           "https://playhearthstone.com/en-us/api/community/leaderboardsData?region=#{region}&leaderboardId=#{
             leaderboard_id
           }&seasonId=#{season_id}"
         ) do
      {:error, _} ->
        get_latest_cached_leaderboard()

      {:ok, %{body: body}} ->
        body
        |> Poison.decode!()
        |> process_current_entries
    end
  end

  def fetch_current_entries(region, leaderboard_id) do
    response =
      HTTPoison.get!(
        "https://playhearthstone.com/en-us/api/community/leaderboardsData?region=#{region}&leaderboardId=#{
          leaderboard_id
        }"
      )

    raw_snapshot = Poison.decode!(response.body)
    process_current_entries(raw_snapshot)
  end

end
