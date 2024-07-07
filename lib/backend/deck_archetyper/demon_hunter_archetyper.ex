defmodule Backend.DeckArchetyper.DemonHunterArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers

  def standard(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander DH"

      boar?(card_info) ->
        :"Boar Demon Hunter"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Demon Hunter"

      deathrattle_dh?(card_info) ->
        :"Deathrattle DH"

      clean_slate_dh?(card_info) ->
        :"Clean Slate DH"

      big_dh?(card_info) ->
        :"Big Demon Hunter"

      murloc?(card_info) ->
        :"Murloc Demon Hunter"

      fel_dh?(card_info) && spell_dh?(card_info) && relic_dh?(card_info) ->
        :"Spffellic Demon Hunter"

      spell_dh?(card_info) && fel_dh?(card_info) ->
        :"Spffell Demon Hunter"

      spell_dh?(card_info) && relic_dh?(card_info) ->
        :"Spellic Demon Hunter"

      fel_dh?(card_info) && relic_dh?(card_info) ->
        :"Felic Demon Hunter"

      spell_dh?(card_info) ->
        :"Spell Demon Hunter"

      naga_dh?(card_info) and shopper_dh?(card_info) ->
        :"Naga Shopper DH"

      naga_dh?(card_info) ->
        :"Naga Demon Hunter"

      menagerie?(card_info) ->
        :"Menagerie DH"

      cycle_dh?(card_info) ->
        :"Cycle DH"

      weapon_dh?(card_info) ->
        :"Weapon DH"

      aggro_dh?(card_info) && outcast_dh?(card_info) ->
        :"Aggro Outcast DH"

      aggro_dh?(card_info) && relic_dh?(card_info) ->
        :"Aggro Relic DH"

      aggro_dh?(card_info) ->
        :"Aggro Demon Hunter"

      fel_dh?(card_info) ->
        :"Fel Demon Hunter"

      relic_dh?(card_info) ->
        :"Relic Demon Hunter"

      shopper_dh?(card_info) ->
        :"Shopper DH"

      attack_dh?(card_info) ->
        :"Attack DH"

      outcast_dh?(card_info) ->
        :"Outcast DH"

      true ->
        fallbacks(card_info, "Demon Hunter")
    end
  end

  def attack_dh?(ci) do
    min_count?(ci, 5, [
      "Illidari Inquisitor",
      "Sock Puppet Slitherspear",
      "Burning Heart",
      "Battlefiend",
      "Parched Desperado",
      "Spirit of the Team",
      "Going Down Swinging",
      "Chaos Strike",
      "Lesser Opal Spellstone",
      "Saronite Shambler",
      "Gan'arg Glaivesmith",
      "Gibbering Reject",
      "Rhythmdancer Risa"
    ])
  end

  def shopper_dh?(ci) do
    min_count?(ci, 2, ["Window Shopper", "Umpire's Grasp"])
  end

  def cycle_dh?(ci) do
    "Playhouse Giant" in ci.card_names or
      min_count?(ci, 2, ["Momentum", "Mindbender", "Eredar Deceptor", "Argunite Golem"])
  end

  def weapon_dh?(ci) do
    min_count?(ci, 2, ["Quick Pick", "Umberwing", "Umpire's Grasp"]) and
      min_count?(ci, 1, [
        "Abyssal Bassist",
        "Shadestone Skulker",
        "Instrument Tech",
        "Air Guitarist"
      ])
  end

  def naga_dh?(ci) do
    "Blindeye Sharpshooter" in ci.card_names and type_count(ci, "Naga") >= 4
  end

  def spell_dh?(c),
    do:
      min_count?(c, 3, [
        "Souleater's Scythe",
        "Mark of Scorn",
        "Fel'dorei Warband",
        "Deal with a Devil"
      ])

  def outcast_dh?(c), do: min_keyword_count?(c, 4, "outcast")

  defp deathrattle_dh?(%{card_names: card_names}),
    do:
      "Death Speaker Blackthorn" in card_names ||
        ("Tuskpiercier" in card_names && "Razorboar" in card_names)

  defp aggro_dh?(ci) do
    min_count?(ci, 4, [
      "Irondeep Trogg",
      "Bibliomite",
      "Mankrik",
      "Sightless Magistrate",
      "Battlefiend",
      "Metamorfin",
      "Magnifying Glaive"
    ])
  end

  defp relic_dh?(ci) do
    min_count?(ci, 4, [
      "Relic of Extinction",
      "Relic Vault",
      "Relic of Phantasms",
      "Relic of Dimensions",
      "Artificer Xy'mox"
    ])
  end

  defp fel_dh?(ci) do
    min_spell_school_count?(ci, 5, "fel") and
      min_count?(ci, 1, [
        "Fossil Fanatic",
        "Jace Darkweaver",
        "Felgorger"
      ])
  end

  defp big_dh?(ci = %{card_names: card_names}),
    do:
      "Sigil of Reckoning" in card_names || vanndar?(ci) ||
        min_count?(ci, 2, ["Felscale Evoker", "Illidari Inquisitor", "Brutal Annihilan"])

  defp clean_slate_dh?(ci),
    do:
      min_count?(ci, 4, [
        "Dispose of Evidence",
        "Magnifying Glaive",
        "Kryxis the Voracious",
        "Bibliomite"
      ])

  defp relic?(ci),
    do:
      min_count?(ci, 4, [
        "Relic of Extinction",
        "Relic of Phantasms",
        "Relic Vault",
        "Relic Of Dimensions",
        "Artificer Xy'mox"
      ])

  def prepend_relic(name, ci) do
    if relic?(ci) do
      "Relic " <> to_string(name)
    else
      name
    end
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

      outcast_dh?(card_info) ->
        :"Outcast DH"

      fel_dh?(card_info) ->
        :"Fel DH"

      "King Togwaggle" in card_info.card_names ->
        String.to_atom("Tog #{class_name}")

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      "Jace Darkweaver" in card_info.card_names && min_spell_school_count?(card_info, 5, "Fel") ->
          :"Jace Demon Hunter"

      true ->
        fallbacks(card_info, class_name)
    end
  end
end
