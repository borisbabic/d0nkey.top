# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.ShamanArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Shaman", ["Spirit of the Mountain"]},
    {:"Harold Shaman",
     [
       "Shadowed Informant",
       "For All Time",
       "Twilight Egg",
       "Elise the Navigator",
       "Nightmare Lord Xavius",
       "Whelp of the Infinite",
       "Healing Rain",
       "Carrier Whelp",
       "Ceremonial Clash",
       "Crackling Clopudstrider",
       "Ultraxion",
       "Ancient Raptor",
       "Muradin, High King",
       "Deathwing, Worldbreaker",
       "Al'Akir, Lord of Storms",
       "High King's Hammer",
       "Envoy of the End",
       "Avatar Form",
       "Flight of the Firehawk",
       "Skywall Sentinel",
       "Muradin's Last Stand",
       "Primordial Overseer",
       "Ritual of Power",
       "Witch's Apprentice",
       "Hex",
       "Static Shock",
       "Lightning Storm",
       "Mother Duck",
       "Wailing Vapor",
       "Far Sight",
       "Voltaic Burst",
       "Glacial Shard",
       "Crackling Cloudstrider"
       # x (4) Ascendance
     ]},
    {:"Imbue Shaman",
     [
       "Flutterwing Guardian",
       "Bitterbloom Knight",
       "Petal Picker",
       "Resplendent Dreamweaver",
       "Glowroot Lure",
       "Aspect's Embrace",
       "Living Guarden"
     ]}
  ]
  @wild_config []

  def standard_excludes(), do: %{}
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, standard_excludes())
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Shaman")
  end

  def wild(_card_info) do
    nil
  end
end
