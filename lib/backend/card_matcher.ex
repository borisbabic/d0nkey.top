defmodule Backend.CardMatcher do
  @moduledoc "Match cards based on name"
  @min_distance 0.85
  def match_name(cards, card_name, cutoff \\ @min_distance) do
    cards
    |> prepared_match()
    |> match_optimized(card_name, cutoff)
  end

  def match_optimized(prepared_cards, card_name, cutoff \\ @min_distance) do
    composed = Akin.Util.compose(card_name)

    # overlap is MUCH faster, if it's too low to hit the cutoff no point doing the more expensive algo
    overlap_cutoff = 1 - 2 * (1 - cutoff)

    Enum.flat_map(prepared_cards, fn {cached, card} ->
      with overlap when overlap >= overlap_cutoff <- Akin.Overlap.compare(composed, cached, []),
           sdm <- Akin.SubstringDoubleMetaphone.compare(composed, cached, []),
           similarity when similarity >= cutoff <- (overlap + sdm) / 2 do
        [{similarity, card}]
      else
        _ -> []
      end
    end)
    |> Enum.sort_by(&elem(&1, 0), :desc)
  end

  def prepared_match(cards) do
    Enum.map(cards, fn c -> {Akin.Util.compose(c.name), c} end)
  end
end
