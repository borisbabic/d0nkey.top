defmodule Youtube.Api do
  @moduledoc "Minimal YouTube Data API v3 client"

  @base_url "https://www.googleapis.com/youtube/v3"
  @video_id_regex ~r/^[A-Za-z0-9_-]{11}$/

  @doc "Fetches the channels owned by the account the oauth token belongs to"
  @spec my_channels(String.t()) :: {:ok, [map()]} | {:error, any()}
  def my_channels(access_token) do
    [
      base_url: @base_url,
      url: "/channels",
      params: [part: "snippet", mine: true],
      auth: {:bearer, access_token}
    ]
    |> Req.new()
    |> Req.get()
    |> parse_channels()
  end

  @doc """
  Ids of the most recent videos (including live streams) of the channel.
  Tries the rss feed first since it doesn't use quota, falls back to the uploads playlist (1 quota unit)
  """
  @spec recent_video_ids(String.t(), String.t(), integer()) ::
          {:ok, [String.t()]} | {:error, any()}
  def recent_video_ids(channel_id, api_key, limit \\ 5) do
    with {:error, _} <- feed_video_ids(channel_id, limit) do
      uploads_video_ids(channel_id, api_key, limit)
    end
  end

  @spec feed_video_ids(String.t(), integer()) :: {:ok, [String.t()]} | {:error, any()}
  def feed_video_ids(channel_id, limit) do
    case Req.get("https://www.youtube.com/feeds/videos.xml",
           params: [channel_id: channel_id],
           retry: false
         ) do
      {:ok, %{status: 200, body: body}} -> {:ok, parse_feed_video_ids(body, limit)}
      {:ok, %{status: status}} -> {:error, status}
      error -> error
    end
  end

  @spec uploads_video_ids(String.t(), String.t(), integer()) ::
          {:ok, [String.t()]} | {:error, any()}
  def uploads_video_ids(channel_id, api_key, limit) do
    [
      base_url: @base_url,
      url: "/playlistItems",
      params: [
        part: "contentDetails",
        playlistId: uploads_playlist_id(channel_id),
        maxResults: limit,
        key: api_key
      ]
    ]
    |> Req.new()
    |> Req.get()
    |> case do
      {:ok, %{status: 200, body: %{"items" => items}}} ->
        {:ok, Enum.map(items, &get_in(&1, ["contentDetails", "videoId"]))}

      {:ok, %{status: status, body: body}} ->
        {:error, {status, body}}

      error ->
        error
    end
  end

  @doc """
  The uploads playlist id is the channel id with UU instead of UC

  iex> Youtube.Api.uploads_playlist_id("UCabc")
  "UUabc"
  """
  def uploads_playlist_id("UC" <> rest), do: "UU" <> rest
  def uploads_playlist_id(channel_id), do: channel_id

  @doc false
  def parse_feed_video_ids(feed, limit) do
    ~r{<yt:videoId>([^<]+)</yt:videoId>}
    |> Regex.scan(feed, capture: :all_but_first)
    |> Enum.map(&hd/1)
    |> Enum.take(limit)
  end

  @doc "Recent videos (including live streams) from the channel's rss feed, doesn't use quota"
  @spec feed_videos(String.t(), integer()) :: {:ok, [map()]} | {:error, any()}
  def feed_videos(channel_id, limit) do
    case Req.get("https://www.youtube.com/feeds/videos.xml",
           params: [channel_id: channel_id],
           retry: false
         ) do
      {:ok, %{status: 200, body: body}} -> {:ok, parse_feed_videos(body, limit)}
      {:ok, %{status: status}} -> {:error, status}
      error -> error
    end
  end

  @doc false
  def parse_feed_videos(feed, limit) do
    ~r{<entry>(.*?)</entry>}s
    |> Regex.scan(feed, capture: :all_but_first)
    |> Enum.map(fn [entry] -> parse_feed_entry(entry) end)
    |> Enum.filter(& &1.id)
    |> Enum.take(limit)
  end

  defp parse_feed_entry(entry) do
    %{
      id: feed_tag(entry, "yt:videoId"),
      channel_id: feed_tag(entry, "yt:channelId"),
      title: entry |> feed_tag("title") |> decode_entities(),
      published_at: entry |> feed_tag("published") |> parse_datetime()
    }
  end

  defp feed_tag(entry, tag) do
    case Regex.run(~r{<#{tag}>([^<]*)</#{tag}>}, entry, capture: :all_but_first) do
      [value] -> value
      _ -> nil
    end
  end

  defp decode_entities(nil), do: nil
  defp decode_entities(text), do: text |> Floki.parse_fragment!() |> Floki.text()

  defp parse_datetime(nil), do: nil

  defp parse_datetime(text) do
    case DateTime.from_iso8601(text) do
      {:ok, dt, _offset} -> dt
      _ -> nil
    end
  end

  @doc "The channel that uploaded the video. Costs 1 quota unit"
  @spec video_channel_id(String.t(), String.t()) :: {:ok, String.t()} | {:error, any()}
  def video_channel_id(video_id, api_key) do
    case videos([video_id], api_key) do
      {:ok, [%{"snippet" => %{"channelId" => channel_id}} | _]} -> {:ok, channel_id}
      {:ok, []} -> {:error, :video_not_found}
      error -> error
    end
  end

  @doc """
  Extracts the video id from common youtube links, or returns the id if passed one

  iex> Youtube.Api.extract_video_id("https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10")
  "dQw4w9WgXcQ"
  iex> Youtube.Api.extract_video_id("https://youtu.be/dQw4w9WgXcQ")
  "dQw4w9WgXcQ"
  iex> Youtube.Api.extract_video_id("https://www.youtube.com/live/dQw4w9WgXcQ?si=abc")
  "dQw4w9WgXcQ"
  iex> Youtube.Api.extract_video_id("dQw4w9WgXcQ")
  "dQw4w9WgXcQ"
  iex> Youtube.Api.extract_video_id("https://example.com/watch?v=dQw4w9WgXcQ")
  nil
  """
  @spec extract_video_id(String.t() | nil) :: String.t() | nil
  def extract_video_id(nil), do: nil

  def extract_video_id(link_or_id) when is_binary(link_or_id) do
    trimmed = String.trim(link_or_id)

    if Regex.match?(@video_id_regex, trimmed) do
      trimmed
    else
      trimmed |> URI.parse() |> video_id_from_uri()
    end
  end

  defp video_id_from_uri(%URI{host: host} = uri) when is_binary(host) do
    host = String.replace_prefix(host, "www.", "") |> String.replace_prefix("m.", "")

    host
    |> candidate_video_id(uri)
    |> valid_video_id()
  end

  defp video_id_from_uri(_), do: nil

  defp candidate_video_id("youtu.be", %{path: "/" <> id}), do: id

  defp candidate_video_id(host, %{path: path, query: query})
       when host in ["youtube.com", "youtube-nocookie.com"] do
    case String.split(path || "", "/", trim: true) do
      ["watch"] -> URI.decode_query(query || "") |> Map.get("v")
      [type, id | _] when type in ["live", "shorts", "embed", "v"] -> id
      _ -> nil
    end
  end

  defp candidate_video_id(_, _), do: nil

  defp valid_video_id(<<id::binary>>) do
    if Regex.match?(@video_id_regex, id), do: id, else: nil
  end

  defp valid_video_id(_), do: nil

  @doc "Fetches video details (snippet, live details, statistics). Costs 1 quota unit per 50 videos"
  @spec videos([String.t()], String.t()) :: {:ok, [map()]} | {:error, any()}
  def videos(video_ids, api_key) do
    video_ids
    |> Enum.chunk_every(50)
    |> Enum.reduce_while({:ok, []}, fn chunk, {:ok, acc} ->
      case fetch_videos(chunk, api_key) do
        {:ok, items} -> {:cont, {:ok, acc ++ items}}
        error -> {:halt, error}
      end
    end)
  end

  defp fetch_videos(video_ids, api_key) do
    [
      base_url: @base_url,
      url: "/videos",
      params: [part: "snippet,liveStreamingDetails", id: Enum.join(video_ids, ","), key: api_key]
    ]
    |> Req.new()
    |> Req.get()
    |> case do
      {:ok, %{status: 200, body: body}} -> {:ok, Map.get(body, "items", [])}
      {:ok, %{status: status, body: body}} -> {:error, {status, body}}
      error -> error
    end
  end

  defp parse_channels({:ok, %{status: 200, body: body}}) do
    {:ok, body |> Map.get("items", []) |> Enum.map(&to_channel_attrs/1)}
  end

  defp parse_channels({:ok, %{status: status, body: body}}), do: {:error, {status, body}}
  defp parse_channels(error), do: error

  defp to_channel_attrs(%{"id" => id} = item) do
    snippet = Map.get(item, "snippet", %{})

    %{
      channel_id: id,
      title: snippet["title"],
      handle: snippet["customUrl"],
      thumbnail_url: get_in(snippet, ["thumbnails", "default", "url"])
    }
  end
end
