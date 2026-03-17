# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.ShamanArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Shaman"

      imbue?(card_info, 4) ->
        :"Imbue Shaman"

      elemental_shaman?(card_info) ->
        :"Elemental Shaman"

      masochist?(card_info) ->
        :"Masochist Shaman"

      spell_damage_shaman?(card_info) ->
        :"Spell Damage Shaman"

      evolve_shaman?(card_info) ->
        :"Evolve Shaman"

      murloc?(card_info) ->
        :"Murloc Shaman"

      herald?(card_info) ->
        :"Harold Shaman"

      "Haywire Hornswog" in card_info.card_names ->
        :"Overload Shaman"

      "Farseer Wo" in card_info.card_names ->
        :"Wo Shaman"

      true ->
        fallbacks(card_info, "Shaman")
    end
  end

  defp masochist?(card_info) do
    min_count?(card_info, 4, [
      "Static Shock",
      "Lightning Rod",
      "Flux Revenant",
      "Thunderquake",
      "Nascent Bolt",
      "Stormrook",
      "Cash Cow"
    ])
  end

  defp asteroid?(card_info, min_count \\ 3) do
    min_count?(card_info, min_count, [
      "Ultraviolet Breaker",
      "Meteor Storm",
      "Bolide Behemoth",
      "Moonstone Mauler"
    ])
  end

  defp spell_damage_shaman?(ci) do
    min_count?(ci, 3, [
      "Novice Zapper",
      "Lightning Bolt",
      "Shade of the End Time" | neutral_spell_damage()
    ])
  end

  @standard_evolve [
    "Ascendance",
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

  defp elemental_shaman?(ci) do
    min_count?(ci, 5, [
      "Wailing Vapor",
      "Volcanic Thrasher",
      "Slagclaw",
      "Fire Breath",
      "Menacing Nimbus",
      "Flame Revenant",
      "Shale Spider",
      "Lamplighter",
      "Minecart Cruiser",
      "Living Prairie",
      "Eroded Sediment",
      "Therazane",
      "Dang-Blasted Elemental",
      "Bralma Searstone",
      "Skarr, the Catastrophe",
      "Azerite Giant",
      "Kalimos, Primal Lord"
    ]) or
      ("City Chief Esho" in ci.card_names and type_count(ci, "Elemental") > 3)
  end

  def wild(card_info) do
    cond do
      questline?(card_info) and highlander?(card_info) ->
        :"HL Questline Shaman"

      quest?(card_info) and highlander?(card_info) ->
        String.to_atom("HL #{quest_abbreviation(card_info)} Quest Shaman")

      "Shudderwock" in card_info.card_names and highlander?(card_info) ->
        :"HL Shudder Shaman"

      highlander?(card_info) ->
        :"Highlander Shaman"

      questline?(card_info) ->
        :"Questline Shaman"

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest Shaman")

      boar?(card_info) ->
        :"Boar Shaman"

      baku?(card_info) ->
        :"Odd Shaman"

      genn?(card_info) ->
        :"Even Shaman"

      "Shudderwock" in card_info.card_names ->
        :"Shudderwock Shaman"

      "King Togwaggle" in card_info.card_names ->
        :"Tog Shaman"

      "Ohn'ahra" in card_info.card_names and wild_big_shaman?(card_info) ->
        :"Ohn'ahra Big Shaman"

      "Ohn'ahra" in card_info.card_names ->
        :"Ohn'ahra Shaman"

      wild_big_shaman?(card_info) ->
        :"Big Shaman"

      wild_evolve?(card_info) ->
        :"Evolve Shaman"

      asteroid?(card_info) ->
        :"Asteroid Shaman"

      wild_murmur?(card_info) ->
        :"Murmur Shaman"

      wild_pirate?(card_info) ->
        :"Pirate Shaman"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun Shaman"

      true ->
        fallbacks(card_info, "Shaman")
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
