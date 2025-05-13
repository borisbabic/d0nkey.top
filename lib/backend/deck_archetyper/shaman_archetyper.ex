# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.ShamanArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.DeckArchetyper.DemonHunterArchetyper
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      menagerie?(card_info) ->
        :"Menagerie Shaman"

      big?(card_info) ->
        :"Big Shaman"

      asteroid?(card_info) and imbue?(card_info, 4) ->
        :"Asteroid Imbue Shaman"

      imbue?(card_info, 4) ->
        :"Imbue Shaman"

      asteroid?(card_info) ->
        :"Asteroid Shaman"

      incindius?(card_info) ->
        :"Incindius Shaman"

      elemental_shaman?(card_info) ->
        :"Elemental Shaman"

      # infinite?(card_info) and terran?(card_info, 4) ->
      #   :"Infinite Terran Shaman"

      "Arkonite Defense Crystal" in card_info.card_names and terran?(card_info, 4) ->
        :"Defense Terran Shaman"

      terran?(card_info, 4) ->
        :"Terran Shaman"

      rainbow?(card_info) or rainbow_cards?(card_info, 2) ->
        :"Rainbow Shaman"

      DemonHunterArchetyper.pirate?(card_info) ->
        :"Pirate Shaman"

      spell_damage_shaman?(card_info) ->
        :"Spell Damage Shaman"

      evolve_shaman?(card_info) ->
        :"Evolve Shaman"

      murloc?(card_info) ->
        :"Murloc Shaman"

      wish_shaman?(card_info) ->
        :"Wish Shaman"

      "Travelmaster Dungar" in card_info.card_names ->
        :"Dungar Shaman"

      "Nebula" in card_info.card_names ->
        :"Nebula Shaman"

      murmur?(card_info) ->
        :"Murmur Shaman"

      "Turbulus" in card_info.card_names ->
        :"Turbulus Shaman"

      concede?(card_info) ->
        :"Concede Shaman"

      true ->
        fallbacks(card_info, "Shaman")
    end
  end

  defp concede?(card_info) do
    min_count?(card_info, 2, ["Hex", "Conductivity"])
  end

  defp murmur?(card_info) do
    "Murmur" in card_info.card_names
  end

  defp asteroid?(card_info, min_count \\ 3) do
    min_count?(card_info, min_count, [
      "Ultraviolet Breaker",
      "Meteor Storm",
      "Bolide Behemoth",
      "Moonstone Mauler"
    ])
  end

  defp rainbow?(card_info) do
    rainbow_cards?(card_info, 1) and
      spell_school_count(card_info) >= 3
  end

  defp rainbow_cards?(card_info, min_count) do
    min_count?(card_info, min_count, [
      "Siren Song",
      "Cabaret Headliner",
      "Carress, Cabaret Star",
      "Razzle-Dazzler"
    ])
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

  defp spell_damage_shaman?(ci) do
    min_count?(ci, 3, ["Novice Zapper", "Spirit Claws", "Lightning Bolt" | neutral_spell_damage()])
  end

  defp big?(ci) do
    "Cliff Dive" in ci.card_names
  end

  @standard_evolve [
    "Convincing Disguise",
    "Muck Pools",
    "Matching Outfits",
    "Wave of Nostalgia",
    "Primordial Wave",
    "Carefree Cookie",
    "Plucky Podling",
    "Baroness Vashj",
    "Tiny Toys"
  ]
  defp evolve_shaman?(ci),
    do: min_count?(ci, 3, @standard_evolve)

  defp elemental_shaman?(ci),
    do:
      min_count?(ci, 5, [
        "Wailing Vapor",
        "Menacing Nimbus",
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

      asteroid?(card_info) ->
        :"Asteroid Shaman"

      wild_murmur?(card_info) ->
        :"Murmur Shaman"

      wild_pirate?(card_info) ->
        :"Pirate Shaman"

      "Mecha'thun" in card_info.card_names ->
        String.to_atom("Mecha'thun #{class_name}")

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp wild_murmur?(card_info) do
    min_count?(card_info, 2, ["Murmur", "Shudderblock"])
  end

  defp wild_pirate?(card_info) do
    min_count?(card_info, 2, ["Patches the Pilot", "Patches the Pirate"])
  end

  defp wild_big_shaman?(card_info) do
    min_count?(card_info, 2, ["Muckmorpher", "Eureka!", "Ancestor's Call"])
  end

  def wild_evolve?(card_info) do
    min_count?(card_info, 4, [
      "Boggspine Knuckles",
      "Doppelgangster",
      "Unstable Evolution",
      "Evolve",
      "Revolve",
      "Desert Hare" | @standard_evolve
    ])
  end
end
