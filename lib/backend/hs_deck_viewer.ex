defmodule Backend.HSDeckViewer do
  @spec create_link([String.t()]) :: String.t()
  def create_link(deckstrings) do
    query =
      deckstrings
      |> Enum.map(fn ds -> {"deckstring", ds} end)
      |> URI.encode_query()

    "https://www.hsdeckviewer.com?#{query}"
  end
end
