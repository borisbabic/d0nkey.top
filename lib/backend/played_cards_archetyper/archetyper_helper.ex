defmodule Backend.PlayedCardsArchetyper.ArchetyperHelper do
  @moduledoc false

  defdelegate quest?(card_info), to: Backend.DeckArchetyper.ArchetyperHelpers

  def any?(%{card_names: search_card_names}, target_card_names),
    do: any?(search_card_names, target_card_names)

  def any?(search_card_names, target_card_names) do
    Enum.any?(search_card_names, &(&1 in target_card_names))
  end
end
