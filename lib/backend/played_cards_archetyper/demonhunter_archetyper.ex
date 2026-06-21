# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DemonHunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @herald_package [
    "Armored Bloodletter",
    "Azshara, Ocean Lord",
    "Deathwing, Worldbreaker",
    "Envoy of the End",
    "Ultraxion"
  ]
  @broxigar_dh_minions [
    "Bloodmage Thalnos",
    "Devious Coyote",
    "Dreadsoul Corrupter",
    "Felfire Blaze",
    "Glacial Shard",
    "Kayn Sunfury",
    "Remnant of Rage",
    "Slumbering Sprite",
    "Wild Pyromancer"
  ]
  @standard_excludes %{
    :"No Minion DH" =>
      @herald_package ++
        ["Elise the Navigator", "Scorchreaver", "Felfire Blaze", "Ravenous Felfisher" | @broxigar_dh_minions]
  }
  @standard_config [
    {:"Quest DH", ["Unleash the Colossus"]},
    {:"No Minion DH", ["Solitude", "Hounds of Fury", "The Eternal Hold"]},
    {:"Harold DH", @herald_package},
    {:"Broxigar DH",
     [
       "Insect Claw",
       "Perennial Serpent"
       | @broxigar_dh_minions
     ]},
    {:"Harold DH",
     [
       "Defiled Spear",
       "Fel Infusion",
       "Scorchreaver"
     ]},
    # 5.5
    {:"No Minion DH", ["Time-Lost Glaive"]},
    {:"Broxigar DH", ["Press the Advantage", "Eye Beam", "Chaos Strike"]},
    {:"No Minion DH", ["Lasting Legacy", "Horn of Feasting"]},
    {:"No Minion DH", ["Wyvern's Slumber", "Hive Map", "Axe of Cenarius", "Sigil of the Seas"]},
    {:"Harold DH",
     [
       "Illidari Studies",
       "Infestation"
     ]},
    {:"No Minion DH",
     [
       "Grim Harvest",
       "Sigil of Cinder"
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

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, @standard_excludes)
  def wild_config, do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other DH")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other DH")
  end
end
