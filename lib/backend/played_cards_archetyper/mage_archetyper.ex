# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.MageArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  def standard(card_info) do
    cond do
      any?(card_info, [
        "Spot the Difference",
        "Malfunction",
        "Manufacturing Error",
        "Yogg in the Box"
      ]) ->
        :"Spell Mage"

      any?(card_info, [
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
      ]) ->
        :"Elemental Mage"

      any?(card_info, [
        "Warp Gate",
        "Busy Peon",
        "Colossus",
        "Resonance Coil",
        "Chrono Boost",
        "Artanis",
        "Void Ray",
        "Youthful Brewmaster"
      ]) ->
        :"Protoss Mage"

      any?(card_info, [
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
      ]) ->
        :"Quest Mage"

      any?(card_info, [
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
      ]) ->
        :"Big Spell Mage"

      any?(card_info, [
        "Fire Fly",
        "Glacial Shard",
        "Conjured Bookkeeper",
        "Flame Geyser",
        "Sizzling Cinder",
        "Living Flame",
        "Blob of Tar",
        "Fireball"
      ]) ->
        :"Elemental Mage"

      any?(card_info, [
        "Pocket Dimension",
        "Buy One, Get One Freeze",
        "Hidden Objects",
        "Unearthed Artifacts",
        "Relic of Kings"
      ]) ->
        :"Spell Mage"

      any?(card_info, ["The Forbidden Sequence", "Frostbolt", "Rising Waves", "Tide Pools"]) ->
        :"Spell Mage"

      true ->
        :"Other Mage"
    end
  end

  def wild(_card_info) do
    nil
  end
end
