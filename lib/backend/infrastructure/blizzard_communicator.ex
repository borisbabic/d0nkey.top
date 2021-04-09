defmodule Backend.Infrastructure.BlizzardCommunicator do
  @moduledoc false
  require Logger
  alias Backend.Blizzard.Leaderboard
  alias Backend.Grandmasters.Response

  def get_leaderboard(region, leaderboard_id, season_id) do
    url = create_link(region, leaderboard_id, season_id)

    {u_secs, return} = :timer.tc(&HTTPoison.get/1, [url])

    Logger.info(
      "Got leaderboard #{region} #{leaderboard_id} #{season_id} in #{div(u_secs, 1000)} ms #{url}"
    )

    case return do
      #      {:ok, %{body: body}} -> body |> Poison.decode!() |> process_leaderboard
      {:ok, %{body: body}} -> body |> Poison.decode!() |> Leaderboard.from_raw_map()
      _ -> {:error, nil}
    end
  end

  def create_link(region, leaderboard_id, nil),
    do:
      "https://playhearthstone.com/en-us/api/community/leaderboardsData?region=#{region}&leaderboardId=#{
        leaderboard_id
      }"

  def create_link(region, leaderboard_id, season_id),
    do: "#{create_link(region, leaderboard_id, nil)}&seasonId=#{season_id}"

  defp process_leaderboard(map = %{"leaderboard" => %{"metadata" => metadata, "rows" => rows}}) do
    new = Leaderboard.from_raw_map(map)
    {:ok, {new |> Leaderboard.old_entries(), new.updated_at}}
  end

  #  defp process_leaderboard(map = %{"leaderboard" => %{"metadata" => metadata, "rows" => rows}}) do
  #    leaderboard_table = process_leaderboard_table(rows)
  #    updated_at = extract_updated_at(metadata)
  #    {:ok, {leaderboard_table, updated_at}}
  #  end

  defp process_leaderboard(_raw_snapshot) do
    {:error, nil}
  end

  defp process_leaderboard_table(rows) do
    Enum.map(rows, fn row ->
      %{
        battletag: row["accountid"],
        position: row["rank"],
        rating: row["rating"]
      }
    end)
  end

  defp extract_updated_at(%{"last_updated_time" => last_updated_time}) do
    last_updated_time
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

  defp extract_updated_at(_) do
    nil
  end

  def get_gm() do
    url =
      "https://playhearthstone.com/en-us/api/esports/schedule/grandmasters/?season=null&year=null"

    with {:ok, %{body: body}} <- HTTPoison.get(url, [], timeout: 20_000, recv_timeout: 20_000),
         {:ok, decoded} <- Poison.decode(body) do
      Response.from_raw_map(decoded)
    end
  end
end
