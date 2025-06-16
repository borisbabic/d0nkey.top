# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.RogueArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      mech_rogue?(card_info) ->
        :"Mech Rogue"

      pain?(card_info) and amalgam?(card_info) ->
        :"Amalgam Pain Rogue"

      amalgam?(card_info) ->
        :"Amalgam Rogue"

      pain?(card_info) and pirate_rogue?(card_info) ->
        :"Scurvy Rogue"

      pain?(card_info) ->
        :"Pain Rogue"

      pirate_rogue?(card_info) && thief_rogue?(card_info) ->
        :"Pirate Thief Rogue:"

      thief_rogue?(card_info) ->
        :"Thief Rogue"

      pirate_rogue?(card_info) and cycle_rogue?(card_info) ->
        :"Pirate Cycle Rogue"

      pirate_rogue?(card_info) ->
        :"Pirate Rogue"

      protoss?(card_info, 4) ->
        :"Protoss Rogue"

      cycle_rogue?(card_info) ->
        :"Cycle Rogue"

      goldbeard?(card_info) ->
        :"Goldbeard Rogue"

      incindius?(card_info) ->
        :"Incindius Rogue"

      menagerie?(card_info) ->
        :"Menagerie Rogue"

      quasar?(card_info) ->
        :"Quasar Rogue"

      weapon?(card_info) ->
        :"Weapon Rogue"

      dorian_rogue?(card_info) ->
        :"Dorian Rogue"

      starship?(card_info) ->
        :"Starship Rogue"

      bounce?(card_info) ->
        :"Bounce Rogue"

      ysera_rogue?(card_info) ->
        :"Ysera Rogue"

      "Ashamane" in card_info.card_names ->
        :"Ashamane Rogue"

      "Fyrakk the Blazing" in card_info.card_names ->
        :"Fyrakk Rogue"

      dark_gift?(card_info) ->
        :"Dark Gift Rogue"

      combo?(card_info) ->
        :"Combo Rogue"

      maestra_rogue?(card_info) ->
        :"Maestra Rogue"

      "Incindius" in card_info.card_names ->
        :"Incindius Rogue"

      "Quasar" in card_info.card_names ->
        :"Quasar Rogue"

      "Photographer Fizzle" in card_info.card_names ->
        :"Fizzle Rogue"

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

  defp bounce?(card_info) do
    min_count?(card_info, 4, [
      "Shadowstep",
      "Twisted Webweaver",
      "Harbringer of the Blighted",
      "Web of Deception",
      "Waggle Pick"
    ])
  end

  defp combo?(card_info) do
    min_keyword_count?(card_info, 8, "combo")
  end

  defp quasar?(card_info) do
    "Quasar" in card_info.card_names and min_keyword_count?(card_info, 1, "spell-damage")
  end

  defp incindius?(card_info) do
    min_count?(card_info, 2, ["Incindius", "Sonya Waterdancer"])
  end

  defp pain?(card_info) do
    min_count?(card_info.card_names ++ card_info.zilliax_modules_names, 3, [
      "Fine Print",
      "Party Fiend",
      "Cursed Souvenir",
      "Trogg Exile",
      "Sheriff Barrelbrim",
      "Haywire Module",
      "Party Planner Vona"
    ])
  end

  defp amalgam?(card_info) do
    "Adaptive Amalgam" in card_info.card_names and
      min_count?(card_info, 2, [
        "Pit Stop",
        "SP-3Y3-D3R",
        "Sailboat Captain",
        "From the Scrapheap"
      ])
  end

  defp dorian_rogue?(card_info) do
    "Puppetmaster Dorian" in card_info.card_names
  end

  defp goldbeard?(ci) do
    min_count?(ci, 2, ["Shoplifter Goldbeard", "The Replicator-inator"])
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

  defp mech_rogue?(ci), do: type_count(ci, "Mech") > 5

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
        "Twisted Webweaver"
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
      "Dread Corsair",
      "Sharp Shipment",
      "Swarthy Swordshiner"
    ])
  end

  @cycle_payoff [
    "Fal'dorei Strider",
    "Everything Must Go!",
    "Playhouse Giant"
  ]
  @multi_draw [
    "Triple Sevens",
    "Gear Shift",
    "Gaslight Gatekeeper",
    "Knickknack Shack",
    "Eat! The! Imp!",
    "Twisted Webweaver",
    "Raiding Party",
    "Robocaller",
    "Ethereal Oracle",
    "Quick Pick",
    "Dubious Purchase"
  ]
  defp cycle_rogue?(ci) do
    min_count?(ci, 1, @cycle_payoff) and
      min_count?(ci, 3, @multi_draw)
  end

  defp pirate_rogue?(ci) do
    min_count?(ci, 3, [
      "Toy Boat",
      "Raiding Party",
      "Treasure Distributor",
      "Dig for Treasure",
      "Sailboat Captain",
      "Hozen Roughhouser",
      "Southsea Captain",
      "Shoplifter Goldbeard"
    ])
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
        "Hench-Clan Burglar",
        "Swashburglar"
      ])

  defp maestra_rogue?(card_info) do
    min_count?(card_info, 2, [
      "Maestra, Mask Merchant",
      "Tess Greymane"
    ])
  end

  def wild(card_info) do
    cond do
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

      "Kingsbane" in card_info.card_names ->
        :"Kingsbane Rogue"

      "King Togwaggle" in card_info.card_names ->
        :"Tog Rogue"

      wild_phoenix_rogue?(card_info) ->
        :"Phoenix Rogue"

      wild_gnoll_miracle_rogue?(card_info) ->
        :"Gnoll Miracle Rogue"

      wild_miracle_rogue?(card_info) ->
        :"Miracle Rogue"

      quasar?(card_info) ->
        :"Quasar Rogue"

      garrote?(card_info) ->
        :"Garrote Rogue"

      "Pirate Admiral Hooktusk" in card_info.card_names ->
        :"Hooktusk Rogue"

      wild_mill_rogue?(card_info) ->
        :"Mill Rogue"

      wild_alex_rogue?(card_info) ->
        :"Alex Rogue"

      wild_astalor_rogue?(card_info) ->
        :"Astalor Rogue"

      wild_pirate_rogue?(card_info) ->
        :"Pirate Rogue"

      mine_rogue?(card_info) ->
        :"Mine Rogue"

      wild_thief_rogue?(card_info) ->
        :"Thief Rogue"

      wild_draka_rogue?(card_info) ->
        :"Draka Rogue"

      "Spirit of the Shark" in card_info.card_names ->
        :"Shark Rogue"

      excavate_rogue?(card_info) ->
        :"Drilling Rogue"

      maestra_rogue?(card_info) ->
        :"Maestra Rogue"

      weapon?(card_info) ->
        :"Weapon Rogue"

      true ->
        fallbacks(card_info, "Rogue")
    end
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
      "Velarok",
      "Kaj'mite Creation",
      "Shell Game",
      "Obsidian Shard",
      "Velarok Windblade",
      "Vendetta",
      "Wildpaw Gnoll",
      "Stick Up",
      "Flint Firearm",
      "Thistle Tea Set"
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

  defp wild_draka_rogue?(card_info) do
    "Necrolord Draka" in card_info.card_names or
       "Necrolord Draka" in card_info.etc_sideboard_names
  end

  defp wild_phoenix_rogue?(card_info) do
    min_count?(card_info, 3, [
      "Everburning Phoenix",
      "Spiritsinger Umbra",
      "Knife Juggler"
    ])
  end
end
