# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PaladinArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{}

  @standard_config [
    {:"Quest Paladin", ["Dive the Golakka Depths"]},
    {:"Imbue Paladin",
     [
       "Malorne the Waywatcher",
       "Resplendent Dreamweaver",
       "Bitterbloom Knight",
       "Flutterwing Guardian",
       "Dreamwarden",
       "Goldpetal Drake",
       "Petal Picker",
       "Aegis of Light"
     ]},
    {:"Dude Paladin",
     [
       "Emboldening Blade",
       "Resilient Savior",
       "Arator the Redeemer"
     ]},
    {:"End of Turnadin",
     [
       "Chronological Aura",
       "Gelbin of Tomorrow",
       "Gnomish Aura",
       "Inspiring Maul",
       "Manifested Timeways",
       "Mekkatorque's Aura",
       "Nightmare Lord Xavius",
       "Sandfury Aura",
       "Scalebreaker Bulwark",
       "Spearheart Sentry"
     ]},
    {:"Aggro Paladin",
     [
       "Beaming Sidekick",
       "Murloc Tidecaller",
       "Rockskipper",
       "Tortollan Storyteller"
     ]},
    # 5.5
    {:"Dude Paladin",
     [
       "Teamwork",
       "Brash Battlemaster",
       "Muster for Battle",
       "Hatching Ceremony"
     ]},
    {:"Aggro Paladin",
     [
       "Carrier Whelp",
       "Glacial Shard",
       "Murmy",
       "Rockskipper",
       "Worgen Infiltrator"
     ]},
    {:"End of Turnadin",
     [
       "Righteous Protector",
       "Violet Treasuregill",
       "Toreth the Unbreaking",
       "Acceleration Aura",
       "Nozdormu, Bronze Aspect"
     ]},
    {:"Dude Paladin",
     [
       "Convalescence"
     ]}
  ]
  @wild_config []

  def standard_excludes, do: @standard_excludes
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Paladin")
  end

  def wild(_card_info) do
    nil
  end
end
