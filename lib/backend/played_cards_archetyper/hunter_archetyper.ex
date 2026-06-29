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
       # "Nightmare Lord Xavius",
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
       # "Niri of the Crater",
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
       "Niri of the Crater",
       "Wound Prey"
     ]},
    {:"Dragon Hunter",
     [
       "Portal Vanguard",
       "Tol'vir Carver"
     ]}
  ]
  @wild_config [
    "Boar Hunter": ["Elwynn Boar"],
    "Secret Hunter": ["Eversong Portal"],
    "Amalgam Hunter": ["Adaptive Amalgam"],
    "XL Highlander Hunter": ["Mojomaster Zihi"],
    "Highlander Hunter": ["Trusty Fishing Rod"],
    "Beast Hunter": ["Painted Canvasaur"],
    "XL Highlander Hunter": ["Astalor Bloodsworn", "Boompistol Bully", "Irondeep Trogg", "Misdirection"],
    "STD No Hand Hunter": ["Arrow Retriever", "Sizzling Cinder"],
    "STD Companion Hunter": ["Critter Caretaker"],
    "XL HL Leoroxx Hunter": ["Hydralodon"],
    "XL Hunter": ["Sing-Along Buddy"],
    "XL Highlander Hunter": ["Kerrigan, Queen of Blades"],
    "Secret Hunter": ["Starstrung Bow"],
    "LC Quest Hunter": ["The Food Chain"],
    "Leoroxx Hunter": ["Ten Gallon Hat"],
    "XL HL Leoroxx Hunter": ["Beastmaster Leoroxx", "Elise the Navigator"],
    "XL Highlander Hunter": ["Far Watch Post", "Spawning Pool"],
    "STD No Hand Hunter": ["Quel'dorei Fletcher"],
    "Boar Hunter": ["Bola Shot"],
    "XL Hunter": ["Bitterbloom Knight", "Flutterwing Guardian", "Umbraclaw"],
    "XL HL Leoroxx Hunter": ["Tundra Rhino"],
    "Dragon Hunter": ["Petal Peddler"],
    "Highlander Hunter": ["Dreamplanner Zephrys"],
    "XL Highlander Hunter": ["Beaststalker Tavish", "Observer of Myths", "Sneaky Snakes", "ZOMBEEEES!!!"],
    "Secret Hunter": ["Wandering Monster"],
    "Boar Hunter": ["Selective Breeder"],
    "XL HL Leoroxx Hunter": ["Hope of Quel'Thalas"],
    "Beast Hunter": ["Pet Collector"],
    "Questline Hunter": ["Defend the Dwarven District", "Platysaur"],
    "XL Secret Hunter": ["Trueaim Crescent"],
    "XL HL Leoroxx Hunter": ["Miracle Salesman", "Razorscale", "Troubled Mechanic", "Wild Spirits"],
    "Highlander Hunter": ["Theldurin the Lost"],
    "STD Companion Hunter": ["Migrating Elekk", "Talya Earthstrider"],
    "Boar Hunter": ["Rangari Scout"]
  ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Hunter")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Hunter")
  end
end
