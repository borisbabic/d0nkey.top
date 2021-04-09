defmodule Backend.Infrastructure.GrandmastersCommunicator do
  @moduledoc false

  alias Backend.Grandmasters.Response

  use Tesla
  plug Tesla.Middleware.Cache, ttl: :timer.seconds(60)
  plug Tesla.Middleware.Timeout, timeout: 10_000

  def get_gm() do
    url =
      "https://playhearthstone.com/en-us/api/esports/schedule/grandmasters/?season=null&year=null"

    with {:ok, %{body: body}} <- get(url),
         {:ok, decoded} <- Poison.decode(body) do
      Response.from_raw_map(decoded)
    end
  end
end
