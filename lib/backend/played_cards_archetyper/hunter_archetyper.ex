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
       "Flutterwing Guardian"
     ]},
    {:"Amalgam Hunter",
     [
       "Adaptive Amalgam",
       "Trusty Fishing Rod",
       "Cloud Serpent",
       "Sailboat Captain",
       "Lunar Trailblazer",
       "Devilsaur Mask"
     ]},
    # 5.5
    {:"Starship Hunter", ["Specimen Claw", "The Exodar", "Laser Barrage"]},
    {:"Handbuff Hunter",
     [
       "Bumbling Bellhop",
       "Mythical Runebear",
       "Cup o'Muscle",
       "Cup o' Muscle",
       "Reserved Spot",
       "Ranger Gilly"
     ]},
    {:"Mystery Egg Hunter", ["Chatty Macaw", "Mystery Egg", "Death Roll", "Furious Fowls"]},
    {:"Discover Hunter",
     [
       "Parallax Cannon",
       "Bloodmage Thalnos",
       "Cult Neophyte",
       "Astral Vigilant",
       "Incindius",
       "Youthful Brewmaster"
     ]},
    {:"Amalgam Hunter", ["Observer of Mysteries", "Rustrot Viper", "Troubled Mechanic"]},
    # 10.5
    {:"Egg Hunter",
     [
       "Gorm the Worldeater",
       "Escape Pod",
       "Stranglevine",
       "Pterrordax Egg",
       "Holy Eggbearer",
       "The Egg of Khelos",
       "Dissolving Ooze",
       "Doomsayer",
       "Crazed Alchemist",
       "Amphibian's Spirit",
       "Extraterrestrial Egg",
       "Cubicle",
       "Endbringer Umbra"
     ]},
    {:"Discover Hunter",
     [
       "Shaladrassil",
       "Blob of Tar",
       "Customs Enforcer",
       "Zilliax Deluxe 3000",
       "Beast Speaker Taka",
       "Rockskipper",
       "Elise the Navigator",
       "The Ceaseless Expanse",
       "Sasquawk",
       "Bob the Bartender",
       "Glacial Shard",
       "Niri of the Crater",
       "Creature of Madness",
       "Tidepool Pupil",
       "Alien Encounters",
       "Mixologist",
       "Ragnari Scout",
       "Parrot Sanctuary",
       "Nightmare Lord Xavius",
       "Arcane Shot",
       "Birdwatching",
       "Exarch Naielle"
     ]},
    {:"Beast Hunter",
     [
       "Shepherd's Crook",
       "Scarab Keychain",
       "Supreme Dinomancy",
       "Jungle Gym",
       "Fetch!",
       "R.C. Rampage",
       "Remote Control"
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
