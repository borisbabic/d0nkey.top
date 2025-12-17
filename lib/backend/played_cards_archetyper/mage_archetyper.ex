# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.MageArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    # {:"Quest Mage", ["The Forbidden Sequence"]},
    {:"Spell Mage", ["Spot the Difference", "Manufacturing Error", "Yogg in the Box"]},
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
       "Void Ray",
       "Chrono-Lord Deios"
     ]},
    {:"Arcane Mage",
     [
       "Go with the Flow",
       "Arcane Intellect",
       "Azure Queen Sindragosa",
       "Mirror Dimension",
       "Azure King Malygos",
       "Stellar Balance",
       "Portal Vanguard",
       "Azure Oathstone",
       "Arcane Barrage"
       # "Portal Vanguard"
       # "Buy One, Get One Freeze",
       # "Stellar Balance"
     ]},
    {:"Quest Mage",
     [
       "Raptor Herald",
       "Relentless Wrathguard",
       "Treacherous Tormentor",
       "Astrobiologist",
       "Stonehill Defender",
       "Questing Assistant",
       "Beast Speaker Taka"
     ]},
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
       "Wisprider"
     ]},
    {:"Toki Mage",
     [
       "Wisp",
       "The Ceaseless Expanse",
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
       "Steamcleaner",
       "Ysera, Emerald Aspect",
       "Arcane Artificer",
       "Bob the Bartender",
       "Sleet Skater",
       "Elise the Navigator"
     ]},
    {:"Orb Mage",
     [
       "Carry-On Grub",
       "The Curator",
       "Sharp-Eyed Lookout",
       "Overplanner",
       "Sleepy Resident"
     ]},
    {:"Spell Mage", ["Malfunction"]},
    {:"Quest Mage", ["Scrappy Scavenger"]},
    # {:"Spell Mage",
    #  [
    #    "Buy One, Get One Freeze",
    #    "Stellar Balance",
    #    "Nightmare Lord Xavius"
    #  ]},
    # 10.5
    {:"Protoss Mage", ["Photon Cannon"]},
    # 15.5
    {:"Arcane Mage", ["Watercolor Artist"]},
    {:"Quest Mage", ["Tidepool Pupil"]},
    {:"Spell Mage", ["Hidden Objects", "Pocket Dimension"]},
    {:"Arcane Mage", ["Primordial Glyph", "Tide Pools"]},
    # 20.5
    {:"Elemental Mage",
     [
       "Cloud Serpent",
       "Violet Spellwing",
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
       "Flame Geyser",
       "Sizzling Cinder"
     ]}
    # {:"Spell Mage", ["The Forbidden Sequence", "Frostbolt", "Rising Waves", "Tide Pools"]}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Mage")
  end

  def wild(_card_info) do
    nil
  end
end
