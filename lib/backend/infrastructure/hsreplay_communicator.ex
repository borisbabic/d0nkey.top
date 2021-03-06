defmodule Backend.Infrastructure.HSReplayCommunicator do
  @moduledoc false
  require Logger
  import Backend.Infrastructure.CommunicatorUtil
  alias Backend.HSReplay.ReplayFeedEntry
  alias Backend.HSReplay.Archetype
  alias Backend.HSReplay.Streaming
  @behaviour Backend.HSReplay.Communicator
  def get_replay_feed() do
    get_body("https://hsreplay.net/api/v1/live/replay_feed/")
    |> Poison.decode!()
    |> Access.get("data")
    |> Enum.map(&ReplayFeedEntry.from_raw_map/1)
  end

  def get_archetypes() do
    get_body("https://hsreplay.net/api/v1/archetypes/")
    |> Poison.decode!()
    |> Enum.map(&Archetype.from_raw_map/1)
  end

  def get_archetype_matchups() do
    url =
      "https://hsreplay.net/analytics/query/head_to_head_archetype_matchups/?GameType=RANKED_STANDARD&RankRange=LEGEND_THROUGH_TWENTY&Region=ALL&TimeRange=LAST_7_DAYS"

    get_body(url)
    |> Poison.decode!()
    |> Backend.HSReplay.ArchetypeMatchups.from_raw_map()
  end

  def get_archetype_matchups(cookies) when is_nil(cookies) do
    get_archetype_matchups()
  end

  def get_archetype_matchups(cookies) do
    url =
      "https://hsreplay.net/analytics/query/head_to_head_archetype_matchups/?GameType=RANKED_STANDARD&RankRange=LEGEND_THROUGH_FIVE&Region=ALL&TimeRange=LAST_7_DAYS"

    {u_secs, response} =
      :timer.tc(&HTTPoison.get!/1, [URI.encode(url), %{}, hackney: [cookie: [cookies]]])

    Logger.info("Got #{url} in #{div(u_secs, 1000)} ms")

    response.body
    |> Poison.decode!()
    |> Backend.HSReplay.ArchetypeMatchups.from_raw_map()
  end

  @spec get_streaming_now() :: [Streaming.t()]
  def get_streaming_now() do
    url = "https://hsreplay.net/api/v1/live/streaming-now/"

    url
    |> get_body()
    |> Poison.decode()
    |> case do
      {:ok, decoded} -> decoded |> Enum.map(&Streaming.from_raw_map/1)
      _ -> []
    end
  end
end
