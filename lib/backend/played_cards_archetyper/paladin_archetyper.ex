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
       "Scalebreaker Bulwark",
       "Spearheart Sentry",
       "Inspiring Maul",
       "Sandfury Aura",
       "Nightmare Lord Xavius",
       "Gelbin of Tomorrow",
       "Mekkatorque's Aura",
       "Gnomish Aura",
       "Manifested Timeways",
       "Chronological Aura"
     ]},
    {:"Aggro Paladin",
     [
       "Beaming Sidekick",
       "Murloc Tidecaller",
       "Tortollan Storyteller",
       "Imprisoned Vilefiend"
     ]},
    # 5.5
    {:"Dude Paladin",
     [
       "Teamwork",
       "Brash Battlemaster",
       "Muster for Battle",
       "Hatching Ceremony",
       "Convalescence"
     ]},
    {:"Aggro Paladin",
     [
       "Worgen Infiltrator",
       "Rockskipper",
       "Dreambound Raptor",
       "Dragonscale Armaments",
       "Rock Skipper",
       "Murmy",
       "Glacial Shard",
       "Carrier Whelp",
       "Platysaur",
       "Dragonscale Aramaments",
       "Sizzling Cinder"
     ]},
    {:"End of Turnadin",
     [
       "Righteous Protector",
       "Violet Treasuregill",
       "Toreth the Unbreaking",
       "Acceleration Aura",
       "Nozdormu, Bronze Aspect"
     ]}
  ]
  @wild_config []

  def standard_excludes(), do: @standard_excludes
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, standard_excludes())
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Paladin")
  end

  def wild(_card_info) do
    nil
  end
end
