defmodule Backend.Infrastructure.CommunicatorUtil do
  @moduledoc false
  require Logger

  def get_body(url) do
    response = get_response(url)
    response.body
  end

  def get_response(url) do
    {u_secs, response} = :timer.tc(&HTTPoison.get!/1, [URI.encode(url)])
    Logger.debug("Got #{url} in #{div(u_secs, 1000)} ms")
    response
  end
end
