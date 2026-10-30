defmodule Youtube.Api do
  @moduledoc "Minimal YouTube Data API v3 client"

  @base_url "https://www.googleapis.com/youtube/v3"

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
