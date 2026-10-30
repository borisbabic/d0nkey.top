defmodule Youtube.HearthstoneLive do
  @moduledoc """
  Tracks live streams of the youtube channels users connected.
  Youtube has no game category we can query, so instead we check the recent videos of the connected channels.

  To save quota only channels of users who recently submitted a deck tracker game (or that are already live) are polled.
  Channels are also checked on demand when a deck tracker game comes in, see `ensure_checked/1`
  """
  use GenServer
  require Logger
  @name :hearthstone_live_youtube
  @active_minutes 30

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    send_loop(10_000)
    table = :ets.new(@name, [:named_table])
    {:ok, %{table: table, checked_at: %{}}}
  end

  def handle_info(:loop, state) do
    channel_ids =
      Backend.UserManager.recently_active_youtube_channel_ids(@active_minutes)
      |> Enum.concat(Enum.map(live_streams(), & &1.channel_id))
      |> Enum.uniq()

    # every polled channel is replaced, so channels that stopped being active are dropped
    new_state = check_channels(channel_ids, state, fn _ -> [] end)
    send_loop()
    {:noreply, new_state}
  end

  def handle_call({:ensure_checked, channel_ids}, _from, %{checked_at: checked_at} = state) do
    stale = Enum.reject(channel_ids, &recently_checked?(checked_at, &1))
    {:reply, :ok, check_channels(stale, state, &live_streams_except/1)}
  end

  defp check_channels([], state, _keep), do: state

  defp check_channels(channel_ids, %{table: table, checked_at: checked_at} = state, keep) do
    with <<api_key::binary>> <- api_key(),
         {:ok, fetched} <- fetch_live_streams(channel_ids, api_key) do
      live = keep.(channel_ids) ++ fetched
      :ets.insert(table, {:live_streams, live})
      Backend.Streaming.update_youtube_info(fetched)
      broadcast(live)
      now = System.monotonic_time(:millisecond)
      %{state | checked_at: Map.merge(checked_at, Map.new(channel_ids, &{&1, now}))}
    else
      {:error, reason} ->
        Logger.warning("Couldn't fetch youtube live streams: #{inspect(reason)}")
        state

      _no_api_key ->
        state
    end
  end

  defp live_streams_except(channel_ids) do
    Enum.reject(live_streams(), &(&1.channel_id in channel_ids))
  end

  defp recently_checked?(checked_at, channel_id) do
    case Map.get(checked_at, channel_id) do
      nil -> false
      at -> System.monotonic_time(:millisecond) - at < poll_interval()
    end
  end

  defp broadcast(live) do
    BackendWeb.Endpoint.broadcast_from(self(), "streaming:hs:youtube_live", "update", %{
      streams: Enum.filter(live, & &1.hearthstone?)
    })
  end

  defp fetch_live_streams(channel_ids, api_key) do
    video_ids =
      channel_ids
      |> Task.async_stream(&Youtube.Api.recent_video_ids(&1, api_key),
        max_concurrency: 10,
        timeout: 30_000,
        on_timeout: :kill_task
      )
      |> Enum.flat_map(fn
        {:ok, {:ok, ids}} -> ids
        _ -> []
      end)

    with {:ok, videos} <- Youtube.Api.videos(video_ids, api_key) do
      {:ok, for(video <- videos, Youtube.Stream.live?(video), do: Youtube.Stream.from_video(video))}
    end
  end

  defp api_key, do: Application.get_env(:backend, :youtube_api_key)
  defp poll_interval, do: Application.get_env(:backend, :youtube_poll_interval_ms, 180_000)
  defp table, do: :ets.whereis(@name)
  defp send_loop, do: send_loop(poll_interval())
  defp send_loop(after_ms), do: Process.send_after(self(), :loop, after_ms)

  @doc """
  Checks if the channels are live, unless they were checked within the poll interval.
  Used when a deck tracker game comes in so the streamer's first game isn't missed
  """
  @spec ensure_checked([String.t()]) :: :ok
  def ensure_checked([]), do: :ok

  def ensure_checked(channel_ids) do
    GenServer.call(@name, {:ensure_checked, channel_ids}, 60_000)
  catch
    :exit, reason ->
      Logger.warning("Couldn't check youtube channels: #{inspect(reason)}")
      :ok
  end

  @doc "All live streams of tracked channels, hearthstone or not"
  @spec live_streams() :: [Youtube.Stream.t()]
  def live_streams, do: Util.ets_lookup(table(), :live_streams, [])

  @doc "Live streams that appear to be hearthstone"
  @spec streams() :: [Youtube.Stream.t()]
  def streams, do: Enum.filter(live_streams(), & &1.hearthstone?)

  @doc """
  If any of the channels is live. Doesn't check if the stream is hearthstone
  since this is used when we already know they're playing hearthstone (ie from deck tracker games)
  """
  @spec live_channel_id([String.t()]) :: String.t() | nil
  def live_channel_id(channel_ids) do
    live = live_streams() |> MapSet.new(& &1.channel_id)
    Enum.find(channel_ids, &MapSet.member?(live, &1))
  end
  @spec live_channel_ids([String.t()]) :: [String.t()]
  def live_channel_ids(channel_ids) do
    live = live_streams() |> MapSet.new(& &1.channel_id)
    Enum.find(channel_ids, &MapSet.member?(live, &1))
  end
end
