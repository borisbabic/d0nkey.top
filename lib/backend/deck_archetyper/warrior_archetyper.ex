# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.WarriorArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Warrior"

      handbuff?(card_info) ->
        :"Handbuff Warrior"

      murloc?(card_info) ->
        :"Murloc Warrior"

      dragon?(card_info) ->
        :"Dragon Warrior"

      herald?(card_info, 5) ->
        :"Harold Warrior"

      "Gladiatorial Combat" in card_info.card_names ->
        :"Gladiator Warrior"

      "Ysondre" in card_info.card_names ->
        :"Ysondre Warrior"

      type_count(card_info, "Dragon") > 5 ->
        :"Dragon Warrior"

      burn_warrior?(card_info) ->
        :"Burn Warrior"

      patron?(card_info) and enrage_warrior?(card_info) ->
        :"Patron Warrior"

      enrage_warrior?(card_info) ->
        :"Enrage Warrior"

      herald?(card_info) ->
        :"Harold Warrior"

      patron?(card_info) ->
        :"Patron Warrior"

      "Briarspawn Drake" in card_info.card_names ->
        :"Briarspawn Warrior"

      warrior_aoe?(card_info) ->
        :"Control Warrior"

      type_count(card_info, "Pirate") >= 5 ->
        :"Pirate Warrior"

      "Lo'Gosh, Blood Fighter" in card_info.card_names ->
        :"Lo'Gosh Warrior"

      true ->
        fallbacks(card_info, "Warrior")
    end
  end

  defp patron?(card_info) do
    "Destructive Blaze" in card_info.card_names
  end

  defp burn_warrior?(card_info) do
    min_count?(card_info, 1, ["Time-Twisted Seer"]) and
      min_count?(card_info, 3, [
        "Rockskipper",
        "Bash",
        "Precursory Strike",
        "Shadowflame Suffusion"
      ])
  end

  defp dragon?(card_info) do
    min_count?(
      card_info,
      3,
      [
        "Giftwrapped Whelp",
        "Windspeak Wyrm",
        "Brood Keeper",
        "Darkrider"
      ] ++ neutral_dragon_synergy()
    )
  end

  defp enrage_warrior?(card_info) do
    min_count?(card_info, 3, [
      "Sanguine Depths",
      "Ominous Nightmares",
      "Stonecarver",
      "Eggbasher",
      "Bloodhoof Brave",
      "City Defenses",
      "Nablya, the Watcher",
      "Grommash Hellscream",
      "Scaring Fissure",
      "Undercover Cultist"
    ])
  end

  defp handbuff?(card_info) do
    "Keeper of Flame" in card_info.card_names
  end

  defp warrior_aoe?(ci, min_count \\ 4),
    do:
      min_count?(ci, min_count, [
        "Brawl",
        "Aftershocks",
        "Sanitize",
        "Decimation",
        "Garrosh's Gift",
        "Shellnado",
        "Bladestorm",
        "Hostile Invader"
      ])

  def wild(card_info) do
    cond do
      questline?(card_info) and highlander?(card_info) ->
        :"HL Questline Warrior"

      quest?(card_info) and highlander?(card_info) ->
        String.to_atom("HL #{quest_abbreviation(card_info)} Quest Warrior")

      "Unlucky Powderman" in card_info.card_names and highlander?(card_info) ->
        :"HL Taunt Warrior"

      n_roll?(card_info) and highlander?(card_info) ->
        :"HL 'n' Roll Warrior"

      igneous?(card_info) and highlander?(card_info) ->
        :"HL Igneous Warrior"

      highlander?(card_info) ->
        :"Highlander Warrior"

      questline?(card_info) ->
        :"Questline Warrior"

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest Warrior")

      boar?(card_info) ->
        :"Boar Warrior"

      baku?(card_info) ->
        :"Odd Warrior"

      genn?(card_info) ->
        :"Even Warrior"

      "King Togwaggle" in card_info.card_names ->
        :"Tog Warrior"

      wild_handbuff_warrior?(card_info) ->
        :"Handbuff Warrior"

      min_count?(card_info, 2, ["Blackrock 'n' Roll", "Unlucky Powderman"]) ->
        :"Taunt 'n' Roll Warrior"

      n_roll?(card_info) ->
        :"Rock 'n' Roll Warrior"

      sulthraze?(card_info) and odyn?(card_info) ->
        :"Sul'thraze Odyn Warrior"

      igneous?(card_info) and odyn?(card_info) ->
        :"Igneous Odyn Warrior"

      odyn?(card_info) ->
        :"Odyn Warrior"

      "Barricade Basher" in card_info.card_names ->
        :"Basher Warrior"

      gauntlet?(card_info) ->
        :"Gauntlet Warrior"

      "Warsong Commander" in card_info.card_names ->
        :"Warsong Warrior"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun Warrior"

      "Dead Man's Hand" in card_info.card_names ->
        :"DMH Warrior"

      "Hydration Station" in card_info.card_names ->
        :"Hydration Warrior"

      "Unlucky Powderman" in card_info.card_names ->
        :"Taunt Warrior"

      "Rivendare, Warrider" in card_info.card_names ->
        :"Rivendare Warrior"

      "Mecha'thun" in card_info.etc_sideboard_names and
          "Thaddius, Monstrosity" in card_info.card_names ->
        :"Mecha'Chad Warrior"

      "Thaddius, Monstrosity" in card_info.card_names ->
        :"Chad Warrior"

      sulthraze?(card_info) ->
        :"Sul'thraze Warrior"

      true ->
        fallbacks(card_info, "Warrior")
    end
  end

  defp igneous?(card_info) do
    min_count?(card_info, 2, ["Igneous Lavagorger", "The Ceaseless Expanse"])
  end

  defp odyn?(card_info), do: "Odyn, Prime Designate" in card_info.card_names

  defp sulthraze?(card_info), do: "Sul'thraze" in card_info.card_names

  defp n_roll?(card_info), do: "Blackrock 'n' Roll" in card_info.card_names

  defp gauntlet?(card_info) do
    min_count?(card_info, 2, ["Bladed Gauntlet", "Bloodsail Raider"])
  end

  defp wild_handbuff_warrior?(card_info) do
    min_count?(card_info, 1, ["Anima Extractor"])
  end
end
