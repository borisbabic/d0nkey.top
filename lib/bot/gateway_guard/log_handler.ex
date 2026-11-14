defmodule Bot.GatewayGuard.LogHandler do
  @moduledoc """
  `:logger` handler that detects Nostrum gateway disconnects from its log messages
  and reports them to `Bot.GatewayGuard`.

  Handlers run in the logging process (the shard session), so this only parses
  and casts, it never blocks.
  """

  @handler_id :bot_gateway_guard
  @session_module Nostrum.Shard.Session
  @close_regex ~r/^Shard websocket closed \(errno (\d+)/
  @other_disconnect_prefixes [
    "Shard websocket closed (unknown reason)",
    "Lost complete shard connection"
  ]

  def attach do
    case :logger.add_handler(@handler_id, __MODULE__, %{level: :all}) do
      {:error, {:already_exist, _}} -> :ok
      other -> other
    end
  end

  def detach, do: :logger.remove_handler(@handler_id)

  # :logger handler callback
  def log(%{meta: %{mfa: {@session_module, _, _}}, msg: msg}, _config) do
    with {:ok, text} <- message_text(msg),
         {:disconnected, code} <- parse(text) do
      Bot.GatewayGuard.disconnected(code)
    end

    :ok
  end

  def log(_event, _config), do: :ok

  @doc "Parses a Nostrum session log message into a disconnect, if it is one."
  @spec parse(String.t()) :: {:disconnected, integer() | nil} | :ignore
  def parse(text) do
    cond do
      match = Regex.run(@close_regex, text, capture: :all_but_first) ->
        {:disconnected, match |> hd() |> String.to_integer()}

      Enum.any?(@other_disconnect_prefixes, &String.starts_with?(text, &1)) ->
        {:disconnected, nil}

      true ->
        :ignore
    end
  end

  defp message_text({:string, chardata}), do: {:ok, IO.chardata_to_string(chardata)}
  defp message_text(_), do: :ignore
end
