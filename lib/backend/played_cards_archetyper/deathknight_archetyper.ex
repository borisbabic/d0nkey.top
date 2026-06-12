# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DeathKnightArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest DK", ["Reanimate the Terror"]},
    {:"Harold DK",
     [
       "Staff of the Endbringer",
       "Deathwing, Worldbreaker",
       "Obsessive Technician",
       "Ultraxion",
       "Arisen Onyxia",
       "Envoy of the End",
       "Experimental Animation",
       "Memoriam Manifest",
       "The Curator",
       "Soulrest Ceremony"

       # "Boneguard Commander" 
     ]},
    {:"Unholy DK",
     [
       "Grave Strength",
       "Maze Guide",
       "Living Paradox",
       "Talanji's Last Stand"
     ]},
    # {:"Imbue DK",
    #  [
    #    "Petal Picker",
    #    "Bitterbloom Knight",
    #    "Jagged Edge of Time",
    #    "Finality",
    #    "Flutterwing Guardian"
    #  ]},
    {:"Harold DK",
     [
       "Hematurge",
       "Elise the Navigator"
     ]},
    {:"Unholy DK",
     [
       "Monstrous Mosquito",
       "Talanji's Last Stand",
       "Shadows of Yesterday"
     ]},
    # 5.5
    {:"Imbue DK",
     [
       "Jagged Edge of Time",
       "Flutterwing Guardian",
       "Petal Picker",
       "Bitterbloom Knight"
     ]},
    {:"Harold DK",
     [
       "Shadowed Informant",
       "Morbid Swarm"
     ]},
    {:"Blood DK",
     [
       "Ursoc",
       "Crittter Caretaker",
       "Fyrakk the Blazing",
       "Ancient of Yore",
       "Alexandros Mograine",
       "Naralex, Herald of the Flights",
       "Death Strike"
     ]},
    {:"Harold DK",
     [
       "Infested Breath",
       "Husk, Eternal Reaper",
       "Royal Librarian"
     ]},
    {:"Unholy DK",
     [
       "Nerubian Swawmguard",
       "Falric",
       "Chow Down",
       "Nerubian Swarmguard",
       "Twilight Egg"
     ]},
    # 10.5
    {:"Harold DK",
     [
       "Sanguine Infestation",
       "Creature of Madness",
       "Nightmare Lord Xavius",
       "Hideous Husk",
       "Sands of Time",
       "Poison Breath",
       "Wild Pyromancer",
       "Chillfallen Baron"
     ]},
    {:"Unholy DK",
     [
       "Reluctant Wrangler",
       "Ancient Raptor",
       "Murmy"
     ]}
  ]

  @wild_config []

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other DK")
  end

  def wild(card_info) do
    process_config(@wild_config, card_info, :"Other DK")
  end
end
