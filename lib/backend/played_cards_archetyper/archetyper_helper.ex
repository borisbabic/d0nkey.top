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
    Enum.find_value(config, fallback, fn
      {archetype, {cards, exclude}} when is_list(cards) and is_list(exclude) ->
        if any?(card_info, cards) and not any?(card_info, exclude) do
          archetype
        else
          nil
        end

      {archetype, cards} ->
        if any?(card_info, cards) do
          archetype
        else
          nil
        end
    end)
  end

  @spec process_config(list(), map()) :: list()
  def add_excludes(config, excludes_map) do
    Enum.map(config, fn
      {archetype, {cards, excludes}} ->
        new_excludes = excludes ++ Map.get(excludes_map, archetype, [])
        {archetype, {cards, new_excludes}}

      {archetype, cards} ->
        excludes = Map.get(excludes_map, archetype, [])
        {archetype, {cards, excludes}}
    end)
  end
end
