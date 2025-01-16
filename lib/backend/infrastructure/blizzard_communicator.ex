defmodule Backend.Infrastructure.BlizzardCommunicator do
  @moduledoc false
  require Logger
  alias Backend.Blizzard.Leaderboard
  alias Backend.Hearthstone.Deck

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
  def reveal_schedule(mode \\ :constructed)

  def reveal_schedule(mode) do
    with {:ok, url} <- reveal_url(mode),
         {:ok, %{body: body}} <- HTTPoison.get(url) do
      parse_reveal_schedule(body, mode)
    end
  end

  def reveal_url(:constructed), do: {:ok, "https://hearthstone.blizzard.com/en-us/cards"}
  def reveal_url(:bgs), do: {:ok, "https://hearthstone.blizzard.com/en-us/battlegrounds"}
  def reveal_url(_), do: {:error, :unsupported_mode_for_reveal_url}

  defp mount_id(:constructed), do: {:ok, "#cardGalleryMount"}
  defp mount_id(:bgs), do: {:ok, "#battlegroundsMount"}
  defp mount_id(_), do: {:error, :unsupported_mode_for_mount_id}

  def parse_reveal_schedule(body, mode \\ :constructed) do
    with {:ok, html} <- Floki.parse_document(body),
         {:ok, mount_id} <- mount_id(mode),
         [hype] <- Floki.find(html, mount_id) |> Floki.attribute("hypemachine"),
         {:ok, %{"cards" => cards}} <- Jason.decode(hype) do
      for %{"hype_url" => url, "image_url" => image_url, "reveal_time" => time_raw, "id" => id} <-
            cards,
          {result, time} = NaiveDateTime.from_iso8601(time_raw),
          result == :ok do
        %{
          url: url,
          id: id,
          class: extract_class(image_url),
          image_url: image_url,
          reveal_time: time
        }
      end
    else
      _ -> {:error, "Could not parse reveal schedule"}
    end
  end

  def extract_class(image_url) do
    class = Deck.extract_class(image_url)

    if class == "UNKNOWN" do
      nil
    else
      Deck.class_name(class)
    end
  end
end
