# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.RogueArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander Rogue"

      menagerie?(card_info) ->
        :"Menagerie Rogue"

      mech_rogue?(card_info) ->
        :"Mech Rogue"

      coin_rogue?(card_info) ->
        :"Coin Rogue"

      ogre?(card_info) ->
        :"Ogre Rogue"

      excavate_rogue?(card_info) ->
        :"Drilling Rogue"

      pain?(card_info) and amalgam?(card_info) ->
        :"Amalgam Pain Rogue"

      amalgam?(card_info) ->
        :"Amalgam Rogue"

      pain?(card_info) and pirate_rogue?(card_info) ->
        :"Scurvy Rogue"

      pain?(card_info) ->
        :"Pain Rogue"

      mine_rogue?(card_info) ->
        :"Mine Rogue"

      pirate_rogue?(card_info) && thief_rogue?(card_info) ->
        :"Pirate Thief Rogue:"

      thief_rogue?(card_info) ->
        :"Thief Rogue"

      boar?(card_info) ->
        :"Boar Rogue"

      pirate_rogue?(card_info) and cycle_rogue?(card_info) ->
        :"Pirate Cycle Rogue"

      pirate_rogue?(card_info) ->
        :"Pirate Rogue"

      cycle_rogue?(card_info) and archon?(card_info) ->
        :"Archon Cycle Rogue"

      archon?(card_info) ->
        :"Archon Rogue"

      protoss?(card_info, 4) ->
        :"Protoss Rogue"

      cycle_rogue?(card_info) ->
        :"Cycle Rogue"

      cutlass_rogue?(card_info) ->
        :"Cutlass Rogue"

      miracle_rogue?(card_info) and miracle_wincon?(card_info) ->
        :"Miracle Rogue"

      goldbeard?(card_info) ->
        :"Goldbeard Rogue"

      "Lamplighter" in card_info.card_names ->
        :"Lamplighter Rogue"

      incindius?(card_info) ->
        :"Incindius Rogue"

      sonya?(card_info) ->
        :"Sonya Rogue"

      quasar?(card_info) ->
        :"Quasar Rogue"

      weapon?(card_info) ->
        :"Weapon Rogue"

      shaffar?(card_info) ->
        :"Shaffar Rogue"

      combo?(card_info) ->
        :"Combo Rogue"

      dorian_rogue?(card_info) ->
        :"Dorian Rogue"

      starship?(card_info) ->
        :"Starship Rogue"

      maestra_rogue?(card_info) ->
        :"Maestra Rogue"

      miracle_rogue?(card_info) ->
        :"Miracle Rogue"

      "Quasar" in card_info.card_names ->
        :"Quasar Rogue"

      "Photographer Fizzle" in card_info.card_names ->
        :"Fizzle Rogue"

      true ->
        fallbacks(card_info, "Rogue")
    end
  end

  defp combo?(card_info) do
    min_keyword_count?(card_info, 6, "combo")
  end

  defp quasar?(card_info) do
    "Quasar" in card_info.card_names and min_keyword_count?(card_info, 1, "spell-damage")
  end

  defp shaffar?(card_info) do
    # stupid official api has without - in the name field and with - in the image
    min_count?(card_info, 2, [
      "Nexus Prince Shaffar",
      "Nexus-Prince Shaffar",
      "Bargain Bin Buccaneer"
    ])
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

  defp archon?(ci) do
    sonya?(ci) and min_count?(ci, 1, ["Dark Templar", "High Templar"])
  end

  defp sonya?(ci) do
    min_count?(ci, 3, ["Cover Artist", "Sonya Waterdancer", "Sandbox Scoundrel"])
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

  defp coin_rogue?(ci) do
    "Wishing Well" in ci.card_names and
      min_count?(ci, 3, [
        "Dart Throw",
        "Greedy Partner",
        "Bounty Wrangler",
        "Oh, Manager!",
        "Counterfeit Coin",
        "Metal Detector"
      ])
  end

  defp miracle_rogue?(ci) do
    min_count?(ci, 4, ["Breakdance", "Tidepool Pupil", "Sonya Waterdancer", "Sandbox Scoundrel"])
  end

  defp miracle_wincon?(ci) do
    min_count?(ci, 1, ["Mixologist", "Griftah, Trusted Vendor"])
  end

  defp mech_rogue?(ci), do: type_count(ci, "Mech") > 5

  defp wild_gnoll_miracle_rogue?(card_info) do
    min_count?(card_info, 2, ["Wildpaw Gnoll", "Arcane Giant"])
  end

  defp wild_alex_rogue?(card_info) do
    "Spirit of the Shark" in card_info.card_names and
      "Alexstrasza the Life-Binder" in card_info.etc_sideboard_names
  end

  defp wild_miracle_rogue?(card_info) do
    min_count?(card_info, 3, [
      "Prize Plunderer",
      "Mailbox Dancer",
      "Arcane Giant",
      "Edwin VanCleef",
      "Lucky Comet",
      "Frostwolf Warmaster",
      "Scribbling Stenographer",
      "Zephrys the Great"
    ])
  end

  defp weapon?(ci) do
    min_count?(ci, 3, [
      "Deadly Poison",
      "Air Guitarist",
      "Harmonic Hip Hop",
      "Harmonic Hip-Hop",
      "Mic Drop",
      "Sharp Shipment",
      "Swarthy Swordshiner"
    ])
  end

  defp cutlass_rogue?(ci),
    do:
      "Spectral Cutlass" in ci.card_names and
        min_count?(ci, 3, [
          "Deadly Poison",
          "Valeera's Gift",
          "Harmonic Hip Hop",
          "Mic Drop",
          "Sonya Waterdancer",
          "Shadestone Skulker",
          "Instrument Tech"
        ])

  @cycle_payoff [
    "Fal'dorei Strider",
    "Everything Must Go!",
    "Playhouse Giant"
  ]
  @multi_draw [
    "Triple Sevens",
    "Gear Shift",
    "Gaslight Gatekeeper",
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
    min_count?(ci, 2, ["Toy Boat", "Raiding Party", "Treasure Distributor", "Dig for Treasure"]) and
      type_count(ci, "Pirate") > 5
  end

  defp thief_rogue?(ci),
    do:
      min_count?(ci, 6, [
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
    class_name = Deck.class_name(card_info.deck)

    cond do
      highlander?(card_info) ->
        String.to_atom("Highlander #{class_name}")

      questline?(card_info) ->
        String.to_atom("Questline #{class_name}")

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest #{class_name}")

      boar?(card_info) ->
        String.to_atom("Boar #{class_name}")

      baku?(card_info) ->
        String.to_atom("Odd #{class_name}")

      genn?(card_info) ->
        String.to_atom("Even #{class_name}")

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      "Majordomo Executus" in card_info.card_names ->
        :"Majordomo Rogue"

      "Kingsbane" in card_info.card_names ->
        :"Kingsbane Rogue"

      "King Togwaggle" in card_info.card_names ->
        String.to_atom("Tog #{class_name}")

      wild_draka_rogue?(card_info) ->
        :"Draka Rogue"

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

      wild_alex_rogue?(card_info) ->
        :"Alex Rogue"

      wild_pirate_rogue?(card_info) ->
        :"Pirate Rogue"

      mine_rogue?(card_info) ->
        :"Mine Rogue"

      wild_mill_rogue?(card_info) ->
        :"Mill Rogue"

      wild_thief_rogue?(card_info) ->
        :"Thief Rogue"

      bounty_draka?(card_info) ->
        :"APM Draka Rogue"

      "Spirit of the Shark" in card_info.card_names ->
        :"Shark Rogue"

      excavate_rogue?(card_info) ->
        :"Drilling Rogue"

      maestra_rogue?(card_info) ->
        :"Maestra Rogue"

      coin_rogue?(card_info) ->
        :"Coin Rogue"

      weapon?(card_info) ->
        :"Weapon Rogue"

      "Smokescreen" in card_info.card_names ->
        :"Smokescreen Rogue"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp bounty_draka?(ci) do
    min_count?(ci, 3, [
      "Tenwu Of The Red Smoke",
      "Tenwu of the Red Smoke",
      "Bounty Board",
      "Scabbs Cutterbutter"
    ]) and
      min_count?(ci.etc_sideboard_names, 3, [
        "Bounce Around (ft Garona)",
        "Bounce Around (ft. Garona)",
        "Potion Of Illusion",
        "Potion of Illusion",
        "Necrolord Draka"
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
      min_count?(card_info, 4, [
        "Coldlight Oracle",
        "Prize Vendor",
        "Togwaggle's Scheme",
        "Gang Up",
        "Lab Recruiter"
      ])
  end

  defp wild_draka_rogue?(card_info) do
    ("Necrolord Draka" in card_info.card_names or
       "Necrolord Draka" in card_info.etc_sideboard_names) and
      min_count?(card_info, 4, [
        "Brann Bronzebeard",
        "Mailbox Dancer",
        "Tidepool Pupil",
        "Shadowstep"
      ])
  end
end
