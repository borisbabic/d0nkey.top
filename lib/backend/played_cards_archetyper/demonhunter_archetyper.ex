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
    :"Spell DH" =>
      @herald_package ++
        ["Elise the Navigator", "Scorchreaver", "Felfire Blaze", "Ravenous Felfisher" | @broxigar_dh_minions]
  }
  @standard_config [
    "Quest DH": ["Unleash the Colossus"],
    "Raza DH": [
      "Enduring Roach",
      "Eredar Deceptor"
    ],
    "Void C'Thun DH": ["Devious Coyote"],
    "Void Soul DH": [
      "Vicious Voidscale",
      "Void Blast",
      "Void Soul",
      "Stardust Scythe"
    ],
    "Raza DH": ["Soul Immolation"],
    # 5.5
    "C'Thun DH": ["Frontline Ironborn"],
    "Void C'Thun DH": ["Cosmic Manifestations", "Watfin", "Sigil of Cinder"],
    "C'Thun DH": {["Gargantuan Slitherer", "C'Thun, Eye of the Empire"], ["Irida Sinseeker"]},
    "Harold DH": ["Fel Infusion"],
    "Spell DH": ["Hounds of Fury"],
    # 10.5
    "Void C'Thun DH": ["Escape Artist", "C'Thun, Eye of the Empire", "Gargantuan Slitherer"],
    # auto gen
    "N'Zoth DH": ["Vyranoth"],
    "Raza DH": ["Fumigate"],
    "C'Thun DH": ["Defias Smuggler"],
    "Void C'Thun DH": ["Irida Sinseeker"],
    "Other DH": ["Wrathspike Brute"],
    "C'Thun DH": ["Broxigar's Last Stand", "Hungering Cavern", "Remnant of Rage", "Spawn of C'Thun", "Tentacle Lash"],
    "Other DH": ["Beaming Sidekick", "Elven Archer", "Fire Fly", "Murloc Warleader"],
    "Other DH": ["Hench-Clan Thug"],
    "Raza DH": ["Dark Bribe"],
    "Spell DH": ["Aeon Rend"],
    "Harold DH": ["Armored Bloodletter"],
    "Demon DH": ["Raging Felscreamer"],
    "Other DH": ["Netherwalker"],
    "C'Thun DH": ["First Portal to Argus"],
    "Void C'Thun DH": ["Cult Neophyte"],
    "Other DH": ["Blind Harrower", "Bloatray"],
    "Void C'Thun DH": ["Wormriddled Wriggler"],
    "Other DH": ["Insect Claw"],
    "C'Thun DH": ["Axe of Cenarius", "Glacial Shard", "Sigil of the Seas"],
    "C'Thun DH": ["Grim Harvest", "Illidari Studies", "Wyvern's Slumber"]
  ]
  @wild_config [
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
