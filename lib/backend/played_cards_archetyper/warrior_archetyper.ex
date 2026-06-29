# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarriorArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest Warrior": ["Enter the Lost City"],
    "Dragon Warrior": ["Darkscale Broodmother", "Petal Peddler"],
    "Burn Warrior": ["Rockskipper"],
    "Gladiator Warrior": ["Gladiatorial Combat"],
    "Dragon Warrior": [
      "Brood Keeper",
      "Carrier Whelp",
      "Cult Neophyte",
      "Prescient Slitherdrake",
      "Shadowed Informant",
      "Stadium Announcer",
      "Twilight Egg",
      "Windpeak Wyrm"
    ],
    "Harold Warrior": ["Chrono-Lord Deios", "Ragnaros, the Great Fire"],
    "Burn Warrior": ["Time-Twisted Seer"],
    "Harold Warrior": ["Cataclysmic War Axe", "Envoy of the End", "Scorching Ravager", "Ultraxion"],
    "Burn Warrior": ["Prize Vendor"],
    "Egg Warrior": ["Decimation", "Endbringer Umbra"],
    "Dragon Warrior": ["Darkrider"],
    "Egg Warrior": ["Holy Eggbearer", "Nablya, the Watcher", "The Egg of Khelos"],
    "Burn Warrior": ["Bash", "Erupting Volcano", "Searing Fissure"],
    "Gladiator Warrior": ["Clutch of Corruption", "Eternal Toil", "Slam", "Torch", "Unleash the Crocolisks"],
    "Dragon Warrior": ["Sanguine Depths"]
  ]
  @wild_config []

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Warrior")
  end

  def wild(card_info) do
    process_config(@wild_config, card_info, :"Other Warrior")
  end
end
