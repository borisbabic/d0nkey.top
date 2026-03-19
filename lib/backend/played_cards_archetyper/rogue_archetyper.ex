# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.RogueArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Rogue", ["Lie in Wait"]},
    {:"Harold Rogue",
     [
       "Maniacal Follower",
       "Ultraxion",
       "Envoy of the End",
       "Sinestra",
       "Deathwing, Worldbreaker",
       "Rite of Twilight"
     ]},
    # {:"Imbue Rogue",
    #  [
    #    "Flutterwing Guardian",
    #    "Bittbloom Knight",
    #    "Jagged Edge of Time",
    #    "Eventuality"
    #  ]},
    {:"Harold Rogue",
     [
       "Elise the Navigator",
       "Deja Vu",
       "Nightmare Fuel",
       "Foxy Fraud",
       "Flashback",
       "Agent of the Old Ones"
     ]}
  ]
  @wild_config []

  def standard_excludes(), do: %{}
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, standard_excludes())
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Rogue")
  end

  def wild(_card_info) do
    nil
  end
end
