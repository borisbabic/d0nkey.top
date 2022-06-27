defmodule Backend.Hearthstone.DeckcodeEmbiggener do
  @moduledoc false
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone
  @type style :: :basic | :pretty

  @doc """
  Takes a deck or deckcode and produces a long form deckcode
  """
  @spec embiggen(Deck.t() | String.t()) :: String.t()
  def embiggen(deckcode) when is_binary(deckcode), do: deckcode |> Deck.decode!() |> embiggen()

  def embiggen(d = %{cards: cards, deckcode: deckcode}) do
    deck_name = Deck.name(d)

    cards_part =
      cards
      |> Hearthstone.ordered_frequencies()
      |> Enum.map_join("\n", &create_card_part(&1))

    link_part =
      case Map.get(d, :id) do
        nil ->
          ""

        id ->
          """
          You can view this deck at https://www.d0nkey.top/deck/#{id}
          """
      end

    """
    ### #{deck_name}
    # Cost: #{Deck.cost(d)}
    #{cards_part}
    #{deckcode}
    # #{link_part}
    """
  end

  def create_card_part({card, freq}) do
    rarity =
      case card.rarity do
        "LEGENDARY" -> "🟨"
        "EPIC" -> "🟪"
        "RARE" -> "🟦"
        _ -> "⬜"
      end

    "# #{rarity} #{freq}x (#{card.cost}) #{card.name}"
  end
end
