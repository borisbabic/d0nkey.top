defmodule Backend.HSDeckViewer do
  @moduledoc false
  alias Backend.Hearthstone.Deck
  def create_link(<<deckstring::binary>>), do: create_link([deckstring])

  @spec create_link([String.t()]) :: String.t()
  def create_link(deckstrings) do
    query =
      deckstrings
      |> Deck.shorten()
      |> Enum.map(fn ds -> {"deckstring", ds} end)
      |> URI.encode_query()

    "https://hsdeckviewer.com?#{query}"
  end

  def hdv_link?(link) when is_binary(link), do: link =~ "hsdeckviewer.com"
  def hdv_link?(_), do: false

  @doc """
  Extracts deckcodes from an hsdeckviewer link

  ## Example
  iex> Backend.HSDeckViewer.extract_codes("example.com")
  []
  iex> Backend.HSDeckViewer.extract_codes("hsdeckviewer.com/")
  []
  iex> Backend.HSDeckViewer.extract_codes("hsdeckviewer.com/?deckstring=")
  []
  iex> Backend.HSDeckViewer.extract_codes("https://hsdeckviewer.com/?deckstring=AAECAf0EBvisA8W4A9DOA9nRA%2FzdA5PhAwzmBJ%2BbA%2BKbA%2F%2BdA%2FusA%2F2sA%2FOvA4XNA83OA%2FfRA%2F7RA%2FjdAwA%3D")
  ["AAECAf0EBvisA8W4A9DOA9nRA/zdA5PhAwzmBJ+bA+KbA/+dA/usA/2sA/OvA4XNA83OA/fRA/7RA/jdAwA="]
  iex> Backend.HSDeckViewer.extract_codes("https://hsdeckviewer.com/?deckstring=AAECAY0WCqsEg5YD%2BKwDxbgDjbsD4MwD0M4DpNED2dED%2FtEDCuYEn5sD4psD%2F50D%2B6wD%2FawD%2BMwDhc0Dzc4D99EDAA%3D%3D&deckstring=AAECAc7WAwTosAPaxgPUyAPP0gMNh7oD17sD4LwD2cYD%2FMgD%2FsgD0c0D%2B84D%2FtEDzNIDzdID1NID99UDAA%3D%3D")
  ["AAECAY0WCqsEg5YD+KwDxbgDjbsD4MwD0M4DpNED2dED/tEDCuYEn5sD4psD/50D+6wD/awD+MwDhc0Dzc4D99EDAA==", "AAECAc7WAwTosAPaxgPUyAPP0gMNh7oD17sD4LwD2cYD/MgD/sgD0c0D+84D/tEDzNIDzdID1NID99UDAA=="]
  """
  @spec extract_codes(String.t()) :: [String.t()]
  def extract_codes(link) do
    with %{query: query} when is_binary(query) <- link |> URI.parse(),
         decoded <- query |> URI.decode() do
      decoded |> String.split(~r/&?deckstring=/) |> Enum.filter(&(bit_size(&1) > 0))
    else
      _ -> []
    end
  end
end
