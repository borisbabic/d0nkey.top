# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.MageArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @leyline_package [
    "Crystallized Leyline",
    "Ley Walker",
    "Bursting Leyline",
    "The Arcanomicon",
    "Surge Needle",
    "Mystic Runesaber",
    "Leyline Nexus"
  ]
  @standard_excludes %{}
  @standard_config [
    {:"Quest Mage", ["The Forbidden Sequence"]},
    {:"Imbue Mage",
     [
       "Aessina",
       "Bitterbloom Knight",
       "Divination",
       "Flutterwing Guardian",
       "Malorne the Waywatcher",
       "Petal Picker",
       "Resplendent Dreamweaver",
       "Spirit Gatherer",
       "Wisprider"
     ]},
    {:"Leyline Mage", @leyline_package},
    {:"Burn Mage",
     [
       "Arcane Barrage",
       "Bloodmage Thalnos",
       "Conjured Bookkeeper",
       "Fireball",
       "First Flame",
       "Frostbolt",
       "Living Flame",
       "Raincaller",
       "Scorching Winds",
       "Sleet Storm",
       "Spellweaver's Brilliance",
       "Time-Twisted Seer",
       "Unstable Spellcaster",
       "Violet Spellwing",
       "Vulcanos"
     ]},
    {:"Leyline Mage",
     [
       "Smoldering Grove",
       "Runed Orb",
       "Sands of Time",
       "Winterspring Whelp",
       "Archmage Kalec"
     ]}
  ]
  @wild_config []

  def standard_excludes(), do: @standard_excludes
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, @standard_excludes)
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Mage")
  end

  def wild(_card_info) do
    nil
  end
end
