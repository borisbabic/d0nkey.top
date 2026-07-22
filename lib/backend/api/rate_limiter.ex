defmodule Backend.Api.RateLimiter do
  @moduledoc """
  A small, node-local fixed-window rate limiter for developer API keys.

  The application currently runs its in-memory caches per node as well. If the
  web app is scaled horizontally, this module can be replaced by a distributed
  backend without changing the API plugs.
  """

  use GenServer

  @cleanup_interval_ms :timer.minutes(5)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec hit(term(), pos_integer(), pos_integer()) ::
          {:allow, non_neg_integer(), pos_integer()} | {:deny, pos_integer()}
  def hit(key, limit, window_ms) do
    GenServer.call(__MODULE__, {:hit, key, limit, window_ms, now_ms()})
  end

  @impl true
  def init(_opts) do
    schedule_cleanup()
    {:ok, %{}}
  end

  @impl true
  def handle_call({:hit, key, limit, window_ms, now}, _from, buckets) do
    {reply, bucket} = update_bucket(Map.get(buckets, key), limit, window_ms, now)
    {:reply, reply, Map.put(buckets, key, bucket)}
  end

  @impl true
  def handle_info(:cleanup, buckets) do
    now = now_ms()

    active =
      Map.reject(buckets, fn {_key, %{started_at: started_at, window_ms: window_ms}} ->
        now - started_at >= window_ms
      end)

    schedule_cleanup()
    {:noreply, active}
  end

  defp update_bucket(nil, limit, window_ms, now) do
    {{:allow, limit - 1, window_ms}, bucket(now, window_ms, 1)}
  end

  defp update_bucket(%{started_at: started_at}, limit, window_ms, now)
       when now - started_at >= window_ms do
    {{:allow, limit - 1, window_ms}, bucket(now, window_ms, 1)}
  end

  defp update_bucket(%{count: count, started_at: started_at} = bucket, limit, window_ms, now)
       when count < limit do
    new_count = count + 1
    reset_after_ms = max(window_ms - (now - started_at), 1)

    {
      {:allow, limit - new_count, reset_after_ms},
      %{bucket | count: new_count, window_ms: window_ms}
    }
  end

  defp update_bucket(%{started_at: started_at} = bucket, _limit, window_ms, now) do
    retry_after_ms = max(window_ms - (now - started_at), 1)
    {{:deny, retry_after_ms}, %{bucket | window_ms: window_ms}}
  end

  defp bucket(now, window_ms, count) do
    %{count: count, started_at: now, window_ms: window_ms}
  end

  defp now_ms, do: System.monotonic_time(:millisecond)

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @cleanup_interval_ms)
  end
end
