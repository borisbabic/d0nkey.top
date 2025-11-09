# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.MageArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    # {:"Quest Mage", ["The Forbidden Sequence"]},
    {:"Spell Mage", ["Spot the Difference", "Manufacturing Error", "Yogg in the Box"]},
    {:"Arcane Mage",
     [
       "Go with the Flow",
       "Arcane Intellect",
       "Azure Queen Sindragosa",
       "Mirror Dimension",
       "Azure King Malygos",
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
       "Stonehill Defender",
       "Travel Agent",
       "Questing Assistant",
       "Beast Speaker Taka"
     ]},
    {:"Elemental Mage",
     [
       "Blazing Accretion",
       "Lamplighter",
       "Fire Fly",
       "Triplewick Trickster",
       "Windswept Pageturner",
       "Solar Flare",
       "Blasteroid",
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
    # 5.5
    {:"Orb Mage",
     [
       "Doomsayer",
       "Carry-On Grub",
       "The Curator",
       "Sharp-Eyed Lookout",
       "Overplanner",
       "Sleepy Resident"
     ]},
    {:"Quest Mage",
     [
       "Astrobiologist",
       "Treasure Hunter Eudora"
     ]},
    {:"Spell Mage", ["Malfunction"]},
    {:"Big Spell Mage",
     [
       "Huddle Up",
       "Sizzling Cinder",
       "King Tide",
       "Fireball",
       "Blob of Tar"
     ]},
    {:"Arcane Mage", ["Portal Vanguard"]},
    # 10.5
    {:"Imbue Mage",
     [
       "Sing-Along Buddy",
       "Bitterbloom Knight",
       "Aessina",
       "Spirit Gatherer",
       "Flutterwing Guardian",
       "Wisprider"
     ]},
    {:"Quest Mage", ["Malorne the Waywatcher", "Scrappy Scavenger"]},
    {:"Spell Mage",
     [
       "Buy One, Get One Freeze",
       "Stellar Balance",
       "Nightmare Lord Xavius"
     ]},
    {:"Quest Mage", ["Creature of Madness"]},
    {:"Protoss Mage", ["Photon Cannon"]},
    # 15.5
    {:"Arcane Mage", ["Watercolor Artist", "Smoldering Grove"]},
    {:"Quest Mage", ["Tidepool Pupil"]},
    {:"Spell Mage", ["Hidden Objects", "Pocket Dimension"]},
    {:"Orb Mage", ["Dirty Rat"]},
    {:"Arcane Mage", ["Primordial Glyph", "Tide Pools", "Alter Time"]},
    # 20.5
    {:"Elemental Mage", ["Cloud Serpent", "Violet Spellwing"]},
    {:"Protoss Mage", ["Shield Battery", "Seabreeze Chalice"]},
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
