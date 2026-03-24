# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarriorArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Warrior",
     [
       "Enter the Lost City"
     ]},
    {:"Dragon Warrior",
     [
       "Darkscale Broodmother",
       "Petal Peddler",
       "Prescient Slitherdrake",
       "Carrier Whelp",
       "Shadowed Informant",
       "Stadium Announcer",
       "Brood Keeper"
     ]},
    {:"Gladiator Warrior",
     [
       "Gladiatorial Combat",
       "Shaladrassil",
       "Succumb to Madness",
       "Clutch of Corruption",
       "Tortolla",
       "Ysondre"
     ]},
    {:"Egg Warrior",
     [
       "Holy Eggbearer",
       "Endbringer Umbra",
       "Abusive Sergeant",
       "Siphoning Growth",
       "Heir of Hereafter",
       "Shellnado",
       "The Egg of Khelos"
     ]},
    {:"Harold Warrior",
     [
       "Living Flame",
       "Time-Twisted Seer",
       "Elise the Navigator",
       "Envoy of the End",
       "Ragnaros, the Great Fire",
       "Ultraxion",
       "Deathwing, Worldbreaker"
     ]},
    # 5.5
    {:"Dragon Warrior",
     [
       "Windpeak Wyrm",
       "Darkrider"
     ]},
    {:"Harold Warrior",
     [
       "Scorching Ravager",
       "Cataclysmic War Axe"
     ]},
    {:"Gladiator Warrior",
     [
       "Erupting Volcano",
       "Shadowflame Suffusion",
       "Searing Fissure"
     ]},
    {:"Egg Warrior",
     [
       "Decimation",
       "Acolyte of Pain",
       "Sanguine Depths"
     ]},
    {:"Gladiator Warrior",
     [
       "For Glory!",
       "Torch",
       "Axe of the Forefathers",
       "Eternal Toil",
       "Shield Block"
     ]},
    # 10.5
    {:"Precursory Strike", ["Dragon Warrior"]}
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
