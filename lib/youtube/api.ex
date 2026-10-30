defmodule Youtube.Api do
  @moduledoc "Minimal YouTube Data API v3 client"

  @base_url "https://www.googleapis.com/youtube/v3"

  @doc "Fetches the channels owned by the account the oauth token belongs to"
  @spec my_channels(String.t()) :: {:ok, [map()]} | {:error, any()}
  def my_channels(access_token) do
    [
      base_url: @base_url,
      url: "/channels",
      params: [part: "snippet", mine: true],
      auth: {:bearer, access_token}
    ]
    |> Req.new()
    |> Req.get()
    |> parse_channels()
  end

  defp parse_channels({:ok, %{status: 200, body: body}}) do
    {:ok, body |> Map.get("items", []) |> Enum.map(&to_channel_attrs/1)}
  end

  defp parse_channels({:ok, %{status: status, body: body}}), do: {:error, {status, body}}
  defp parse_channels(error), do: error

  defp to_channel_attrs(%{"id" => id} = item) do
    snippet = Map.get(item, "snippet", %{})

    %{
      channel_id: id,
      title: snippet["title"],
      handle: snippet["customUrl"],
      thumbnail_url: get_in(snippet, ["thumbnails", "default", "url"])
    }
  end
end
