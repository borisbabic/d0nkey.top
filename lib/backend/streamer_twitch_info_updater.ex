defmodule Backend.StreamerTwitchInfoUpdater do
  @moduledoc false
  use GenServer
  @name :streamer_twitch_info_updater
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    BackendWeb.Endpoint.subscribe("streaming:hs:twitch_live")
    {:ok, nil}
  end

  def handle_info(%{topic: "streaming:hs:twitch_live", payload: %{streams: twitch}}, state) do
    Backend.Streaming.update_twitch_info(twitch)
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
