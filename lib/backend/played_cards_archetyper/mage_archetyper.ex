# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.MageArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @spell_mage_first [
    "Spot the Difference",
    "Manufacturing Error",
    "Yogg in the Box"
  ]
  @quest_mage_first [
    "Raptor Herald",
    "Relentless Wrathguard",
    "Treacherous Tormentor",
    "Stonehill Defender",
    "Questing Assistant",
    "Beast Speaker Taka"
  ]
  @arkwing_first [
    "Grillmaster",
    "Divine Brew",
    "Marooned Archmage",
    "Raylla, Sand Sculptor",
    "Vicious Slitherspear",
    "Metal Detector",
    "Oh, Manager!",
    "Stellar Balance",
    "Flame Geyser",
    "Ingenious Artificer",
    "Violet Spellwing",
    "Troubled Mechanic",
    "Go with the Flow",
    "Arkwing Pilot"
  ]
  @standard_excludes %{
    :"Arkwing Mage" => ["The Forbidden Sequence"],
    :"Spell Mage" => @quest_mage_first,
    :"Quest Mage" => @spell_mage_first
  }
  @standard_config [
    # {:"Quest Mage", ["The Forbidden Sequence"]},
    {:"Spell Mage", @spell_mage_first},
    {:"Elemental Mage",
     [
       "Blazing Accretion",
       "Lamplighter",
       "Fire Fly",
       "Triplewick Trickster",
       "Windswept Pageturner",
       "Solar Flare",
       "Spontaneous Combustion"
     ]},
    {:"Protoss Mage",
     [
       "Busy Peon",
       "Warp Gate",
       "Colossus",
       "Resonance Coil",
       "Chrono Boost",
       "Artanis",
       "Void Ray"
     ]},
    {:"Arcane Mage",
     [
       "Arcane Intellect",
       "Azure Queen Sindragosa",
       "Azure King Malygos",
       "Azure Oathstone",
       "Arcane Barrage"
       # "Portal Vanguard"
       # "Buy One, Get One Freeze",
       # "Stellar Balance"
     ]},
    {:"Quest Mage", @quest_mage_first},
    # 5.5
    {:"Imbue Mage",
     [
       "Sing-Along Buddy",
       "Bitterbloom Knight",
       "Spirit Gatherer",
       "Resplendent Dreamweaver",
       "Petal Picker",
       "Flutterwing Guardian",
       "Divination",
       # "Aessina",
       "Wisprider"
     ]},
    {:"Arkwing Mage", @arkwing_first},
    {:"Spell Mage", ["Malfunction"]},
    {:"Orb Mage",
     [
       "Carry-On Grub",
       "The Curator",
       "Sharp-Eyed Lookout",
       "Overplanner",
       "Sleepy Resident"
     ]},
    {:"Toki Mage",
     [
       "Wisp",
       "Youthful Brewmaster",
       "Demolition Renovator",
       "Puzzlemaster Khadgar",
       "Timelooper Toki",
       "Kil'jaedan",
       "Dirty Rat",
       "Alter Time",
       "Smoldering Grove",
       "Rising Waves",
       "Seabreeze Chalice",
       "Joymancer Jepetto",
       "Marin the Manager",
       "The Ceaseless Expanse",
       "Steamcleaner",
       "Ysera, Emerald Aspect",
       "Arcane Artificer",
       "Bob the Bartender",
       "Sleet Skater",
       "Dreamplanner Zephyrs",
       "Rustrot Viper",
       "Eternal Firebolt",
       "Kil'jaeden",
       "Zilliax Deluxe 3000",
       "Warmaster Blackhorn",
       "Blob of Time",
       "Elise the Navigator"
     ]},
    # 10.5
    {:"Quest Mage", ["Scrappy Scavenger", "Ingenious Artificer", "Troubled Mechanic"]},
    {:"Protoss Mage", ["Photon Cannon"]},
    {:"Arcane Mage", ["Watercolor Artist"]},
    {:"Quest Mage",
     ["Tidepool Pupil", "Creature rof Madness", "Techysaurus", "The Forbidden Sequence"]},
    {:"Spell Mage", ["Hidden Objects", "Pocket Dimension", "The Forbidden Sequence"]},
    # 15.5
    {:"Arcane Mage", ["Primordial Glyph", "Tide Pools"]},
    {:"Elemental Mage",
     [
       "Cloud Serpent",
       "Blasteroid"
     ]},
    {:"Protoss Mage", ["Shield Battery"]},
    {:"Bot? Mage",
     [
       "Ice Barrier",
       "Oasis Ally",
       "Babbling Bookcase",
       "Flamestrike",
       "Kobold Geomancer",
       "Explosive Runes",
       "Counterspell",
       "Firelands Portal",
       "Bloodmage Thalnos",
       "Frostbolt"
     ]},
    {:"Elemental Mage",
     [
       "Conjured Bookkeeper",
       "Glacial Shard",
       "Living Flame",
       "Sizzling Cinder"
     ]}
    # 20.5
    # {:"Spell Mage", ["The Forbidden Sequence", "Frostbolt", "Rising Waves", "Tide Pools"]}
  ]
  @wild_config []

  def standard_excludes(), do: @standard_excludes
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, @standard_excludes)
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Mage")
  end

  def wild(_card_info) do
    nil
  end
end
