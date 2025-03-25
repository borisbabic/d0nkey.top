# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.WarriorArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander Warrior"

      taunt_warrior?(card_info) ->
        :"Taunt Warrior"

      n_roll?(card_info) && menagerie_warrior?(card_info) ->
        :"Menagerie 'n' Roll"

      n_roll?(card_info) && enrage?(card_info) ->
        :"Enrage 'n' Roll"

      menagerie_warrior?(card_info) ->
        :"Menagerie Warrior"

      enrage?(card_info) ->
        :"Enrage Warrior"

      n_roll?(card_info) ->
        :"Rock 'n' Roll Warrior"

      excavate_warrior?(card_info) && odyn?(card_info) ->
        :"Excavate Odyn Warrior"

      # cycle_odyn?(card_info) -> :"Cycle Odyn Warrior"

      terran?(card_info, 4) ->
        :"Terran Warrior"

      odyn?(card_info) ->
        :"Odyn Warrior"

      excavate_warrior?(card_info) ->
        :"Excavate Warrior"

      draenei?(card_info) ->
        :"Draenei Warrior"

      mech_warrior?(card_info) ->
        :"Mech Warrior"

      bomb_warrior?(card_info) ->
        :"Bomb Warrior"

      "The Ryecleaver" in card_info.card_names ->
        :"Sandwich Warrior"

      riff_warrior?(card_info) ->
        :"Riff Warrior"

      weapon_warrior?(card_info) ->
        :"Weapon Warrior"

      "Deepminer Brann" in card_info.card_names ->
        :"Brann Warrior"

      murloc?(card_info) ->
        :"Murloc Warrior"

      boar?(card_info) ->
        :"Boar Warrior"

      "Justicar Trueheart" in card_info.card_names ->
        :"Justicar Warrior"

      "Safety Expert" in card_info.card_names ->
        :"Safety Warrior"

      type_count(card_info, "dragon") > 5 ->
        :"Dragon Warrior"

      "Hydration Station" in card_info.card_names ->
        :"Hydration Warrior"

      "Ysondre" in card_info.card_names ->
        :"Ysondre Warrior"

      warrior_aoe?(card_info) ->
        :"Control Warrior"

      type_count(card_info, "Pirate") >= 5 ->
        :"Pirate Warrior"

      sulthraze?(card_info) ->
        :"Sul'thraze Warrior"

      "Photographer Fizzle" in card_info.card_names ->
        :"Fizzle Warrior"

      true ->
        fallbacks(card_info, "Warrior")
    end
  end

  def sulthraze?(ci) do
    min_count?(ci, 2, ["Sul'thraze", "Punch Card"])
  end

  def taunt_warrior?(ci) do
    min_count?(ci, 3, ["Battlepickaxe", "Detonation Juggernaut", "Unlucky Powderman"])
  end

  def bomb_warrior?(card_info) do
    min_count?(card_info, 2, ["Explodineer", "Safety Expert"])
  end

  def mech_warrior?(card_info) do
    min_count?(card_info, 2, ["Boom Wrench", "Testing Dummy"])
  end

  def draenei?(card_info) do
    type_count(card_info, "Draenei") > 5
  end

  defp odyn?(card_info) do
    "Odyn, Prime Designate" in card_info.card_names
  end

  # defp cycle_odyn?(ci) do
  #   odyn?(ci) and
  #     min_count?(ci, 3, [
  #       "Acolyte of Pain",
  #       "Needlerock Totem",
  #       "Stoneskin Armorer",
  #       "Gold Panner"
  #     ])
  # end

  defp excavate_warrior?(ci),
    do:
      min_count?(ci, 3, [
        "Blast Charge",
        "Reinforced Plating",
        "Slagmaw the Slumbering",
        "Badlands Brawler" | neutral_excavate()
      ])

  defp riff_warrior?(ci), do: min_count?(ci, 3, ["Verse Riff", "Chorus Riff", "Bridge Riff"])

  defp n_roll?(card_info), do: "Blackrock 'n' Roll" in card_info.card_names

  defp menagerie_warrior?(card_info) do
    min_count?(card_info, 3, [
      "Roaring Applause",
      "Party Animal",
      "The One-Amalgam Band",
      "All You Can Eat",
      "Rock Master Voone",
      "Power Slider"
    ])
  end

  defp enrage?(ci) do
    min_count?(ci, 5, [
      "Sanguine Depths",
      "Warsong Envoy",
      "Whirlwind",
      "Anima Extractor",
      "Crazed Wretch",
      "Cruel Taskmaster",
      "Frothing Berserker",
      "Sunfury Champion",
      "Jam Session",
      "Imbued Axe",
      "Grommash Hellscream"
    ])
  end

  defp warrior_aoe?(ci, min_count \\ 4),
    do:
      min_count?(ci, min_count, [
        "Brawl",
        "Aftershocks",
        "Sanitize",
        "Garrosh's Gift",
        "Bladestorm",
        "Hostile Invader"
      ])

  defp weapon_warrior?(ci),
    do:
      min_count?(ci, 3, [
        "Azsharan Trident",
        "Outrider's Axe",
        "Blacksmithing Hammer",
        "Lady Ashvane"
      ])

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

      "King Togwaggle" in card_info.card_names ->
        String.to_atom("Tog #{class_name}")

      wild_handbuff_warrior?(card_info) ->
        :"Handbuff Warrior"

      n_roll?(card_info) ->
        :"Rock 'n' Roll Warrior"

      "Odyn, Prime Designate" in card_info.card_names ->
        :"Odyn Warrior"

      "Warsong Commander" in card_info.card_names ->
        :"Warsong Warrior"

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      wild_dmh_warrior?(card_info) ->
        :"DMH Warrior"

      raider?(card_info) ->
        :"Raider Warrior"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp raider?(card_info) do
    min_count?(card_info, 2, ["Bladed Gauntlet", "Bloodsail Raider"])
  end

  defp wild_handbuff_warrior?(card_info) do
    min_count?(card_info, 1, ["Anima Extractor"])
  end

  defp wild_dmh_warrior?(card_info) do
    min_count?(card_info, 2, [
      "Dead Man's Hand",
      "Marin the Manager"
    ])
  end
end
