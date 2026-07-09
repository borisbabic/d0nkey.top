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
    "Void Soul DH": [
      "Jailbird",
      "Vanessa the Ringleader",
      "Tras'tath, Soul Parasite",
      "Vicious Voidscale",
      "Stardust Scythe",
      "Void Blast",
      "Void Soul"
    ],
    "Harold DH": @herald_package,
    # auto gen
    "Spell DH": ["Hounds of Fury"],
    "Archmage DH": ["Captured Archmage", "Ravenous Felhunter"],
    # 5.5
    "Spell DH": ["Lasting Legacy", "Sands of Time", "Solitude"],
    "Demon DH": ["Netherwalker"],
    "Spell DH": ["Horn of Feasting", "Nespirah, Enthralled"],
    "Void DH": ["Battlefiend", "Hive Map", "Sigil of Cinder", "Time-Lost Glaive"],
    "Void Soul DH": ["Grim Harvest", "Sigil of the Seas"]
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
