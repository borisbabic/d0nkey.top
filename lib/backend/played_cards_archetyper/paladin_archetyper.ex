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
       "Arator the Redeemer",
       "Hatching Ceremony",
       "Teamwork",
       "Muster for Battle",
       "Brash Battlemaster"
     ]},
    {:"End of Turnadin",
     [
       "Scalebreaker Bulwark",
       "Spearheart Sentry",
       "Hourglass Attendant",
       "Inspiring Maul",
       "Sandfury Aura",
       "Nightmare Lord Xavius",
       "Gelbin of Tomorrow",
       "Ancient of Yore",
       "Mekkatorque's Aura",
       "Gnomish Aura",
       "Renewing Flames",
       "Manifested Timeways",
       "Chronological Aura",
       "Bronze Redeemer"
     ]},
    {:"Aggro Paladin",
     [
       "Beaming Sidekick",
       "Murloc Tidecaller",
       "Worgen Infiltrator",
       "Dreambound Raptor",
       "Tortollan Storyteller",
       "Abusive Sergeant",
       "Imprisoned Vilefiend",
       "Fire Fly"
     ]},
    {:"Dude Paladin",
     [
       "Convalescence"
     ]},
    {:"Aggro Paladin",
     [
       "Rock Skipper",
       "Murmy",
       "Glacial Shard",
       "Carrier Whelp",
       "Platysaur",
       "Dragonscale Aramaments",
       "Sizzling Cinder",
       "The Fins Beyond Time",
       "Twilight Egg",
       "Ancient Raptor",
       "Past Gnomeregan"
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
