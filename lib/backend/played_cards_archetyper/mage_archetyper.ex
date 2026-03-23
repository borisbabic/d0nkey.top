# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.MageArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{}
  @standard_config [
    {:"Quest Mage", ["The Forbidden Sequence"]},
    {:"Imbue Mage",
     [
       "Divination",
       "Malorne the Waywatcher",
       "Wisprider",
       "Resplendent Dreamweaver",
       "Spirit Gatherer",
       "Aessina",
       "Petal Picker",
       "Flutterwing Guardian",
       "Bitterbloom Knight"
     ]},
    {:"Burn Mage",
     [
       "Battlefield Blaster",
       "Frostbolt",
       "Spellweaver's Brilliance",
       "Scorching Winds",
       "Raincaller",
       "Sleet Storm",
       "Archmage Kalec",
       "Unstable Spellcaster",
       "Winterspring Whelp",
       "Fireball",
       "Living Flame",
       "First Flame",
       "Runed Orb",
       "Conjured Bookkeeper",
       "Arcane Barrage",
       "Violet Spellwing",
       "Bloodmage Thalnos",
       "Smoldering Grove",
       "Sizzling Cinder",
       "Time-Twisted Seer",
       "Vulcanos",
       "Stellar Balance",
       "Gemstone Hoarder"
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
