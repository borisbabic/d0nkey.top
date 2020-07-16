defmodule Backend.Infrastructure.HearthstoneJsonCommunicator do
  @moduledoc false
  @behaviour Backend.HearthstoneJson.Communicator
  alias Backend.HearthstoneJson.Card

  @spec get_collectible_cards() :: [Card]
  def get_collectible_cards() do
    get("https://api.hearthstonejson.com/v1/latest/enUS/cards.collectible.json")
  end

  @spec get_cards() :: [Card]
  def get_cards() do
    get("https://api.hearthstonejson.com/v1/latest/enUS/cards.json")
  end

  defp get(url) do
    response =
      url
      |> HTTPoison.get!([], follow_redirect: true)

    response.body
    |> Poison.decode!()
    |> Enum.map(&Card.from_raw_map/1)
  end
end
