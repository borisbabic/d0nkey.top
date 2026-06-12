defmodule Backend.Infrastructure.HearthstoneJsonCommunicator do
  @moduledoc false
  @behaviour Backend.HearthstoneJson.Communicator
  alias Backend.HearthstoneJson.Card

  @spec get_collectible_cards(String.t() | number) :: {:ok, [Card]} | {:error, any()}
  def get_collectible_cards(build \\ "latest"),
    do: get("https://api.hearthstonejson.com/v1/#{build}/enUS/cards.collectible.json")

  @spec get_cards!(String.t() | number) :: [Card]
  def get_cards!(build \\ "latest"), do: get_cards(build) |> Util.bangify()

  @spec get_cards() :: {:ok, [Card]} | {:error, any()}
  @spec get_cards(String.t() | number) :: {:ok, [Card]} | {:error, any()}
  def get_cards(build \\ "latest"),
    do: get("https://api.hearthstonejson.com/v1/#{build}/enUS/cards.json")

  defp get(url) do
    with {:ok, %{body: body}} <- HTTPoison.get(url, [], follow_redirect: true),
         {:ok, decoded} <- Poison.decode(body) do
      {:ok, Enum.map(decoded, &Card.from_raw_map/1)}
    else
      {:error, _} = e -> e
      _ -> {:error, :error_getting}
    end
  end

  @directory_url "https://api.hearthstonejson.com/v1/"
  @version_regex ~r/"\/v1\/(\d+)\/"/
  @spec get_latest_version() :: {:ok, integer()} | {:error, any()}
  def get_latest_version do
    with {:ok, %{body: body}} <- HTTPoison.get(@directory_url) do
      latest =
        Regex.scan(@version_regex, body)
        |> Enum.map(fn [_matched, captured] ->
          Util.to_int!(captured)
        end)
        |> Enum.max()

      {:ok, latest}
    end
  end
end
