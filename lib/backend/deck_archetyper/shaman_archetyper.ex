# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.ShamanArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.DeckArchetyper.DemonHunterArchetyper
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander Shaman"

      menagerie?(card_info) ->
        :"Menagerie Shaman"

      totem_shaman?(card_info) ->
        :"Totem Shaman"

      big?(card_info) ->
        :"Big Shaman"

      rainbow?(card_info) or rainbow_cards?(card_info, 2) ->
        :"Rainbow Shaman"

      jive?(card_info) ->
        :"Jive Shaman"

      DemonHunterArchetyper.pirate?(card_info) ->
        :"Pirate Shaman"

      bonk?(card_info) ->
        :"Bonk Shaman"

      incindius?(card_info) ->
        :"Incindius Shaman"

      elemental_shaman?(card_info) ->
        :"Elemental Shaman"

      spell_damage_shaman?(card_info) ->
        :"Spell Damage Shaman"

      nature_shaman?(card_info) ->
        :"Nature Shaman"

      overload_shaman?(card_info) ->
        :"Overload Shaman"

      excavate_shaman?(card_info) ->
        :"Excavate Shaman"

      evolve_shaman?(card_info) ->
        :"Evolve Shaman"

      murloc?(card_info) ->
        :"Murloc Shaman"

      wish_shaman?(card_info) ->
        :"Wish Shaman"

      "Travelmaster Dungar" in card_info.card_names ->
        :"Dungar Shaman"

      "Wave of Nostalgia" in card_info.card_names ->
        :"Nostalgia Shaman"

      true ->
        fallbacks(card_info, "Shaman")
    end
  end

  defp bonk?(card_info) do
    min_count?(card_info, 3, ["Horn of the Windlord", "Skirting Death", "Turn the Tides"])
  end

  defp rainbow?(card_info) do
    rainbow_cards?(card_info, 1) and
      spell_school_count(card_info) >= 4
  end

  defp rainbow_cards?(card_info, min_count) do
    min_count?(card_info, min_count, [
      "Siren Song",
      "Cabaret Headliner",
      "Carress, Cabaret Star",
      "Razzle-Dazzler"
    ])
  end

  defp jive?(card_info) do
    min_count?(card_info, 3, ["Conductivity", "Sigil of Skydiving", "JIVE, INSECT!"])
  end

  defp incindius?(card_info) do
    min_count?(card_info, 3, ["Incindius", "Shudderblock", "Gaslight Gatekeeper"])
  end

  defp wish_shaman?(card_info) do
    "Wish Upon a Star" in card_info.card_names and
      min_count?(card_info, 3, [
        "Leeroy Jenkins",
        "Outfit Tailor",
        "Al'Akir the Windlord",
        "Backstage Bouncer",
        "Southsea Deckhand",
        "Murloc Growfin"
      ])
  end

  defp excavate_shaman?(card_info) do
    min_count?(
      card_info,
      3,
      ["Shroomscavate", "Sir Finley, the Intrepid", "Digging Straight Down" | neutral_excavate()]
    )
  end

  defp totem_shaman?(ci) do
    min_count?(ci, 2, ["Gigantotem", "Grand Totem Eys'or", "The Stonewright"])
  end

  defp spell_damage_shaman?(ci) do
    min_count?(ci, 3, ["Novice Zapper", "Spirit Claws" | neutral_spell_damage()])
  end

  defp nature_shaman?(ci),
    do:
      min_count?(ci, 2, [
        "Flash of Lightning",
        "Crash of Thunder",
        "Champion of Storms"
      ])

  defp big?(ci) do
    "Cliff Dive" in ci.card_names
  end

  defp overload_shaman?(ci),
    do: min_count?(ci, 2, ["Flowrider", "Overdraft", "Inzah", "Thorim, Stormlord"])

  defp evolve_shaman?(ci),
    do:
      min_count?(ci, 3, [
        "Convincing Disguise",
        "Muck Pools",
        "Matching Outfits",
        "Wave of Nostalgia",
        "Primordial Wave",
        "Carefree Cookie",
        "Baroness Vashj",
        "Tiny Toys"
      ])

  defp elemental_shaman?(ci),
    do:
      min_count?(ci, 5, [
        "Flame Revenant",
        "Shale Spider",
        "Lamplighter",
        "Minecart Cruiser",
        "Living Prairie",
        "Eroded Sediment",
        "Therazane",
        "Dang-Blasted Elemental",
        "Skarr, the Catastrophe",
        "Azerite Giant",
        "Kalimos, Primal Lord"
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

      "Shudderwock" in card_info.card_names ->
        :"Shudderwock Shaman"

      "King Togwaggle" in card_info.card_names ->
        String.to_atom("Tog #{class_name}")

      wild_big_shaman?(card_info) ->
        :"Big Shaman"

      wild_pirate?(card_info) ->
        :"Pirate Shaman"

      "Mecha'thun" in card_info.card_names ->
        String.to_atom("Mecha'thun #{class_name}")

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp wild_pirate?(card_info) do
    min_count?(card_info, 2, ["Patches the Pilot", "Patches the Pirate"])
  end

  defp wild_big_shaman?(card_info) do
    min_count?(card_info, 2, ["Muckmorpher", "Eureka!", "Ancestor's Call"])
  end
end
