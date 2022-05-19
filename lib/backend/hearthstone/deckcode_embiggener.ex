defmodule Backend.Hearthstone.DeckcodeEmbiggener do
  @moduledoc false
  alias Backend.HearthstoneJson
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone
  @type style :: :basic | :pretty

  @doc """
  Takes a deck or deckcode and produces a long form deckcode
  """
  @spec embiggen(Deck.t() | String.t()) :: String.t()
  def embiggen(deckcode) when is_binary(deckcode), do: deckcode |> Deck.decode!() |> embiggen()

  def embiggen(d = %{cards: cards, deckcode: deckcode, format: format}) do
    class_name = d |> class_name()

    cards_part =
      cards
      |> Hearthstone.ordered_frequencies()
      |> Enum.map_join("\n", &create_card_part(&1))

    link_part =
      case Map.get(d, :id) do
        nil -> ""
        id -> "You can view this deck at https://www.d0nkey.top/deck/#{id}"
      end

    """
    ### #{class_name}
    # Class: #{class_name}
    # Format: #{format |> Deck.format_name()}
    # Cost: #{Deck.cost(d)}
    #
    #{cards_part}
    #
    #{deckcode}
    # #{link_part}
    # To use this deck, copy it to your clipboard and create a new deck in Hearthstone
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

  @spec class_name(Deck.t()) :: String.t()
  defp class_name(d) do
    (d.class || HearthstoneJson.get_class(d.hero))
    |> String.upcase()
    |> Deck.class_name()
  end
end
