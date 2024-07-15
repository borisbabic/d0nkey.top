defmodule Backend.HSTopDecks do
  @moduledoc false
  alias Backend.Hearthstone.Deck

  @cards_regex ~r/deck=([0-9:,]+)/
  @format_regex ~r/format=([0-9])+/
  @class_regex ~r/class=([a-zA-Z-]+)/
  def deckbuilder_link?(link) when is_binary(link) do
    Regex.match?(@cards_regex, link) and
      Regex.match?(@format_regex, link) and
      Regex.match?(@class_regex, link)
  end

  def extract_deckbuilder_code(link) do
    [_, cards_part] = Regex.run(@cards_regex, link)
    [_, format] = Regex.run(@format_regex, link)
    [_, class_raw] = Regex.run(@class_regex, link)
    cards = parse_cards(cards_part)
    hero = class_raw |> String.replace("-", "") |> Deck.get_basic_hero()
    format = Util.to_int(format, 2)
    Deck.deckcode(cards, hero, format)
  end

  def parse_cards(cards_part) do
    String.split(cards_part, ",")
    |> Enum.flat_map(fn card_part ->
      [card_id_raw, num] = String.split(card_part, ":")
      card_id = Util.to_int!(card_id_raw)
      for _ <- 1..Util.to_int!(num), do: card_id
    end)
  end

  def to_deckbuilder_link(%Deck{cards: cards, format: format} = deck) do
    cards_part =
      cards
      |> Enum.frequencies()
      |> Enum.map_join(",", fn {card_id, num} -> "#{card_id}:#{num}" end)

    class_part =
      Deck.class(deck) |> Deck.class_name() |> String.downcase() |> String.replace(" ", "-")

    "https://www.hearthstonetopdecks.com/deck-builder/#?class=#{class_part}&format=#{format}&deck=#{cards_part}"
  end
end
