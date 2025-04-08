defmodule BobsLeague.Api do
  @moduledoc false
  use Tesla
  plug(Tesla.Middleware.BaseUrl, "https://api.bobsleague.com")
  alias BobsLeague.Api.Tournament

  @spec tournaments() :: {:ok, Tournament.t()} | {:error, any()}
  def tournaments() do
    with {:ok, %{body: body}} <- get("/tournaments/?limit=25"),
         {:ok, %{"data" => data}} <- Jason.decode(body) do
      tournaments =
        for {:ok, tournament} <- Enum.map(data, &Tournament.from_raw_map/1), do: tournament

      {:ok, tournaments}
    else
      r = {:error, _reason} -> r
      _ -> {:error, :unknown_error_getting_bobs_league_tournaments}
    end
  end
end
