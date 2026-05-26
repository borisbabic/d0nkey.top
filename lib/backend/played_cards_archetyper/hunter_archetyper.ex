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
    {:"Companion Hunter",
     [
       "Roam Free",
       "Call of the Wild",
       "Migrating Elekk",
       "Animal Companion",
       "Talya Earthstrider",
       "Critter Caretaker",
       "Broll Bearmantle",
       "Spiritspeaker",
       "Nightmare Lord Xavius",
       "Crazed Alchemist"
     ]},
    {:"No Hand Hunter",
     [
       "Arcane Shot",
       "Arrow Retriever",
       "Bloodmage Thalnos",
       "Brutish Endmaw",
       # "Confront the Tol'vir",
       "Dreambound Raptor",
       "Glacial Shard",
       "Niri of the Crater",
       "Platysaur",
       "Precise Shot",
       "Quel'dorei Fletcher",
       "Quick Shot",
       "Reinforcement Rallier",
       "Rockskipper",
       "Shepherd's Crook",
       "Sizzling Cinder",
       "Slumbering Sprite",
       "Sylvanas's Triumph",
       "Wormhole"
     ]},
    # 5.5
    {:"Dragon Hunter",
     [
       "Carrier Whelp",
       "Darkscale Broodmother",
       "Netherspite Historian",
       "Petal Peddler",
       "Prescient Slitherdrake",
       "Tormented Dreadwing",
       "Whelp of the Infinite",
       "Whlpe of the Infinite"
     ]},
    {:"Companion Hunter",
     [
       "Confront the Tol'vir",
       "Ranger Captain Alleria",
       "Ranger General Sylvanas",
       "Ranger Initiate Vereesa",
       "Raptor-Nest Nurse",
       "Sands of Time",
       "Tame Pet",
       "Tracking",
       "Wound Prey"
     ]},
    {:"Dragon Hunter",
     [
       "Portal Vanguard",
       "Tol'vir Carver"
     ]}
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
