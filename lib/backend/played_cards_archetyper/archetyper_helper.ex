defmodule Backend.PlayedCardsArchetyper.ArchetyperHelper do
  @moduledoc false

  defdelegate quest?(card_info), to: Backend.DeckArchetyper.ArchetyperHelpers

  def any?(%{card_names: search_card_names}, target_card_names),
    do: any?(search_card_names, target_card_names)

  def any?(search_card_names, target_card_names) do
    Enum.any?(search_card_names, &(&1 in target_card_names))
  end

  @spec process_config(list(), any(), atom() | nil) :: atom() | nil
  def process_config(config, card_info, fallback \\ nil) do
    Enum.find_value(config, fallback, fn {archetype, cards} ->
      if any?(card_info, cards) do
        archetype
      else
        nil
      end
    end)
  end
end
