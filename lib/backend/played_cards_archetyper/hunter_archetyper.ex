# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.HunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {
      :"Whizbang Hunter",
      [
        "Yogg-Saron, Master of Fate",
        "Wild Growth",
        "Reliquary of Souls",
        "Infinitize the Maxitude",
        "Beastmaster Leoroxx",
        "Convoke the Spirits",
        "King Krush",
        "Astromancer Solarian",
        "Lor'themar Theron",
        "Astalor Bloodsworn",
        "Serena Bloodfeather",
        "Kun the Forgotten King",
        "Blademaster Okani",
        "Zilliax",
        "Nourish",
        "Velarok Windblade",
        "Emperor Thaurissan",
        "Mister Mukla",
        "Moment of Discovery",
        "Crystal Cluster",
        "Zixor, Apex Predator"
      ]
    },
    {:"Quest Hunter", ["The Food Chain"]},
    {:"Beast Hunter",
     [
       "Mother Duck",
       "City Chief Esho",
       "Ball of Spiders",
       "Jeweled Macaw",
       "Workhorse",
       "Dreambound Raptor",
       "Ancient Raptor",
       "Painted Canvasaur",
       "Catch of the Day",
       "Cower in Fear",
       "Painted Canvasaur"
     ]},
    {:"Imbue Hunter",
     [
       "Sing-Along Buddy",
       "Petal Picker",
       "Bitterbloom Knight",
       "Umbraclaw",
       "Resplendent Dreamweaver",
       "Flutterwing Guardian"
     ]},
    {:"Amalgam Hunter",
     [
       "Adaptive Amalgam",
       "Sailboat Captain",
       "Lunar Trailblazer",
       "Devilsaur Mask"
     ]},
    # 5.5
    {:"Starship Hunter", ["Specimen Claw", "The Exodar", "Dimensional Barrage"]},
    {:"Handbuff Hunter",
     [
       "Bumbling Bellhop",
       "Mythical Runebear",
       "Cup o'Muscle",
       "Cup o' Muscle",
       "Reserved Spot",
       "Ranger Gilly"
     ]},
    {:"Discover Hunter",
     [
       "Parallax Cannon",
       "Glacial Shard",
       "Niri of the Crater",
       "Astral Vigilant",
       "Bloodmage Thalnos",
       "Cult Neophyte",
       "Incindius"
     ]},
    {:"Starship Hunter", ["Arkonite Defense Crystal", "Laser Barrage"]},
    {:"Beast Hunter",
     [
       "Shepherd's Crook",
       "Supreme Dinomancy",
       "Jungle Gym",
       "R.C. Rampage",
       "Remote Control"
     ]},
    # 10.5
    {:"Discover Hunter", ["Biopod"]},
    {:"Mystery Egg Hunter",
     [
       "Mystery Egg",
       "Holy Eggbearer",
       "Patchwork Pals",
       "Terrorscale Stalker",
       "Ankylodon",
       "Sasquawk"
     ]}
    # {:"Discover Hunter",
    #  [
    #    "Rockskipper",
    #    "Parallax Cannon",
    #    "Bloodmage Thalnos",
    #    "Astral Vigilant"
    #  ]},
    # {:"Beast Hunter",
    #  [
    #    "Shepherd's Crook",
    #    "R.C. Rampage",
    #    "Remote Control",
    #    "Jungle Gym",
    #    "Patchwork Pals",
    #    "Painted Canvasaur",
    #    "Fetch!"
    #  ]},
    # {:"Discover Hunter", ["Sasquawk"]},
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Hunter")
  end

  def wild(_card_info) do
    nil
  end
end
