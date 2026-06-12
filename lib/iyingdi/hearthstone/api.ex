defmodule Iyingdi.Hearthstone.Api do
  @moduledoc false
  alias Iyingdi.Hearthstone.Deck

  @spec fetch_decks(String.t()) :: {:ok, [Deck.t()]} | {:error, any()}
  def fetch_decks(set_id) do
    url = decks_url(set_id)

    with {:ok, %{body: body}} <- get(url),
         {:ok, %{"list" => list, "success" => true}} <- JSON.decode(body) do
      {:ok, Enum.map(list, &Deck.from_raw_map/1)}
    end
  end

  def decks_url(set_id) do
    "/hearthstone/set/#{set_id}/decks?token=&page=0&size=10000"
  end

  def client do
    Tesla.client([{Tesla.Middleware.BaseUrl, "https://api2.iyingdi.com"}])
  end

  def get(url) do
    Tesla.get(client(), url)
  end
end
