# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.MageArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    # {:"Quest Mage", ["The Forbidden Sequence"]},
    {:"Spell Mage",
     ["Spot the Difference", "Malfunction", "Manufacturing Error", "Yogg in the Box"]},
    {:"Elemental Mage",
     [
       "Lamplighter",
       "Triplewick Trickster",
       "Blazing Accretion",
       "Windswept Pageturner",
       "Solar Flare",
       "Spontaneous Combustion",
       "Tar Slime"
     ]},
    {:"Quest Mage",
     [
       "Raptor Herald",
       "Relentless Wrathguard",
       "Treacherous Tormentor",
       "Stonehill Defender",
       "Travel Agent",
       "Questing Assistant",
       "Beast Speaker Taka"
     ]},
    {:"Protoss Mage",
     [
       "Warp Gate",
       "Colossus",
       "Resonance Coil",
       "Chrono Boost",
       "Artanis",
       "Void Ray"
     ]},
    {:"Orb Mage",
     [
       "Carry-On Grub",
       "The Curator",
       "Sharp-Eyed Lookout",
       "Overplanner",
       "Knickknack Shack",
       "Sleepy Resident",
       "Kil'jaeden"
     ]},
    # 5.5
    {:"Quest Mage",
     [
       "Astrobiologist",
       "Treasure Hunter Eudora",
       "Scrappy Scavenger",
       "Techysaurus"
     ]},
    {:"Imbue Mage",
     [
       "Sing-Along Buddy",
       "Aessina",
       "Merry Moonkin",
       "Resplendent Dreamweaver",
       "Divination",
       "Wisprider",
       "Flutterwing Guardian",
       "Petal Picker",
       "Bitterbloom Knight",
       "Spirit Gatherer"
     ]},
    {:"Big Spell Mage",
     [
       "Stellar Balance",
       "Huddle Up",
       "King Tide",
       "Vicious Slitherspear"
     ]},
    {:"Protoss Mage", ["Ancient of Yore"]},
    {:"Quest Mage", ["Q'onzu"]},
    # 10.5
    {:"Spell Mage",
     [
       "Storage Scuffle",
       "Story of the Waygate",
       "Spark of Life",
       "Pocket Dimension",
       "Buy One, Get One Freeze",
       "Hidden Objects",
       "Unearthed Artifacts",
       "Relic of Kings"
     ]},
    {:"Protoss Mage", ["Photon Cannon"]},
    {:"Big Spell Mage",
     [
       "Marooned Archmage",
       "Tsunami"
     ]},
    {:"Orb Mage", ["Watercolor Artist"]},
    {:"Protoss Mage", ["Shield Battery", "Tide Pools", "Seabreeze Chalice"]},
    # 15.5
    {:"Quest Mage", ["The Forbidden Sequence"]},
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
       "Frostbolt",
       "Arcane Intellect"
     ]},
    {:"Elemental Mage",
     [
       "Fire Fly",
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
