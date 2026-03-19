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
       "Brood Keeper"
     ]},
    {:"Harold Warrior",
     [
       "Searing Fissure",
       "Cataclysmic War Axe",
       "Scorching Ravager",
       "Envoy of the End",
       "Ragnaros, the Great Fire",
       "Ultraxion"
     ]},
    {:"Egg Warrior",
     [
       "Holy Eggbearer",
       "Endbringer Umbra",
       "Siphoning Growth",
       "Execute",
       "Abusive Sergeant",
       "Shellnado",
       "Decimation",
       "The Egg of Khelos"
     ]},
    {:"Dragon Warrior",
     [
       "Stadium Announcer",
       "Windpeak Wyrm",
       "Darkrider",
       "Shadowflame Suffusion",
       "Precursory Strike",
       "Sanuine Depths",
       "Portal Vanguard",
       "Shadowed Informant",
       "Whelp of the Infinite",
       "Stonecarver",
       "Dimensional Weaponsmith"
     ]},
    {:"Harold Warrior",
     [
       "Living Flame",
       "Time-Twisted Seer"
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
