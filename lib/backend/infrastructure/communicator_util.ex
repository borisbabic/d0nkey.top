defmodule Backend.Infrastructure.CommunicatorUtil do
  @moduledoc false
  require Logger

  def get_body(url) do
    response = get_response(url)
    response.body
  end

  def response(url) do
    case :timer.tc(&HTTPoison.get/1, [URI.encode(url)]) do
      {u_secs, {:ok, response}} ->
        Logger.debug("Got #{url} in #{div(u_secs, 1000)} ms")
        {:ok, response}

      {u_secs, {:error, error}} ->
        Logger.warning("Error getting #{url} in #{div(u_secs, 1000)} ms: #{inspect(error)}")
        {:error, error}

      {u_secs, _} ->
        Logger.warning("Error getting #{url} in #{div(u_secs, 1000)} ms")
        {:error, :error_getting_response}

      _ ->
        Logger.warning("Error getting #{url}")
        {:error, :unable_to_Get_response}
    end
  end

  def get_response(url), do: response(url) |> Util.bangify()
end
