# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarriorArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Warrior",
     [
       "Enter the Lost City"
     ]}
  ]
  @wild_config []

  def standard_excludes(), do: %{}
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, standard_excludes())
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Warrior")
  end

  def wild(_card_info) do
    nil
  end
end
