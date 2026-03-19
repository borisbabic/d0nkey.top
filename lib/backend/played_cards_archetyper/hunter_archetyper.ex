# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.HunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Hunter", ["The Food Chain"]},
    {:"Tick Tock Hunter", ["Battle at the End Time"]},
    {:"Imbue Hunter",
     [
       "Petal Picker",
       "Bitterbloom Knight",
       "Umbraclaw",
       "Resplendent Dreamweaver",
       "Flutterwing Guardian"
     ]},
    {:"Dragon Hunter",
     [
       "Tormented Dreadwing",
       "Netherspite Historian",
       "Prescient Slitherdrake",
       "Whlpe of the Infinite",
       "Petal Peddler",
       "Darkscale Broodmother",
       "Portal Vanguard"
     ]},
    {:"No Hand Hunter",
     [
       "Precise Shot",
       "Rockskipper",
       "Confront the Tol'vir",
       "Brutish Endmaw",
       "Arrow Retriever",
       "Sylvanas's Triumph",
       "Sizzling Cinder",
       "Niri of the Crater",
       "Arcane Shot",
       "Quel'dorei Fletcher",
       "Raptor-Nest Nurse",
       "Glacial Shard",
       "Reinforcement Rallier",
       "Slumbering Sprite",
       "Wound Prey",
       "Platysaur",
       "Wormhole",
       "Ranger General Sylvanas",
       "Ranger Captain Alleria",
       "Ranger Initiate Vereesa",
       "Quick Shot",
       "Tracking",
       "Dreambound Raptor"
     ]},
    # 5.5
    {:"Dragon Druid", ["Carrier Whelp", "Shadowed Informant"]}
  ]
  @wild_config []

  def standard_excludes(), do: %{}
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, standard_excludes())
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Hunter")
  end

  def wild(_card_info) do
    nil
  end
end
