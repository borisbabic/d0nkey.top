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
    "Quest DH": ["Unleash the Colossus"],
    "No Minion DH": ["Solitude", "Hounds of Fury", "The Eternal Hold"],
    "Harold DH": @herald_package,
    "Broxigar DH": [
      "Axe of Cenarius",
      "Bloodmage Thalnos",
      "Broxigar",
      "Broxigar's Last Stand",
      "Chaos Strike",
      "Crimson Sigil Runner",
      "Devious Coyote",
      "Dreadsoul Corrupter",
      "Eye Beam",
      "Felfire Blaze",
      "First Portal to Argus",
      "Glacial Shard",
      "Grim Harvest",
      "Hive Map",
      "Horn of Feasting",
      "Illidari Studies",
      "Infestation",
      "Insect Claw",
      "Kayn Sunfury",
      "Lasting Legacy",
      "Nespirah, Enthralled",
      "Perennial Serpent",
      "Portal Vanguard",
      "Press the Advantage",
      "Ravenous Felhunter",
      "Remnant of Rage",
      "Sands of Time",
      "Sigil of Cinder",
      "Sigil of the Seas",
      "Slumbering Sprite",
      "Time-Lost Glaive",
      "Wild Pyromancer",
      "Wyvern's Slumber"
    ]
  ]
  @wild_config [
    "XL Draenei Demon Hunter": ["Crimson Commander", "Saronite Chain Gang", "Starlight Wanderer"],
    "Pirate DH": ["Field of Strife", "Ship's Cannon"],
    "Token Broxigar DH": [
      "Animated Broomstick",
      "Feast of Souls",
      "Remnant of Rage",
      "SECURITY!!",
      "Wings of Hate",
      "Wings of Hate (Rank 1)",
      "Wings of Hate (Rank 2)"
    ],
    "LC Quest DH": ["Moonstone Mauler"],
    "Pirate DH": ["Adrenaline Fiend", "Hozen Roughhouser", "Mistake", "Treasure Distributor"],
    "Naga DH": ["Adaptive Amalgam"],
    "XL Il'gynoth DH": ["Mo'arg Artificer"],
    "Fatigue DH": ["Glaivetar"],
    "XL Questline DH": ["Crystalline Statue"],
    "XL HL Questline DH": ["Speaker Stomper"],
    "Token Broxigar DH": ["Spawning Pool"],
    "Broxigar DH": ["Broxigar", "Vengeful Walloper"],
    "XL HL Questline DH": ["Cult Neophyte", "Razorscale"],
    "XL Starship Demon Hunter": ["Felfused Battery"],
    "Token Broxigar DH": ["Momentum"],
    "XL HL Questline DH": ["Ci'Cigi", "Felfire Deadeye"],
    "Token Broxigar DH": [
      "Broxigar's Last Stand",
      "Dispose of Evidence",
      "Felosophy",
      "Final Showdown",
      "Irebound Brute",
      "Patches the Pilot"
    ],
    "XL Highlander DH": ["Gunslinger Kurtrus", "Snake Eyes"],
    "XL Fel DH": ["Illidan's Gift"],
    "STD Quest DH": ["Questing Assistant"],
    "LC Quest DH": ["Unleash the Colossus"],
    "Fel DH": ["Fel Barrage", "Scorchreaver", "Unleash Fel"],
    "STD Demon Hunter": ["Chaos Strike"]
  ]

  def standard_excludes, do: @standard_excludes
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other DH")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other DH")
  end
end
