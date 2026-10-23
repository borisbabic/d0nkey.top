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
    "C'Thun DH": ["Frontline Ironborn"],
    "Void Soul DH": ["Vicious Voidscale", "Stardusct Scythe"],
    "Void C'Thun DH": [
      "Escape Artist",
      "Irida Sinseeeker",
      "Devious Coyote",
      "Watfin",
      "Wormriddled Wriggler",
      "Cosmic Manifestations"
    ],
    # auto gen
    "C'Thun DH": [
      "Broxigar",
      "Broxigar's Last Stand",
      "C'Thun, Eye of the Empire",
      "Chaos Strike",
      "Chronikar",
      "Cult Neophyte",
      "Gargantuan Slitherer",
      "Hungering Cavern",
      "Remnant of Rage",
      "Spawn of C'Thun",
      "Tentacle Lash",
      "Wyvern's Slumber"
    ],
    "Void Soul DH": ["Stardust Scythe", "Void Soul"],
    "Raza DH": ["Dark Bribe", "Soul Immolation", "Encroaching Roach"],
    "Void C'Thun DH": ["Sigil of Cinder"],
    "C'Thun DH": ["Attentive Tender", "Axe of Cenarius", "First Portal to Argus"],
    "C'Thun DH": ["Illidari Studies", "Infestation", "Sigil of the Seas"]
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
