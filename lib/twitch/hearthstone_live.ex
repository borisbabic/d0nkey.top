defmodule Twitch.HearthstoneLive do
  @moduledoc false
  use GenServer
  @name :hearthstone_live_twitch

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    streams = create_streams()
    send_loop()
    {:ok, streams}
  end

  def handle_info(:loop, _state) do
    streams = create_streams()

    BackendWeb.Endpoint.broadcast_from(self(), "streaming:hs:twitch_live", "update", %{
      streams: streams
    })

    send_loop()
    {:noreply, streams}
  end

  def streams(), do: GenServer.call(@name, :streams)

  def handle_call(:streams, _from, streams), do: {:reply, streams, streams}

  defp create_streams(), do: Twitch.Api.hearthstone_streams()
  defp send_loop(), do: Process.send_after(self(), :loop, 1000 * 60)
end
