defmodule Hearthstone.DeckcodeExtractor do
  @moduledoc "Extract deckcodes from text"

  alias Backend.HSDeckViewer
  alias Backend.HSReplay
  alias Backend.Yaytears
  # The extraction implementation doesn't work since the ids in the URL aren't hearthstone IDs
  # alias Backend.HSTopDecks
  alias Backend.Hearthstone.Deck

  @doc """
  Doesn't check every part so that we don't get spammed
  """
  def performant_extract_from_text(content) do
    for part <- String.split(content),
        String.length(part) > 15,
        parseable_link?(part) or Regex.match?(Backend.Hearthstone.Deck.deckcode_regex(), part),
        codes = extract_decks(part),
        Enum.any?(codes),
        reduce: [] do
      acc -> acc ++ codes
    end
  end

  defp parseable_link?(possible_link) do
    # HSTopDecks.deckbuilder_link?(possible_link) or
    HSDeckViewer.hdv_link?(possible_link) or
      Yaytears.yt_link?(possible_link) or
      HSReplay.hsreplay_link?(possible_link) or
      our_link?(possible_link) or
      link_with_query?(possible_link)
  end

  defp link_with_query?(thing) do
    case URI.parse(thing) do
      %{query: query} when is_binary(query) -> true
      _ -> false
    end
  end

  def extract_decks(new_code) do
    extracted = extract_codes(new_code)

    cond do
      extracted != [] ->
        extracted

      HSDeckViewer.hdv_link?(new_code) ->
        HSDeckViewer.extract_codes(new_code)

      Yaytears.yt_link?(new_code) ->
        Yaytears.extract_codes(new_code)

      HSReplay.hsreplay_link?(new_code) ->
        case HSReplay.extract_deck(new_code) do
          {:ok, deck} -> [Deck.deckcode(deck)]
          _ -> []
        end

      our_link?(new_code) ->
        extract_codes(new_code)

      true ->
        [new_code]
    end
    |> Deck.shorten_codes()
  end

  def extract_codes(link_or_code, opts \\ []) do
    query_params = Keyword.get(opts, :query_params, ["deckcode", "code", "deckcodes", "codes"])
    separators = Keyword.get(opts, :separators, [",", ".", "|"])
    parsed = URI.parse(link_or_code)

    from_query_potential =
      with %{query: query_raw, host: h} when is_binary(query_raw) and is_binary(h) <- parsed,
           query <- URI.decode_query(query_raw) do
        Map.take(query, query_params)
        |> Map.values()
      else
        _ -> []
      end

    # extract from path
    potential =
      [link_or_code | from_query_potential] ++
        for %{host: h, path: path} when is_binary(h) and is_binary(path) <- [parsed],
            part <- String.split(parsed.path, "/"),
            decoded = URI.decode(part),
            # add link to potential incase the whole thing is valid
            do: decoded

    for val <- potential,
        code <- String.split(val, separators),
        Deck.valid?(code),
        do: code
  end

  def our_link?(new_code) when is_binary(new_code),
    do: new_code =~ "d0nkey.top" or new_code =~ "hsguru.com"

  def our_link?(_), do: false
end
