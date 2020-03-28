defmodule Backend.Infrastructure.BlizzardCommunicator do
  require Logger

  def get_leaderboard(region, leaderboard_id, season_id) do
    url =
      "https://playhearthstone.com/en-us/api/community/leaderboardsData?region=#{region}&leaderboardId=#{
        leaderboard_id
      }&seasonId=#{season_id}"

    {uSecs, return} = :timer.tc(&HTTPoison.get/1, [url])

    Logger.info(
      "Got leaderboard #{region} #{leaderboard_id} #{season_id} in #{div(uSecs, 1000)} ms"
    )

    case return do
      {:ok, %{body: body}} -> body |> Poison.decode!() |> process_leaderboard
      _ -> {:error, nil}
    end
  end

  defp process_leaderboard(%{"leaderboard" => %{"metadata" => metadata, "rows" => rows}}) do
    leaderboard_table = process_leaderboard_table(rows)
    updated_at = extract_updated_at(metadata)
    {:ok, {leaderboard_table, updated_at}}
  end

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
end
