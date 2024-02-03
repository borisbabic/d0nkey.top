defmodule Backend.Infrastructure.HSReplayCommunicator do
  @moduledoc false
  require Logger
  import Backend.Infrastructure.CommunicatorUtil
  alias Backend.HSReplay.ReplayFeedEntry
  alias Backend.HSReplay.Archetype
  alias Backend.HSReplay.Streaming
  alias Backend.Hearthstone.Deck

  alias Backend.Infrastructure.ApiCache
  @behaviour Backend.HSReplay.Communicator

  def get_replay_feed() do
    with {:ok, body} <- throttled_body("https://hsreplay.net/api/v1/live/replay_feed/"),
         {:ok, decoded} <- Poison.decode(body) do
      decoded
      |> Access.get("data")
      |> Enum.map(&ReplayFeedEntry.from_raw_map/1)
    else
      _ -> []
    end
  end

  def get_archetypes() do
    with {:ok, body} <- throttled_body("https://hsreplay.net/api/v1/archetypes/"),
         {:ok, decoded} <- Poison.decode(body) do
      Enum.map(decoded, &Archetype.from_raw_map/1)
    else
      _ -> []
    end
  end

  def get_archetype_matchups(_cookied \\ nil) do
    url =
      "https://hsreplay.net/analytics/query/head_to_head_archetype_matchups/?GameType=RANKED_STANDARD&RankRange=LEGEND_THROUGH_TWENTY&Region=ALL&TimeRange=LAST_7_DAYS"

    with {:ok, body} <- throttled_body(url),
         {:ok, decoded} <- Poison.decode(body) do
      Backend.HSReplay.ArchetypeMatchups.from_raw_map(decoded)
    else
      _ -> []
    end
  end

  @spec get_streaming_now() :: [Streaming.t()]
  def get_streaming_now() do
    url = "https://hsreplay.net/api/v1/live/streaming-now/"

    with {:ok, body} <- throttled_body(url),
         {:ok, decoded} <- Poison.decode(body) do
      decoded |> Enum.map(&Streaming.from_raw_map/1)
    else
      _ -> []
    end
  end

  def get_live_decks(mode) do
    url = "https://hsreplay.net/api/v1/streams/#{mode}/"

    with {:ok, body} <- throttled_body(url),
         {:ok, decoded} <- Poison.decode(body) do
      live_decks =
        decoded
        |> Enum.map(& &1["deck_id"])
        |> Enum.filter(& &1)

      {:ok, live_decks}
    end
  end

  def get_deck_streams(mode, hsr_deck_id) do
    url = "https://hsreplay.net/api/v1/streams/#{mode}/?deck_id=#{hsr_deck_id}"

    with {:ok, body} <- throttled_body(url) do
      Poison.decode(body)
    end
  end

  def get_deck(hsr_deck_id) do
    url = "https://hsreplay.net/decks/#{hsr_deck_id}/"

    with {:ok, body} <- throttled_body(url) do
      extract_deck(body)
    end
  end

  @spec extract_deck(String.t()) :: {:ok, Deck.t()} | {:error}
  def extract_deck(body) do
    with [deck_info] <- Floki.find(body, "#deck-info"),
         [hero_raw] <- Floki.attribute(deck_info, "data-hero-id"),
         [format_raw] <- Floki.attribute(deck_info, "data-deck-format"),
         [cards_raw] <- Floki.attribute(deck_info, "data-deck-cards"),
         {hero, _} when is_integer(hero) <- Integer.parse(hero_raw),
         {format, _} when is_integer(format) <- Integer.parse(format_raw),
         cards_parts_raw <- String.split(cards_raw, ","),
         cards <- Enum.map(cards_parts_raw, &Util.to_int_or_orig/1) |> Enum.filter(&is_integer/1),
         deckcode <- Deck.deckcode(cards, hero, format) do
      Deck.decode(deckcode)
    else
      _ -> {:error, :couldnt_extract_deck}
    end
  end

  def throttled_body(url) do
    with false <- throttled?(),
         {:ok, %{body: body}} <- response(url),
         :ok <- update_throttle(body) do
      {:ok, body}
    else
      true -> {:error, :throttled}
      {:error, error} -> {:error, error}
      _other -> {:error, :could_not_get_body}
    end
  end

  defp throttled?() do
    case ApiCache.get(:hsreplay_communication_throttle) do
      nil -> false
      deadline -> :lt == NaiveDateTime.compare(NaiveDateTime.utc_now(), deadline)
    end
  end

  defp update_throttle(%{
         "detail" => "Request was throttled. Expected available in " <> seconds_raw
       }) do
    with {seconds, _} <- Integer.parse(seconds_raw),
         now <- NaiveDateTime.utc_now(),
         deadline <- NaiveDateTime.add(now, seconds + 1) do
      ApiCache.set(:hsreplay_communication_throttle, deadline)
      {:error, "throttling for #{seconds} seconds"}
    else
      _ -> {:error, :couldnt_update_throttle}
    end
  end

  defp update_throttle(_), do: :ok
end
