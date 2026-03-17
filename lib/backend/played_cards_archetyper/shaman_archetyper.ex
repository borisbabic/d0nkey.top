# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.ShamanArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Shaman", ["Spirit of the Mountain"]},
    {:"Imbue Shaman",
     [
       "Living Garden",
       "Flutterwing Guardian",
       "Bitterbloom Knight",
       "Petal Picker",
       "Aspect's Embrace",
       "Resplendent Dreamweaver",
       "Glowroot Lure",
       "Plucky Podling"
     ]}
  ]
  @wild_config []

  def standard_excludes(), do: %{}
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, standard_excludes())
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Shaman")
  end

  def wild(_card_info) do
    nil
  end
end
