defmodule Youtube.Stream do
  @moduledoc "A live youtube stream, created from a youtube video resource"

  @hearthstone_patterns ["hearthstone", "炉石", "爐石"]

  @type t :: %{
          id: String.t(),
          channel_id: String.t(),
          channel_title: String.t(),
          title: String.t(),
          thumbnail_url: String.t() | nil,
          viewer_count: integer(),
          language: String.t() | nil,
          started_at: NaiveDateTime.t(),
          hearthstone?: boolean(),
          link: String.t()
        }

  @spec live?(map()) :: boolean()
  def live?(%{"snippet" => %{"liveBroadcastContent" => "live"}}), do: true
  def live?(_), do: false

  @spec from_video(map()) :: t()
  def from_video(%{"id" => id, "snippet" => snippet} = video) do
    details = Map.get(video, "liveStreamingDetails", %{})

    %{
      id: id,
      channel_id: snippet["channelId"],
      channel_title: snippet["channelTitle"],
      title: snippet["title"],
      thumbnail_url: thumbnail_url(snippet),
      viewer_count: Util.to_int(details["concurrentViewers"], 0),
      language: language(snippet),
      started_at: started_at(details),
      hearthstone?: hearthstone?(snippet),
      link: "https://www.youtube.com/watch?v=#{id}"
    }
  end

  @doc "Youtube doesn't expose the game being played, so we guess from the metadata"
  @spec hearthstone?(map()) :: boolean()
  def hearthstone?(snippet) do
    text =
      [snippet["title"], snippet["description"] | Map.get(snippet, "tags", [])]
      |> Enum.filter(&is_binary/1)
      |> Enum.join(" ")
      |> String.downcase()

    String.contains?(text, @hearthstone_patterns)
  end

  defp thumbnail_url(%{"thumbnails" => thumbnails}) do
    ["medium", "high", "default"]
    |> Enum.find_value(&get_in(thumbnails, [&1, "url"]))
  end

  defp thumbnail_url(_), do: nil

  defp language(snippet) do
    case snippet["defaultAudioLanguage"] || snippet["defaultLanguage"] do
      <<lang::binary>> -> lang |> String.split("-") |> hd() |> String.downcase()
      _ -> nil
    end
  end

  defp started_at(%{"actualStartTime" => start}) do
    case DateTime.from_iso8601(start) do
      {:ok, dt, _} -> DateTime.to_naive(dt)
      _ -> NaiveDateTime.utc_now()
    end
  end

  defp started_at(_), do: NaiveDateTime.utc_now()
end
