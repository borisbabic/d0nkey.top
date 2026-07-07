defmodule ViciousSyndicate.Api do
  @moduledoc false

  @spec extract_child_deckcodes(String.t()) :: [String.t()]
  def extract_child_deckcodes(url) do
    case get(url) do
      {:ok, %{body: body}} ->
        body
        |> extract_deck_urls()
        |> Enum.flat_map(&extract_deckcodes/1)

      _ ->
        []
    end
  end

  @spec extract_deckcodes(String.t()) :: [String.t()]
  def extract_deckcodes(url) do
    with {:ok, %{body: body}} <- get(url),
         {:ok, parsed} <- Floki.parse_document(body) do
      parsed |> Floki.find(".deck-input") |> Floki.attribute("value")
    else
      _ -> []
    end
  end

  def client do
    Tesla.client([{Tesla.Middleware.BaseUrl, "https://www.vicioussyndicate.com"}])
  end

  def get(url) do
    Tesla.get(client(), url)
  end

  def extract_deck_urls(body) do
    Regex.scan(deck_url_regex(), body)
    |> Enum.flat_map(& &1)
  end

  def deck_url_regex, do: ~r/https:\/\/www\.vicioussyndicate\.com\/decks\/[^\/]+\//
end
