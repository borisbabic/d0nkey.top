# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PaladinArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{}

  @standard_config [
    {:"Quest Paladin", ["Dive the Golakka Depths"]},
    {:"Imbue Paladin",
     [
       "Aegis of Light",
       "Bitterbloom Knight",
       "Dreamwarden",
       "Flutterwing Guardian",
       "Goldpetal Drake",
       "Malorne the Waywatcher",
       "Petal Picker",
       "Resplendent Dreamweaver"
     ]},
    {:"Dude Paladin",
     [
       "Arator the Redeemer",
       "Emboldening Blade",
       "Resilient Savior",
       "Teamwork"
     ]},
    {:"End of Turnadin",
     [
       "Battle Vicar",
       "Chronological Aura",
       "Earthen Drake",
       "Gelbin of Tomorrow",
       "Gnomish Aura",
       "Inspiring Maul",
       "Manifested Timeways",
       "Mekkatorque's Aura",
       "Sandfury Aura",
       "Scalebreaker Bulwark",
       "Spearheart Sentry"
     ]},
    {:"Dude Paladin",
     [
       "Platysaur",
       "Brash Battlemaster",
       "Muster for Battle",
       "Hatching Ceremony"
     ]},
    # 5.5
    {:"End of Turnadin",
     [
       "Glacial Shard",
       "Toreth the Unbreaking"
     ]},
    {:"End of Turnadin",
     [
       "Acceleration Aura"
     ]},
    {:"Dude Paladin",
     [
       "Sizzling Cinder",
       "Twilight Egg",
       "Convalescence"
     ]},
    {:"End of Turnadin",
     [
       "Nightmare Lord Xavius",
       "Nozdormu, Bronze Aspect"
     ]},
    {:"Dude Paladin",
     [
       "Violet Treasuregill",
       "Past Gnomeregan"
     ]},
    # 10.5
    {:"End of Turnadin",
     [
       "Righteous Protector",
       "The Fins Beyond Time"
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
