defmodule Backend.Stream do
  alias Backend.Streaming
  alias Backend.Streaming.Streamer
  @type stream_tuple :: {streaming_platform :: String.t(), id :: String.t()}
  @spec get(stream_tuple) :: any()
  def get({"twitch", id}), do: Streaming.get_streamer_by_twitch_id(id)

  @spec display_name(stream_tuple) :: any()
  def display_name({"twitch", id}),
    do: Streaming.get_streamer_by_twitch_id(id) |> Streamer.twitch_display()
end
