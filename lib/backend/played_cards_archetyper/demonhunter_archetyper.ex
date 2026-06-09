# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DemonHunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @herald_package [
    "Deathwing, Worldbreaker",
    "Azshara, Ocean Lord",
    "Ultraxion",
    "Armored Bloodletter",
    "Envoy of the End"
  ]
  @standard_excludes %{
    :"No Minion DH" =>
      @herald_package ++
        ["Elise the Navigator", "Scorchreaver", "Felfire Blaze", "Ravenous Felfisher"]
  }
  @standard_config [
    {:"Quest DH", ["Unleash the Colossus"]},
    {:"No Minion DH", ["Lasting Legacy", "Solitude", "Hounds of Fury", "The Eternal Hold"]},
    {:"Harold DH",
     [
       "Scorchreaver",
       "Defiled Spear" | @herald_package
     ]},
    {:"No Minion DH", ["Time-Lost Glaive", "Horn of Feasting", "Hive Map"]},
    {:"Broxigar DH",
     [
       "Elven Archer",
       "Felfire Blaze",
       "Glacial Shard",
       "Kayn Sunfury",
       "Perenial Serpent",
       "Prize Vendor",
       "Remnant of Rage",
       "Wild Pyromancer"
     ]},
    # 5.5
    {:"No Minion DH",
     [
       "Horn of Feasting",
       "Sands of Time",
       "Nespirah, Enthralled",
       "Broxigar's Last Stand",
       "Illidari Studies",
       "Wyvern's Slumber",
       "Infestation",
       "First Portal to Argus",
       "Press the Advantage",
       "Sigil of the Seas",
       "Hive Map",
       "Axe of Cenarius",
       "Eye Beam",
       "Grim Harvest"
     ]}
  ]
  @wild_config []
  # @wild_config [
  #   {:"Pirate Demon Hunter",
  #    [
  #      "Ship's Cannon",
  #      "Hozen Roughhouser",
  #      "Treasure Distributor",
  #      "Field of Strife",
  #      "Magnifying Glaive",
  #      "Parachute Brigand",
  #      "Southsea Captain",
  #      "Patches the Pirate",
  #      "Mistake",
  #      "Space Pirate",
  #      "Adrenaline Fiend",
  #      "Dangerous Cliffside"
  #    ]},
  #   {:"Questline DH",
  #    [
  #      "Crimson Sigil Runner",
  #      "Glaivetar",
  #      "Fierce Outsider",
  #      "Vengeful Walloper",
  #      "Irebound Brute",
  #      "Felosophy",
  #      "Double Jump",
  #      "Patches the Pilot",
  #      "Aranna, Thrill Seeker",
  #      "Spectral Sight",
  #      "Illidari Studies",
  #      "Final Showdown",
  #      "Sigil of Alacrity",
  #      "Mana Burn",
  #      "Glide",
  #      "Paraglide",
  #      "Dispose of Evidence",
  #      "Spectral Sight",
  #      "Illidari Studies",
  #      "Sigil of Time",
  #      "Consume Magic"
  #    ]}
  # ]

  def standard_excludes(), do: %{}
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, @standard_excludes)
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other DH")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other DH")
  end
end
