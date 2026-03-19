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
    {:"End of Turnadin",
     [
       "The Curator",
       "Scalebreaker Bulwark",
       "Hardlight Protector",
       "Spearheart Sentry",
       "Hourglass Attendant",
       "Inspiring Maul",
       "Sandfury Aura",
       "Highlord Fordragon",
       "Nightmare Lord Xavius",
       "Gelbin of Tomorrow",
       "Ancient of Yore",
       "Ursol",
       "Renewing Flames",
       "Manifested Timeways",
       "Nozdormu, Bronze Aspect",
       "Chronological Aura",
       "Toreth the Unbreaking",
       "Bronze Redeemer",
       "Violet Treasuregill",
       "Acceleration Aura",
       "Righteous Protector",
       "Taelan Fordring"
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
