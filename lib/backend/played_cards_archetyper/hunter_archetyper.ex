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
    {:"Discover Hunter",
     [
       "Incindius",
       "Glacial Shard",
       "Tidepool Pupil",
       "Youthful Brewmaster",
       "Parrot Sanctuary",
       "Bob the Bartender",
       "Parallax Cannon",
       "Card Grader",
       "Astral Vigilant",
       "Mixologist",
       "Alien Encounters",
       "Griftah, Trusted Bendor",
       "Rangari Scout",
       "Griftah, Trusted Vendor",
       "Travel Agent",
       "Elise the Navigator",
       "The Ceaseless Expanse",
       "Zilliax Deluxe 3000",
       "Wisp",
       "Nightmare Lord Xavius"
     ]},
    {:"Imbue Hunter",
     [
       "Petal Picker",
       "Bitterbloom Knight",
       "Umbraclaw",
       "Resplendent Dreamweaver",
       "Exotic Houndmaster",
       "Magma Hound",
       "Flutterwing Guardian"
     ]},
    {:"Beast Hunter",
     [
       "City Chief Esho",
       "Ball of Spiders",
       "Mother Duck"
     ]},
    # 5.5
    {:"No Hand Hunter",
     [
       "Rockskipper",
       "Vicious Slitherspear",
       "Precise Shot",
       "King Maluk",
       "Wormhole",
       "Arrow Retriever",
       "Devious Coyote",
       "Zergling"
     ]},
    {:"Zerg Hunter",
     [
       "Hydralisk",
       "Evolution Chamber",
       "Spawning Pool",
       "Roach",
       "Hive Queen"
     ]},
    {:"Beast Hunter", ["Painted Canvasaur"]},
    {:"No Hand Hunter", ["Quick Shot", "Quel'dorei Fletcher", "Sizzling Cinder"]},
    # 10.5
    {:"Beast Hunter", ["Paltry Flutterwing"]},
    {:"Discover Hunter", ["Scarab Keychain", "Exarch Naielle"]},
    {:"Discover Hunter",
     [
       "Birdwatching",
       "Tracking",
       "Ranger Initiate Vereesa",
       "Ranger General Sylvanas",
       "Ranger Captain Alleria"
     ]},
    {:"Starship Hunter", ["Specimen Claw", "The Exodar", "Dimensional Barrage"]},
    {:"Handbuff Hunter",
     [
       "Bumbling Bellhop",
       "Mythical Runebear",
       "Cup o'Muscle",
       "Cup o' Muscle",
       "Reserved Spot",
       "Ranger Gilly"
     ]}
    # 15.5
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
