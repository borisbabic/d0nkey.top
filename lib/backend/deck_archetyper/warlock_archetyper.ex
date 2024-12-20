# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.WarlockArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander Warlock"

      implock?(card_info) && (quest?(card_info) || questline?(card_info)) ->
        :"Quest Implock"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Warlock"

      menagerie?(card_info) ->
        :"Menagerie Warlock"

      murloc?(card_info) ->
        :"Murloc Warlock"

      implock?(card_info) && boar?(card_info) ->
        :"Boar Implock"

      boar?(card_info) ->
        :"Boar Warlock"

      implock?(card_info) && phylactery_warlock?(card_info) ->
        :"Phylactery Implock"

      phylactery_warlock?(card_info) ->
        :"Phylactery Warlock"

      snek?(card_info) ->
        :"Snek Warlock"

      armor?(card_info) ->
        :"Armor Warlock"

      deathrattle?(card_info) ->
        :"Deathrattle Warlock"

      implock?(card_info) && abyssal_warlock?(card_info) && chad?(card_info) ->
        :"Abyssal Chimplock"

      implock?(card_info) && chad?(card_info) ->
        :Chimplock

      implock?(card_info) && handlock?(card_info) ->
        :"Hand Implock"

      big_demon_warlock?(card_info) ->
        :"Big Demon Warlock"

      implock?(card_info) && agony_warlock?(card_info) ->
        :"Agony Implock"

      agony_warlock?(card_info) ->
        :"Agony Warlock"

      abyssal_warlock?(card_info) && chad?(card_info) ->
        :"Abyssal Chadlock"

      implock?(card_info) && abyssal_warlock?(card_info) ->
        :"Abyssal Implock"

      chad?(card_info) ->
        :Chadlock

      abyssal_warlock?(card_info) ->
        :"Abyssal Warlock"

      implock?(card_info) ->
        :Implock

      sludgelock?(card_info) ->
        :"Sludge Warlock"

      snek?(card_info) ->
        :"Snek Warlock"

      handlock?(card_info) ->
        :Handlock

      painlock?(card_info) ->
        :Painlock

      fatigue_warlock?(card_info) ->
        :"Insanity Warlock"

      starship?(card_info) ->
        :"Starship Warlock"

      demon?(card_info) ->
        :"Demon Warlock"

      deckless?(card_info) ->
        :"Deckless Warlock"

      leeroy_warlock?(card_info) ->
        :"Leeroooooy Warlock"

      control_warlock?(card_info) ->
        :"Control Warlock"

      discard?(card_info, 5) ->
        :"Discard Warlock"

      "Lord Jaraxxus" in card_info.card_names ->
        :"J-Lock"

      true ->
        fallbacks(card_info, "Warlock")
    end
  end

  defp demon?(ci) do
    min_count?(ci, 3, [
      "Kil'jaeden",
      "Demonic Dynamics",
      "Abduction Ray",
      "Archimonde",
      "Foreboding Flame"
    ])
  end

  @spec deckless?(ArchetyperHelpers.card_info()) :: boolean()
  defp deckless?(ci) do
    min_count?(ci.card_names ++ ci.etc_sideboard_names, 1, ["Kil'jaeden", "Wheel of DEATH!!!"])
  end

  defp armor?(card_info) do
    "Arkonite Defense Crystal" in card_info.card_names and deathrattle?(card_info)
  end

  defp deathrattle?(card_info) do
    min_count?(card_info, 2, ["Felfire Bonfire", "Summoner Darkmarrow", "Brittlebone Buccaneer"])
  end

  defp leeroy_warlock?(card_info) do
    min_count?(card_info, 3, ["Leeroy Jenkins", "Monstrous Form", "Reverberations"])
  end

  defp snek?(ci) do
    excavates = [
      "Smokestack",
      "Mo'arg Drillfist",
      "Tram Conductor Gerry" | neutral_excavate()
    ]

    min_count?(ci, 4, excavates) or
      (min_count?(ci, 2, excavates) and neutral_bouncers?(ci))
  end

  defp painlock?(ci) do
    min_count?(ci, 4, [
      "Flame Imp",
      "Spirit Bomb",
      "Malefic Rook",
      "Lesser Amethyst Spellstone",
      "Molten Giant",
      "Imprisoned Horror",
      "Trogg Exile",
      "INFERNAL!",
      "Mass Production",
      "Elementium Geode"
    ])
  end

  defp big_demon_warlock?(ci) do
    min_count?(ci, 1, ["Felfire Bonfire", "Game Master Nemsy", "Crane Game", "Dirge of Despair"]) and
      min_count?(ci, 1, ["Enhanced Dreadlord", "Wretched Queen"])
  end

  defp sludgelock?(ci) do
    min_count?(ci, 3, [
      "Tram Mechanic",
      "Disposal Assistant",
      "Sludge on Wheels",
      "Pop'gar the Putrid"
    ])
  end

  @self_fatigue_package ["Crescendo", "Baritone Imp", "Crazed Conductor"]
  defp fatigue_warlock?(ci) do
    min_count?(ci, 2, ["Pop'gar the Putrid", "Encroaching Insanity"]) and
      min_count?(ci, 3, @self_fatigue_package)
  end

  defp control_warlock?(ci) do
    min_count?(ci, 5, [
      "Sargeras, the Destroyer",
      "Symphony of Sins",
      "Domino Effect",
      "Defile",
      "Drain Soul",
      "Mortal Eradication",
      "Thornveil Tentacle",
      "Armor Vendor",
      "Prison of Yogg-Saron",
      "Gigafin"
    ])
  end

  defp implock?(ci),
    do:
      min_count?(ci, 6, [
        "Bloodbound Imp",
        "Desk Imp",
        "Fiendish Circle",
        "Flame Imp",
        "Flustered Librarian",
        "Imp Gang Boss",
        "Imp King Rafaam",
        "Imp Swarm (Rank 1)",
        "Impending Catastrophe",
        "Malchezaar's Imp",
        "Mischievous Imp",
        "Nofin's Imp-ossible",
        "Piggyback Imp",
        "Vile Library",
        "Wicked Shipment"
      ])

  defp phylactery_warlock?(%{card_names: card_names}),
    do: "Tamsin's Phylactery" in card_names && "Tamsin Roame" in card_names

  defp abyssal_warlock?(ci),
    do: min_count?(ci, 3, ["Dragged Below", "Sira'kess Cultist", "Za'qul", "Abyssal Wave"])

  defp agony_warlock?(%{card_names: card_names}), do: "Curse of Agony" in card_names

  defp handlock?(ci),
    do: min_count?(ci, 2, ["Mountain Giant", "Table Flip"])

  defp chad?(ci) do
    min_count?(ci, 2, ["Amorphous Slime", "Thaddius, Monstrosity"])
  end

  def wild(card_info) do
    class_name = Deck.class_name(card_info.deck)

    cond do
      highlander?(card_info) ->
        String.to_atom("Highlander #{class_name}")

      "The Demon Seed" in card_info.card_names ->
        :Seedlock

      questline?(card_info) ->
        String.to_atom("Questline #{class_name}")

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest #{class_name}")

      baku?(card_info) ->
        String.to_atom("Odd #{class_name}")

      genn?(card_info) ->
        String.to_atom("Even #{class_name}")

      discard?(card_info, 10) ->
        :"Discard Warlock"

      sludgelock?(card_info) ->
        :"Sludge Warlock"

      fatigue_warlock?(card_info) ->
        :"Insanity Warlock"

      wild_fatigue_warlock?(card_info) ->
        :"Fatigue Warlock"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun #{class_name}"

      discard?(card_info, 6) ->
        :"Discard Warlock"

      boar?(card_info) ->
        String.to_atom("Boar #{class_name}")

      "King Togwaggle" in card_info.card_names ->
        String.to_atom("Tog #{class_name}")

      implock?(card_info) ->
        :Implock

      deckless?(card_info) ->
        :"Deckless Warlock"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp discard?(card_info, min_count) do
    min_count?(card_info, min_count, [
      "Shriek",
      "Darkshire Librarian",
      "Clutchmother Zavas",
      "Felstaker",
      "Reckless Diretroll",
      "Howlfiend",
      "Plague Eruption",
      "Trolley Problem",
      "Suffocating Shadows",
      "High Priestess Jeklik",
      "Wing Welding",
      "Nightshade Matron",
      "Lakkari Felhound",
      "Disciple of Sargeras",
      "Gloomstone Guardian",
      "Doomguard",
      "Cruel Dinomancer",
      "Spawn of Deathwing",
      "Savage Ymirjar",
      "Amorphous Slime",
      "Rin, Orchestrator of Doom",
      "Malchezaar's Imp",
      "Blood-Queen Lana'thel",
      "Felsoul Jailer",
      "Cataclysm",
      "Tome Tampering",
      "Soulwarden",
      "Hand of Gul'dan",
      "Cho'gall",
      "Grimtotem Buzzkill",
      "Furnacefire Colossus",
      "Deathwing the Destroyer",
      "Deathwing",
      "Soulfire",
      "The Soularium",
      "Wicked Whispers",
      "Boneweb Egg",
      "Expired Merchant",
      "Tiny Knight of Evil",
      "Chamber of Viscidus",
      "Scourge Supplies",
      "Silverware Golem",
      "Walking Dead",
      "Dark Bargain",
      "Fist of Jaraxxus",
      "Deadline",
      "Soul Barrage"
    ])
  end

  defp wild_fatigue_warlock?(card_info) do
    min_count?(
      card_info,
      5,
      [
        "Altar of Fire",
        "Blood Shard Bristleback",
        "Soul Rend",
        "Neeru Fireblade",
        "Barrens Scavenger",
        "Tickatus",
        "Fanottem, Lord of the Opera"
      ]
    )
  end
end
