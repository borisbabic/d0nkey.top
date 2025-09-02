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
       "Tar Slime",
       "Windswept Pageturner",
       "Inferno Herald",
       "Solar Flare",
       "Blasteroid",
       "Spontaneous Combustion",
       "Glacial Shard"
     ]},
    {:"Protoss Mage",
     [
       "Warp Gate",
       "Busy Peon",
       "Colossus",
       "Resonance Coil",
       "Chrono Boost",
       "Artanis",
       "Void Ray",
       "Youthful Brewmaster"
     ]},
    {:"Quest Mage",
     [
       "Raptor Herald",
       "Relentless Wrathguard",
       "Treacherous Tormentor",
       "Stonehill Defender",
       "Travel Agent",
       "Astrobiologist",
       "Creature of Madness",
       "Scrappy Scavenger",
       "Scarab Keychain",
       "Malorne the Waywatcher"
     ]},
    {:"Big Spell Mage",
     [
       "Stellar Balance",
       "Huddle Up",
       "Vicious Slitherspear",
       "Oh, Manager!",
       "King Tide",
       "Marooned Archmage",
       "Metal Detector",
       "Portalmancer Skyla",
       "Supernova",
       "Tsunami"
     ]},
    {:"Elemental Mage",
     [
       "Fire Fly",
       "Glacial Shard",
       "Conjured Bookkeeper",
       "Flame Geyser",
       "Sizzling Cinder",
       "Living Flame",
       "Blob of Tar",
       "Fireball"
     ]},
    {:"Spell Mage",
     [
       "Pocket Dimension",
       "Buy One, Get One Freeze",
       "Hidden Objects",
       "Unearthed Artifacts",
       "Relic of Kings"
     ]},
    {:"Spell Mage", ["The Forbidden Sequence", "Frostbolt", "Rising Waves", "Tide Pools"]}
  ]

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Mage")
  end

  def wild(_card_info) do
    nil
  end
end
