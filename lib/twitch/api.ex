defmodule Twitch.Api do
  @moduledoc false

  use Tesla
  plug Tesla.Middleware.BaseUrl, "https://api.twitch.tv"

  # plug Tesla.Middleware.Headers, [{"authorization", "Bearer #{Application.fetch_env!(:backend, :twitch_client_secret)}"}]
  plug Tesla.Middleware.Headers, [
    {"Client-Id", Application.fetch_env!(:backend, :twitch_client_id)}
  ]

  plug Tesla.Middleware.JSON

  @hearthstone_id 138_585

  def hearthstone_streams() do
    get_all(&fetch_hearthstone_streams/1, [], nil)
    |> Enum.map(&Twitch.Stream.from_raw_map/1)
  end

  defp fetch_hearthstone_streams(cursor) do
    query = [game_id: @hearthstone_id, after: cursor]
    do_get("/helix/streams/", query)
  end

  @spec do_get(binary | Tesla.Client.t(), list(), list()) :: {:error, any} | {:ok, Tesla.Env.t()}
  def do_get(url, query \\ [], extra_headers \\ []) do
    token = Twitch.TokenRefresher.get_token()
    get(url, query: query, headers: [{:Authorization, "Bearer #{token}"} | extra_headers])
  end

  def hearthstone_streams_after(pagination) do
    token = Twitch.TokenRefresher.get_token()

    get("/helix/streams/",
      query: [game_id: @hearthstone_id, after: pagination],
      headers: [Authorization: "Bearer #{token}"]
    )
  end

  defp data_cursor({:ok, %{body: %{"data" => data, "pagination" => %{"cursor" => cursor}}}}),
    do: {data, cursor}

  defp data_cursor({:ok, %{body: %{"data" => data}}}), do: {data, nil}
  defp data_cursor(_), do: {[], nil}

  defp get_all(get_more, [], _) do
    get_more.(nil)
    |> data_cursor()
    |> case do
      {[], nil} -> []
      {data, cursor} -> get_all(get_more, data, cursor)
    end
  end

  defp get_all(_, carry, nil), do: carry

  defp get_all(get_more, carry, cursor) do
    {data, cursor} =
      get_more.(cursor)
      |> data_cursor()

    get_all(get_more, carry ++ data, cursor)
  end
end
