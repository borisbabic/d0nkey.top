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
       "Glacial Shard"
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
       "Scarab Keychain"
     ]},
    {:"Orb Mage",
     [
       "Carry-On Grub",
       "The Curator",
       "Sharp-Eyed Lookout",
       "Overplanner",
       "Kil'jaeden",
       "Sleepy REsident",
       "Doomsayer"
     ]},
    # 5.5
    {:"Imbue Mage",
     [
       "Sing-Along Buddy",
       "Aessina",
       "Divination",
       "Wisprider",
       "Flutterwing Guardian",
       "Bitterbloom Knight",
       "Spirit Gatherer"
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
    {:"Elemental Mage",
     [
       "Fire Fly",
       "Conjured Bookkeeper",
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
