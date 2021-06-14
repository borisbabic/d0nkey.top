defmodule Backend.Infrastructure.GrandmastersCommunicator do
  @moduledoc false

  alias Backend.Grandmasters.Response

  use Tesla
  plug Tesla.Middleware.Timeout, timeout: 10_000

  def get_gm() do
    url =
      "https://playhearthstone.com/en-us/api/esports/schedule/grandmasters/?season=null&year=null"

    with {:ok, %{body: body}} <- get(url),
         {:ok, decoded} <- Poison.decode(body) do
      {:ok, Response.from_raw_map(decoded)}
    else
      r = {:error, _reason} -> r
      _ -> {:error, :unknown_error}
    end
  end
end
