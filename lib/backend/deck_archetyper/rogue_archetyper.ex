# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.RogueArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Rogue"

      herald?(card_info) ->
        :"Harold Rogue"

      imbue?(card_info, 5) ->
        :"Imbue Rogue"

      thief_rogue?(card_info) ->
        :"Thief Rogue"

      weapon?(card_info) ->
        :"Weapon Rogue"

      "Elise the Navigator" in card_info.card_names ->
        :"Elise Rogue"

      "Fyrakk the Blazing" in card_info.card_names ->
        :"Fyrakk Rogue"

      "Ashamane" in card_info.card_names ->
        :"Ashamane Rogue"

      ysera_rogue?(card_info) ->
        :"Ysera Rogue"

      dark_gift?(card_info) ->
        :"Dark Gift Rogue"

      imbue?(card_info, 3) ->
        :"Imbue Rogue"

      min_keyword_count?(card_info, 2, "spell-damage") ->
        :"Burn Rogue"

      cycle?(card_info) ->
        :"Cycle Rogue"

      "Garona Halforcen" in card_info.card_names ->
        :"Garona Rogue"

      true ->
        fallbacks(card_info, "Rogue")
    end
  end

  defp dark_gift?(card_info) do
    "Cindersword" in card_info.card_names
  end

  defp ysera_rogue?(card_info) do
    dragons =
      card_info.full_cards
      |> Enum.filter(fn
        %{minion_type: %{slug: "dragon"}} -> true
        _ -> false
      end)

    min_count?(card_info, 2, ["Naralex, Herald of the Flights", "Ysera, Emerald Aspect"]) and
      Enum.count(dragons) < 4
  end

  # defp combo?(card_info) do
  #   min_keyword_count?(card_info, 8, "combo")
  # end

  defp quasar?(card_info) do
    "Quasar" in card_info.card_names and min_keyword_count?(card_info, 1, "spell-damage")
  end

  defp excavate_rogue?(ci) do
    min_count?(ci, 3, [
      "Antique Flinger",
      "Drilly the Kid",
      "Bloodrock Co Shovel",
      "Scourge Illusionist",
      "Bloodrock Co. Shovel" | neutral_excavate()
    ])
  end

  defp wild_gnoll_miracle_rogue?(card_info) do
    min_count?(card_info, 2, ["Wildpaw Gnoll", "Arcane Giant"])
  end

  defp wild_alex_rogue?(card_info) do
    min_count?(card_info, 1, ["Spirit of the Shark", "Brann Bronzebeard"]) and
      "Alexstrasza the Life-Binder" in card_info.etc_sideboard_names
  end

  defp wild_astalor_rogue?(card_info) do
    min_count?(card_info, 1, ["Spirit of the Shark", "Brann Bronzebeard"]) and
      min_count?(card_info.etc_sideboard_names, 2, [
        "Astalor Bloodsworn",
        "Bounce Around (ft. Garona)"
      ])
  end

  defp wild_miracle_rogue?(card_info) do
    min_count?(card_info, 2, [
      "Arcane Giant",
      "Breakdance"
    ]) and
      min_count?(card_info, 3, [
        "Gear Shift",
        "Secret Passage",
        "Dig for Treasure",
        "Swindle",
        "Blackwater Cutlass",
        "Ghostly Strike",
        "Twisted Webweaver",
        "Cultist Map"
      ])
  end

  defp wild_sevens_miracle_rogue?(card_info) do
    "Triple Sevens" in card_info.card_names and
      min_count?(card_info, 2, [
        "Arcane Giant",
        "Playhouse Giant",
        "Breakdance",
        "Everything Must Go!"
      ]) and
      min_count?(card_info, 3, [
        "Gear Shift",
        "Secret Passage",
        "Dig for Treasure",
        "Swindle",
        "Blackwater Cutlass",
        "Ghostly Strike",
        "Twisted Webweaver",
        "Cultist Map",
        "Gone Fishin'"
      ])
  end

  defp weapon?(ci) do
    min_count?(ci, 3, [
      "Deadly Poison",
      "Air Guitarist",
      "Harmonic Hip Hop",
      "Harmonic Hip-Hop",
      "Mic Drop",
      "Bloodail Raider",
      "Fogsail Freebooter",
      "Small Time Buccaneer",
      "Dread Corsair",
      "Bloodsail Raider",
      "Fogsail Freebooter",
      "Sharp Shipment",
      "Wicked Blightspawn",
      "Swarthy Swordshiner"
    ])
  end

  @multi_draw [
    "Triple Sevens",
    "Gear Shift",
    "Gaslight Gatekeeper",
    "Knickknack Shack",
    "Eat! The! Imp!",
    "Twisted Webweaver",
    "Raiding Party",
    "Crystal Tusk",
    "Fast Forward",
    "Robocaller",
    "Ethereal Oracle",
    "Quick Pick",
    "Dubious Purchase"
  ]

  def cycle?(card_info) do
    min_count?(card_info, 3, @multi_draw)
  end

  defp thief_rogue?(ci),
    do:
      min_count?(ci, 6, [
        "Shaku, the Collector",
        "Agency Espionage",
        "Nightmare Fuel",
        "Undercity Huckster",
        "Tricky Satyr",
        "Ashamane",
        "Mimicry",
        "Thistle Tea",
        "Snatch and Grab",
        "Treasure Hunter Eudora",
        "Petty Theft",
        "Concierge",
        "Tess Greymane",
        "Twisted Pack",
        "Mixtape",
        "Hipster",
        "Plagiarizarrr",
        "Jackpot!",
        "Kaja'mite Creation",
        "Costume Merchant",
        "Shadowed Informant",
        "Hench-Clan Burglar",
        "Swashburglar"
      ])

  def wild(card_info) do
    cond do
      questline?(card_info) and highlander?(card_info) ->
        :"HL Questline Rogue"

      quest?(card_info) and highlander?(card_info) ->
        String.to_atom("HL #{quest_abbreviation(card_info)} Quest Rogue")

      imbue?(card_info, 4) and highlander?(card_info) ->
        :"HL Imbue Rogue"

      wild_thief_rogue?(card_info) and highlander?(card_info) ->
        :"HL Thief Rogue"

      "Captain Hooktusk" in card_info.card_names and highlander?(card_info) ->
        :"HL Hooktusk Rogue"

      "Velarok Windblade" in card_info.card_names and highlander?(card_info) ->
        :"HL Velarok Rogue"

      highlander?(card_info) ->
        :"Highlander Rogue"

      questline?(card_info) ->
        :"Questline Rogue"

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest Rogue")

      boar?(card_info) ->
        :"Boar Rogue"

      baku?(card_info) ->
        :"Odd Rogue"

      genn?(card_info) ->
        :"Even Rogue"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun Rogue"

      "Majordomo Executus" in card_info.card_names ->
        :"Majordomo Rogue"

      wild_hostage?(card_info) ->
        :"Hostage Rogue"

      "Kingsbane" in card_info.card_names ->
        :"Kingsbane Rogue"

      "King Togwaggle" in card_info.card_names ->
        :"Tog Rogue"

      imbue?(card_info, 4) ->
        :"Imbue Rogue"

      "Smokescreen" in card_info.card_names ->
        :"Deathrattle Rogue"

      quasar_mill?(card_info) ->
        :"Quasar Mill Rogue"

      quasar?(card_info) ->
        :"Quasar Rogue"

      garrote?(card_info) ->
        :"Garrote Rogue"

      "King Llane" in card_info.card_names and wild_pirate_rogue?(card_info) ->
        :"Kingslayer Pirate Rogue"

      wild_pirate_rogue?(card_info) ->
        :"Pirate Rogue"

      "Velarok Windblade" in card_info.card_names ->
        :"Velarok Rogue"

      wild_sevens_miracle_rogue?(card_info) ->
        :"777 Miracle Rogue"

      "Swiftscale Trickster" in card_info.card_names ->
        :"Swiftscale Rogue"

      wild_gnoll_miracle_rogue?(card_info) ->
        :"Gnoll Miracle Rogue"

      wild_miracle_rogue?(card_info) ->
        :"Miracle Rogue"

      wild_alex_rogue?(card_info) ->
        :"Alex Rogue"

      "Pirate Admiral Hooktusk" in card_info.card_names ->
        :"Hooktusk Rogue"

      wild_mill_rogue?(card_info) ->
        :"Mill Rogue"

      wild_astalor_rogue?(card_info) ->
        :"Astalor Rogue"

      mine_rogue?(card_info) ->
        :"Mine Rogue"

      wild_thief_rogue?(card_info) ->
        :"Thief Rogue"

      "Spirit of the Shark" in card_info.card_names ->
        :"Shark Rogue"

      excavate_rogue?(card_info) ->
        :"Drilling Rogue"

      weapon?(card_info) ->
        :"Weapon Rogue"

      true ->
        fallbacks(card_info, "Rogue")
    end
  end

  defp quasar_mill?(card_info) do
    min_count?(card_info, 2, ["Quasar", "Selfish Shellfish"])
  end

  defp wild_hostage?(card_info) do
    min_count?(card_info, 3, [
      "Tess Greymane",
      "Maestra, Mask Merchant",
      "Cloak of Shadows"
    ]) and
      min_count?(card_info, 1, [
        "Bounce Around (ft. Garona)",
        "Vanish",
        "Potion of Illusion"
      ])
  end

  defp mine_rogue?(ci),
    do: min_count?(ci, 2, ["Naval Mine", "Snowfall Graveyard"])

  defp garrote?(card_info) do
    "Garrote" in card_info.card_names and min_keyword_count?(card_info, 1, "spell-damage")
  end

  defp wild_pirate_rogue?(card_info) do
    min_count?(card_info, 3, [
      "Parachute Brigand",
      "Toy Boat",
      "Ship's Cannon",
      "Patches the Pirate",
      "Treasure Distributor",
      "Swordfish",
      "Raiding Party",
      "Southsea Captain"
    ])
  end

  defp wild_thief_rogue?(card_info) do
    min_count?(card_info, 4, [
      "Wildpaw Gnoll",
      "Obsidian Shard",
      "Twisted Pack",
      "Tess Greymane",
      "Maestra of the Masquerade",
      "Kaj'mite Creation",
      "Shell Game",
      "Obsidian Shard",
      "Velarok Windblade",
      "Vendetta",
      "Wildpaw Gnoll",
      "Stick Up",
      "Flint Firearm",
      "Thistle Tea Set",
      "Ashamane",
      "Mixtape",
      "Mirrex, the Crystalline",
      "Sketchy Stranger",
      "Nightmare Fuel",
      "Dragon's Hoard",
      "Wand Thief",
      "Agency Espionage",
      "Tooth of Nefarian"
    ])
  end

  defp wild_mill_rogue?(card_info) do
    min_count?(card_info, 2, [
      "Snowfall Graveyard",
      "Selfish Shellfish"
    ]) or
      ("Coldlight Oracle" in card_info.card_names and
         min_count?(card_info, 1, ["Spirit of the Shark", "Brann Bronzebeard"]) and
         min_count?(card_info, 2, [
           "Potion of Illusion",
           "Togwaggle's Scheme",
           "Gang Up",
           "Lab Recruiter"
         ]))
  end
end
