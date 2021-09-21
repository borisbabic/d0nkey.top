defmodule Backend.Infrastructure.HearthstoneJsonCommunicator do
  @moduledoc false
  @behaviour Backend.HearthstoneJson.Communicator
  alias Backend.HearthstoneJson.Card

  @spec get_collectible_cards() :: {:ok, [Card]} | {:error, any()}
  def get_collectible_cards(),
    do: get("https://api.hearthstonejson.com/v1/latest/enUS/cards.collectible.json")

  @spec get_cards!() :: [Card]
  def get_cards!(), do: get_cards() |> Util.bangify()

  @spec get_cards() :: {:ok, [Card]} | {:error, any()}
  def get_cards(), do: get("https://api.hearthstonejson.com/v1/latest/enUS/cards.json")

  defp get(url) do
    with {:ok, %{body: body}} <- HTTPoison.get(url, [], follow_redirect: true),
         {:ok, decoded} <- Poison.decode(body) do
      {:ok, Enum.map(decoded, &Card.from_raw_map/1)}
    else
      e = {:error, _} -> e
      _ -> {:error, :error_getting}
    end
  end
end
