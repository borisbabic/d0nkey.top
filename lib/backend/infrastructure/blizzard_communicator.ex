defmodule Backend.Infrastructure.BlizzardCommunicator do
  @moduledoc false
  require Logger
  alias Backend.Blizzard.Leaderboard

  @spec get_leaderboard(String.t(), String.t(), String.t()) ::
          {:ok, Leaderboard.t()} | {:error, any()}
  def get_leaderboard(region, leaderboard_id, season_id) do
    url = create_link(region, leaderboard_id, season_id)

    {u_secs, return} = :timer.tc(&HTTPoison.get/1, [url])

    Logger.debug(
      "Got leaderboard #{region} #{leaderboard_id} #{season_id} in #{div(u_secs, 1000)} ms #{url}"
    )

    case return do
      {:ok, %{body: body}} -> body |> Poison.decode!() |> Leaderboard.from_raw_map()
      _ -> {:error, nil}
    end
  end

  def create_link(region, leaderboard_id, nil),
    do:
      "https://hearthstone.blizzard.com/en-us/api/community/leaderboardsData?region=#{region}&leaderboardId=#{leaderboard_id}"

  def create_link(region, leaderboard_id, season_id),
    do: "#{create_link(region, leaderboard_id, nil)}&seasonId=#{season_id}"
end
