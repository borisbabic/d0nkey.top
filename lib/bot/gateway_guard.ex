defmodule Bot.GatewayGuard do
  @moduledoc """
  Protects the bot token from reconnect loops.

  Nostrum (0.10) reconnects to the Discord gateway after every close, including
  fatal close codes like 4004 (invalid token) or 4014 (disallowed intents), with
  only the ~5s identify delay between attempts. Discord resets the token after
  ~1000 connections, so a loop like that kills the token within an hour or two.

  This guard:
    * enables Nostrum's info logs so disconnects and their close codes are visible
    * stops all shards on a fatal close code
    * stops all shards when there are too many disconnects within a time window

  Nostrum doesn't expose disconnects as events, so they're detected from its log
  messages by `Bot.GatewayGuard.LogHandler`. Recheck the messages when upgrading Nostrum.
  """
  use GenServer
  require Logger

  # https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes
  @fatal_close_codes [4004, 4010, 4011, 4012, 4013, 4014]
  @max_disconnects 30
  @window_ms :timer.minutes(15)

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc "Report a gateway disconnect. `close_code` is nil when unknown."
  @spec disconnected(integer() | nil) :: :ok
  def disconnected(close_code), do: GenServer.cast(__MODULE__, {:disconnected, close_code})

  @impl true
  def init(_opts) do
    Logger.put_application_level(:nostrum, :info)
    Bot.GatewayGuard.LogHandler.attach()
    {:ok, %{disconnects: [], stopped?: false}}
  end

  @impl true
  def handle_cast({:disconnected, _code}, %{stopped?: true} = state), do: {:noreply, state}

  def handle_cast({:disconnected, code}, state) do
    now = System.monotonic_time(:millisecond)
    {decision, disconnects} = decide(state.disconnects, code, now)
    {:noreply, act(decision, %{state | disconnects: disconnects})}
  end

  @impl true
  def terminate(_reason, _state), do: Bot.GatewayGuard.LogHandler.detach()

  @doc """
  Decides what to do about a disconnect.

  `disconnects` are monotonic timestamps (ms) of previous disconnects, newest first.
  """
  @spec decide([integer()], integer() | nil, integer()) ::
          {:continue | {:stop, String.t()}, [integer()]}
  def decide(disconnects, code, now) do
    recent = [now | Enum.take_while(disconnects, &(now - &1 <= @window_ms))]

    cond do
      fatal_close_code?(code) ->
        {{:stop, "fatal gateway close code #{code}"}, recent}

      length(recent) > @max_disconnects ->
        {{:stop, "#{length(recent)} gateway disconnects within #{div(@window_ms, 60_000)} minutes"}, recent}

      true ->
        {:continue, recent}
    end
  end

  @spec fatal_close_code?(integer() | nil) :: boolean()
  def fatal_close_code?(code), do: code in @fatal_close_codes

  defp act(:continue, state), do: state

  defp act({:stop, reason}, state) do
    Logger.error(
      "Bot.GatewayGuard: stopping Discord shards to protect the token: #{reason}. " <>
        "Fix the cause and restart the bot."
    )

    stop_shards()
    %{state | stopped?: true}
  end

  defp stop_shards do
    Nostrum.Shard.Supervisor
    |> DynamicSupervisor.which_children()
    |> Enum.each(fn {_, pid, _, _} ->
      DynamicSupervisor.terminate_child(Nostrum.Shard.Supervisor, pid)
    end)
  catch
    :exit, reason -> Logger.error("Bot.GatewayGuard: couldn't stop shards: #{inspect(reason)}")
  end
end
