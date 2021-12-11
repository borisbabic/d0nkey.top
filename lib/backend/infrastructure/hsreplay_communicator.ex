defmodule Backend.Infrastructure.HSReplayCommunicator do
  @moduledoc false
  require Logger
  import Backend.Infrastructure.CommunicatorUtil
  alias Backend.HSReplay.ReplayFeedEntry
  alias Backend.HSReplay.Archetype
  alias Backend.HSReplay.Streaming
  @behaviour Backend.HSReplay.Communicator

  # def get_streams(mode \\ "standard") do
  #   get_body("https://hsreplay.net/api/v1/streams/" <> mode)
  #   |> Poison.decode!()
  #   |> Enum.map(fn ->
  # end

  # def get_dekc_streams(hsr_deck_id, mode \\ "standard") do
  #   get_body("https://hsreplay.net/api/v1/streams/#{mode}/?deck_id=#{hsr_deck_id}")
  #   |> Poison.decode!()
  #   |> Enum.map(fn ->
  # end

  def get_replay_feed() do
    get_body("https://hsreplay.net/api/v1/live/replay_feed/")
    |> decode(fn decoded ->
      decoded
      |> Access.get("data")
      |> Enum.map(&ReplayFeedEntry.from_raw_map/1)
    end, [])
  end

  def get_archetypes() do
    get_body("https://hsreplay.net/api/v1/archetypes/")
    |> decode(fn decoded ->
      decoded
      |> Enum.map(&Archetype.from_raw_map/1)
    end, [])
  end

  defp decode(body, fun, default \\ nil) do
    case Poison.decode(body) do
      {:ok, decoded} ->
        try do
          fun.(default)
        rescue
          e ->
            Logger.warn("Error decoding hsreplay response", error: e)
            default
        end
      _ -> default
    end
  end

  def get_archetype_matchups() do
    url =
      "https://hsreplay.net/analytics/query/head_to_head_archetype_matchups/?GameType=RANKED_STANDARD&RankRange=LEGEND_THROUGH_TWENTY&Region=ALL&TimeRange=LAST_7_DAYS"

    get_body(url)
    |> decode(fn decoded ->
      decoded
      |> Backend.HSReplay.ArchetypeMatchups.from_raw_map()
    end)
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
    |> decode(fn decoded ->
      decoded
      |> Backend.HSReplay.ArchetypeMatchups.from_raw_map()
    end, [])
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
