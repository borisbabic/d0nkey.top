defmodule Backend.HSReplay.StreamingNow do
  @moduledoc false
  use GenServer
  @name :hsreplay_streaming_now
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    send_loop()
    {:ok, []}
  end

  def handle_info(:loop, _state) do
    sn = create_streaming_now()
    BackendWeb.Endpoint.broadcast("streaming:hs:hsreplay_live", "update", %{streaming_now: sn})
    send_loop()
    {:noreply, sn}
  end

  def streaming_now(), do: GenServer.call(@name, :streaming_now)
  def handle_call(:streaming_now, _from, sn), do: {:reply, sn, sn}

  @spec create_streaming_now() :: [Streaming.t()]
  defp create_streaming_now(), do: Backend.HSReplay.get_streaming_now()
  defp send_loop(), do: Process.send_after(self(), :loop, 1000 * 60 * 2)
end
