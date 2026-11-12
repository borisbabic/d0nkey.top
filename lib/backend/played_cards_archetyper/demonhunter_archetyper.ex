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
      "Eredar Deceptor",
      "Soul Immolation"
    ],
    "Void Soul DH": [
      "Vicious Voidscale"
    ],
    "Void C'Thun DH": ["Devious Coyote", "Watfin", "Sigil of Cinder", "Cosmic Manifestations"],
    "Void Soul DH": [
      "Void Blast",
      "Void Soul",
      "Stardust Scythe"
    ],
    # 5.5
    "Harold DH": [
      "Ultraxion",
      "Fel Infusion",
      "Armored Bloodletter"
    ],
    "C'Thun DH": [
      "Sigil of Hatching",
      "Hungering Cavern"
    ],
    "N'Zoth DH": [
      "N'Zoth, Dream's End",
      "Ferocious Felbat",
      "Ravenous Felhunter",
      "Crystalline Golem"
    ],
    "Void C'Thun DH": [
      "Wormriddled Wriggler",
      "Irida Sinseeker"
    ],
    "C'Thun DH": [
      "Remnant of Rage",
      "Frontline Ironborn",
      "Broxigar's Last Stand"
    ],
    # 10.5
    "C'Thun DH": [
      "First Portal to Argus",
      "Axe of Cenarius",
      "Glacial Shard"
    ],
    "Void C'Thun DH": [
      "Kayn Sunfury",
      "Cult Neophyte",
      "Nightmare Lord Xavius"
    ],
    "Void C'Thun DH": [
      "Attentive Tender",
      "Wyvern's Slumber"
    ],
    "Raza DH": [
      "Dark Bribe"
    ],
    "Void C'Thun DH": [
      "Gorishi Stinger"
    ],
    # 15.5
    "C'Thun DH": ["C'Thun, Eye of the Empire", "Gargantuan Slitherer", "Sigil of the Seas"],
    "Void C'Thun DH": ["Grim Harvest", "Illidari Studies", "Infestation", "Tentacle Lash"]
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
