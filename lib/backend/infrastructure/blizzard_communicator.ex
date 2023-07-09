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

  @type reveal_item :: %{
          url: String.t(),
          id: integer(),
          image_url: String.t(),
          reveal_time: NaiveDateTime.t()
        }
  def reveal_schedule() do
    with {:ok, %{body: body}} <- HTTPoison.get("https://hearthstone.blizzard.com/en-us/cards") do
      parse_reveal_schedule(body)
    end
  end

  def parse_reveal_schedule(body) do
    with {:ok, html} <- Floki.parse_document(body),
         [hype] <- Floki.find(html, "#cardGalleryMount") |> Floki.attribute("hypemachine"),
         {:ok, %{"cards" => cards}} <- Jason.decode(hype) do
      for %{"hype_url" => url, "image_url" => image_url, "reveal_time" => time_raw, "id" => id} <-
            cards,
          {result, time} = NaiveDateTime.from_iso8601(time_raw),
          result == :ok do
        %{
          url: url,
          id: id,
          image_url: image_url,
          reveal_time: time
        }
      end
    else
      _ -> {:error, "Could not parse reveal schedule"}
    end
  end
end
