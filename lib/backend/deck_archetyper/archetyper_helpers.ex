defmodule Backend.DeckArchetyper.ArchetyperHelpers do
  @moduledoc false
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Card

  ####
  # if a function starts with defp that means it's private and wont be used by modules that import this
  # for most helpers you move here you want to change it to def
  # if you're unsure just thischange to def

  @type card_info :: %{
          card_names: [String.t()],
          full_cards: [Card.t()],
          cards: [integer()],
          deck: Deck.t(),
          zilliax_sideboard_names: [String.t()],
          etc_sideboard_names: [String.t()]
        }

  @spec full_cards(Deck.t()) :: card_info()
  def full_cards(%{cards: cards} = deck) do
    {full_cards, card_names} =
      Enum.map(cards, fn c ->
        with card = %{name: name} <- Backend.Hearthstone.get_card(c) do
          {card, name}
        end
      end)
      |> Enum.filter(& &1)
      |> Enum.unzip()

    zilliax_modules_names =
      Map.get(deck, :sideboards, []) |> Deck.zilliax_modules_cards() |> Enum.map(& &1.name)

    etc_sideboard_names =
      Map.get(deck, :sideboards, []) |> Deck.etc_sideboard_cards() |> Enum.map(& &1.name)

    %{
      full_cards: full_cards,
      card_names: card_names,
      cards: cards,
      deck: deck,
      zilliax_modules_names: zilliax_modules_names,
      etc_sideboard_names: etc_sideboard_names
    }
  end

  @spec baku?(card_info()) :: boolean()
  def baku?(%{card_names: card_names}), do: "Baku the Mooneater" in card_names
  @spec genn?(card_info()) :: boolean()
  def genn?(%{card_names: card_names}), do: "Genn Greymane" in card_names

  @spec min_count?(card_info() | [String.t()], integer(), [String.t()]) :: boolean()
  def min_count?(%{card_names: card_names}, min, cards) do
    min_count?(card_names, min, cards)
  end

  def min_count?(card_names, min, cards) do
    min <= cards |> Enum.filter(&(&1 in card_names)) |> Enum.count()
  end

  @spec all_odd?(card_info()) :: boolean()
  def all_odd?(%{deck: deck, full_cards: full_cards}), do: all_cost_rem?(deck, full_cards, 1)
  @spec all_even?(card_info()) :: boolean()
  def all_even?(%{deck: deck, full_cards: full_cards}), do: all_cost_rem?(deck, full_cards, 0)

  defp all_cost_rem?(deck, cards, remainder, divisor \\ 2) do
    cards
    |> Enum.filter(& &1)
    |> Enum.reject(fn card ->
      cost = Deck.card_mana_cost(deck, card)
      cost && remainder == rem(cost, divisor)
    end)
    |> Enum.empty?()
  end

  @neutral_excavate ["Kobold Miner", "Burrow Buster"]
  @standard_neutral_spell_damage [
    "Bloodmage Thalnos",
    "Kobold Geomancer",
    "Rainbow Glowscale",
    "Silvermoon Arcanist",
    "Azure Drake"
  ]

  def neutral_excavate(), do: @neutral_excavate
  def neutral_spell_damage(), do: @standard_neutral_spell_damage
end
