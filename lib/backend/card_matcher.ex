defmodule Backend.CardMatcher do
  @moduledoc "Match cards based on name"
  @min_jaro_distance 0.85
  def match_name(cards, card_name, cutoff \\ @min_jaro_distance) do
    Enum.flat_map(cards, fn card ->
      distance_orig = do_distance(card_name, card.name)
      distance_normalized = do_distance(card_name, card.name, &normalize_card_name/1)

      piece_distance = piece_distance(card, card_name, cutoff)
      distance = Enum.max([distance_orig, distance_normalized, piece_distance])

      if distance >= cutoff do
        [{distance, card}]
      else
        []
      end
    end)
    |> Enum.sort_by(&elem(&1, 0), :desc)
  end

  defp piece_distance(card, card_name, cutoff) do
    piece_values =
      String.split(card.name, " ")
      |> Enum.filter(&(String.length(&1) > 2))
      |> Enum.flat_map(fn piece ->
        [
          do_distance(piece, card_name),
          do_distance(piece, card_name, &normalize_card_name/1)
        ]
      end)

    case piece_values do
      [_ | _] ->
        piece_values
        |> Enum.max()
        |> Kernel.*(cutoff)

      _ ->
        0
    end
  end

  defp do_distance(first, second, normalizer \\ &String.downcase/1) do
    String.jaro_distance(normalizer.(first), normalizer.(second))
  end

  defp normalize_card_name(name) do
    name
    |> String.replace("(Rank 1)", "")
    |> String.replace(~r/[,\-';:]/, "")
    |> String.downcase()
    |> String.trim()
  end
end
