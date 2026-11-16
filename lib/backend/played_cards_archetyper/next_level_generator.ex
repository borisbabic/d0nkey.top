defmodule Backend.PlayedCardsArchetyper.NextLevelGenerator do
  @moduledoc """
  Generates the source code for a new archetyper config level from selected cards.

  Single cards are listed directly, pairs of cards are grouped into `{:all, [[card], partners]}`
  matchers, greedily picking the card that is part of the most remaining pairs first.
  """

  @indent "      "

  @type selection :: [String.t()]

  @doc "Generate the config level source for `archetype` from the selected cards (one or two card names each)"
  @spec generate(String.t(), [selection()]) :: String.t()
  def generate(archetype, selections) do
    {singles, pairs} =
      selections
      |> Enum.map(&Enum.uniq/1)
      |> Enum.uniq()
      |> Enum.split_with(&match?([_], &1))

    entries = Enum.map(singles, &single_entry/1) ++ Enum.map(group_pairs(pairs), &group_entry/1)

    "#{@indent}#{inspect(archetype)}: [\n" <> Enum.join(entries, ",\n") <> "\n#{@indent}],"
  end

  @doc """
  Groups pairs by the card shared by the most pairs

  iex> Backend.PlayedCardsArchetyper.NextLevelGenerator.group_pairs([["A", "B"], ["A", "C"], ["B", "C"]])
  [{"A", ["B", "C"]}, {"B", ["C"]}]
  """
  @spec group_pairs([[String.t()]]) :: [{String.t(), [String.t()]}]
  def group_pairs([]), do: []

  def group_pairs(pairs) do
    main = most_common_card(pairs)
    {with_main, rest} = Enum.split_with(pairs, &(main in &1))
    partners = with_main |> Enum.flat_map(&List.delete(&1, main)) |> Enum.sort()

    [{main, partners} | group_pairs(rest)]
  end

  defp most_common_card(pairs) do
    pairs
    |> List.flatten()
    |> Enum.frequencies()
    |> Enum.min_by(fn {card, count} -> {-count, card} end)
    |> elem(0)
  end

  defp single_entry([card]), do: "#{@indent}  #{inspect(card)}"

  defp group_entry({main, partners}) do
    i = @indent <> "  "

    """
    #{i}{:all,
    #{i} [
    #{i}   [#{inspect(main)}],
    #{i}   [#{Enum.map_join(partners, ", ", &inspect/1)}]
    #{i} ]}\
    """
  end
end
