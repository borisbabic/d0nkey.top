defmodule Backend.Infrastructure.EsportsEarningsCommunicator do
  @moduledoc false
  @behaviour Backend.EsportsEarnings.Communicator
  alias Backend.EsportsEarnings.PlayerDetails

  def api_key() do
    Application.fetch_env!(:backend, :esports_earnings_api_key)
  end

  def get_highest_earnings_for_game(game_id, offset \\ 0) when is_integer(game_id) do
    "https://api.esportsearnings.com/v0/LookupHighestEarningPlayersByGame?apikey=#{api_key()}&gameid=#{
      game_id
    }&offset=#{offset}"
    |> HTTPoison.get([], hackney: [:insecure])
    |> case do
      {:ok, %{body: body, status_code: 200}} when body != "" ->
        body
        |> Poison.decode!()
        |> Enum.map(&PlayerDetails.from_raw_map/1)

      _ ->
        []
    end
  end

  def get_all_highest_earnings_for_game(game_id, offset \\ 0, carry \\ []) do
    case get_highest_earnings_for_game(game_id, offset) do
      [] ->
        carry

      highest ->
        Process.sleep(1500)
        get_all_highest_earnings_for_game(game_id, offset + Enum.count(highest), highest ++ carry)
    end
  end
end
