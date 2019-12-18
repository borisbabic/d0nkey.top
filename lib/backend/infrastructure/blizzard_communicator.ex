defmodule Backend.Infrastructure.BlizzardCommunicator do
  def get_leaderboard(region, leaderboard_id, season_id) do
    case HTTPoison.get(
           "https://playhearthstone.com/en-us/api/community/leaderboardsData?region=#{region}&leaderboardId=#{
             leaderboard_id
           }&seasonId=#{season_id}"
         ) do
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
