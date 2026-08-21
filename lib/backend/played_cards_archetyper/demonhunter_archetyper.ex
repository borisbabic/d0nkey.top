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
    "Raza DH": ["Eredar Deceptor"],
    "Void Soul DH": [
      "Ravenous Felhunter",
      "Tras'tath, Soul Parasite",
      "Vicious Voidscale",
      "Stardust Scythe",
      "Void Blast",
      "Void Soul"
    ],
    "Harold DH": @herald_package,
    "Raza DH": [
      "Enduring Roach",
      "Soul Immolation"
    ],
    # auto-gen
    "Void DH": [
      "Carrier Whelp",
      "Cloud Serpent",
      "Cosmic Manifestations",
      "Escape Artist",
      "Hellraiser",
      "Illusory Greenwing",
      "Irida Sinseeker",
      "Jumpscare!",
      "Netherspite Historian",
      "Portal Vanguard",
      "Prescient Slitherdrake",
      "Rockskipper",
      "Shadowed Informant",
      "Solitude",
      "The Eternal Hold"
    ],
    "Raza DH": ["Bloodmage Thalnos", "Fumigate", "Raging Felscreamer", "Royal Librarian", "Rustrot Viper"],
    "Harold DH": ["Fel Infusion"],
    "Other DH": ["Hive Map", "Time-Lost Glaive"],
    "Raza DH": ["Press the Advantage"],
    "Other DH": ["Horn of Feasting"],
    "Other DH": ["Crimson Sigil Runner", "Eye Beam", "Lasting Legacy", "Ravenous Felfisher", "Remnant of Rage"],
    "Raza DH": [
      "Axe of Cenarius",
      "Broxigar's Last Stand",
      "First Portal to Argus",
      "Grim Harvest",
      "Illidari Studies",
      "Infestation"
    ]
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
