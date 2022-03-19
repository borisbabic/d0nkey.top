defmodule Backend.Hearthstone.DeckcodeEmbiggener do
  @moduledoc false
  alias Backend.HearthstoneJson
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone

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
      |> Enum.map(fn {c, freq} ->
        "# #{freq}x (#{c.cost}) #{c.name}"
      end)
      |> Enum.join("\n")

    """
    ### #{class_name}
    # Class: #{class_name}
    # Format: #{format |> Deck.format_name()}
    #
    #{cards_part}
    #
    #{deckcode}
    #
    # To use this deck, copy it to your clipboard and create a new deck in Hearthstone
    """
  end

  @spec class_name(Deck.t()) :: String.t()
  defp class_name(d) do
    (d.class || HearthstoneJson.get_class(d.hero))
    |> String.upcase()
    |> Deck.class_name()
  end
end
