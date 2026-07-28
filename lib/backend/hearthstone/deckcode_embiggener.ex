defmodule Backend.Hearthstone.DeckcodeEmbiggener do
  @moduledoc false
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Card
  alias Backend.Hearthstone
  @type style :: :basic | :pretty

  @doc """
  Takes a deck or deckcode and produces a long form deckcode
  """
  @spec embiggen(Deck.t() | String.t()) :: String.t()
  def embiggen(deckcode) when is_binary(deckcode), do: deckcode |> Deck.decode!() |> embiggen()

  def embiggen(%{cards: cards, deckcode: deckcode} = d) do
    deck_name = Deck.name(d)
    card_sort_opts = [cost: &Deck.card_mana_cost(d, &1)]

    cards_part =
      cards
      |> Hearthstone.ordered_frequencies(card_sort_opts)
      |> Enum.flat_map(fn {card, freq} ->
        card_sideboards =
          d.sideboards
          |> Enum.filter(&(&1.sideboard == card.id))
          |> Hearthstone.sort_cards(card_sort_opts)
          |> Enum.map(&{Hearthstone.get_card(&1.card), Card.multiply_count_for_sideboard(&1), "  "})
          |> Enum.filter(&elem(&1, 0))

        [{card, freq, ""} | card_sideboards]
      end)
      |> Enum.map_join("\n", &create_card_part(&1, d))

    link_part = link_part(d)

    """
    ### #{deck_name}
    # Cost: #{Deck.cost(d)}
    # Format: #{Deck.format_name(d.format)}
    #{cards_part}
    #{deckcode}
    #{link_part}
    """
  end

  def create_card_part({card, freq, sideboard_prefix}, deck) do
    rarity = Card.rarity_square(card)

    "# #{rarity} #{sideboard_prefix}#{freq}x (#{Deck.card_mana_cost(deck, card)}) #{card.name}"
  end

  defp link_part(%{id: id}) when is_integer(id) do
    """
    ### You can view this deck at https://www.hsguru.com/deck/#{id}
    """
  end

  defp link_part(_), do: ""

  def with_name(%{deckcode: deckcode} = d) do
    deck_name = Deck.name(d)
    link_part = link_part(d)

    """
    ### #{deck_name}
    #{deckcode}
    #{link_part}
    """
  end
end
