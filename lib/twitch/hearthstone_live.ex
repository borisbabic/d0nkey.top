defmodule Twitch.HearthstoneLive do
  @moduledoc false
  use GenServer
  @name :hearthstone_live_twitch

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    send_loop(0)
    {:ok, []}
  end

  def handle_info(:loop, _state) do
    streams = create_streams()

    BackendWeb.Endpoint.broadcast_from(self(), "streaming:hs:twitch_live", "update", %{
      streams: streams
    })

    send_loop()
    {:noreply, streams}
  end

  @spec streams() :: [Twitch.Stream]
  def streams(), do: GenServer.call(@name, :streams)

  def handle_call(:streams, _from, streams), do: {:reply, streams, streams}

  defp create_streams(), do: Twitch.Api.hearthstone_streams()
  defp send_loop(after_ms \\ 60_000), do: Process.send_after(self(), :loop, after_ms)

  def twitch_id_live?(nil), do: false
  def twitch_id_live?(twitch_id), do: streams() |> Enum.any?(&(to_string(&1.user_id) == to_string(twitch_id)))

  def twitch_display_live?(twitch_display, title) when nil in [twitch_display, title], do: false
  def twitch_display_live?(twitch_display, title_contains) when is_binary(title_contains) do
    case get_by_twitch_display(twitch_display) do
      %{title: title} -> String.contains?(title, title_contains)
      _ -> false
    end
  end

  @spec get_by_twitch_display(String.t()) :: Twitch.Stream.t() | nil
  def get_by_twitch_display(twitch_display) do
    Enum.find(streams(), & &1.user_name == twitch_display)
  end

  @spec get_by_twitch_login(String.t()) :: Twitch.Stream.t() | nil
  def get_by_twitch_login(twitch_login) do
    Enum.find(streams(), & twitch_login && Twitch.Stream.login(&1.titch_login) == twitch_login)
  end

end
