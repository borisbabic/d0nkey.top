defmodule Backend.DeckArchetyper.PriestArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander Priest"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Priest"

      boar?(card_info) ->
        :"Boar Priest"

      menagerie?(card_info) ->
        :"Menagerie Priest"

      naga_priest?(card_info) ->
        :"Naga Priest"

      boon_priest?(card_info) ->
        :"Boon Priest"

      shellfish_priest?(card_info) ->
        :"Shellfish Priest"

      vanndar?(card_info) && shadow_priest?(card_info) ->
        :"Vanndar Shadow Priest"

      vanndar?(card_info) ->
        :"Vanndar Priest"

      control_priest?(card_info) ->
        :"Control Priest"

      thief_priest?(card_info) ->
        :"Thief Priest"

      automaton_priest?(card_info) ->
        :"Automaton Priest"

      shadow_priest?(card_info) ->
        :"Shaggro Priest"

      rager_priest?(card_info) ->
        :"Rager Priest"

      overheal_priest?(card_info) ->
        :"Overheal Priest"

      svalna_priest?(card_info) ->
        :"Svalna Priest"

      shadow_priest?(card_info) ->
        :"Shadow Priest"

      "Timewinder Zarimi" in card_info.card_names ->
        :"Zarimi Priest"

      "Photographer Fizzle" in card_info.card_names ->
        :"Fizzle Priest"

      "Pip the Potent" in card_info.card_names ->
        :"Pip Priest"

      murloc?(card_info) ->
        :"Murloc Priest"

      true ->
        fallbacks(card_info, "Priest")
    end
  end

  defp automaton_priest?(ci),
    do:
      "Astral Automaton" in ci.card_names and
        min_count?(ci, 3, [
          "Celestial Projectionist",
          "Creation Protocol",
          "Ra-den",
          "Power Chord: Synchronize",
          "Zola the Gordon",
          "Creepy Painting",
          "Ravenous Kraken",
          "Cover Artist"
        ])

  defp overheal_priest?(ci) do
    min_count?(ci, 5, [
      "Crimson Clergy",
      "Funnel Cake",
      "Dreamboat",
      "Holy Champion",
      "Flash Heal",
      "Idol's Adoration",
      "Grace of the Highfather",
      "Hidden Gem",
      "Mana Geode",
      "Injured Hauler",
      "Heartthrob",
      "Ambient Lightspawn",
      "Heartbreaker Hedanis"
    ])
  end

  defp svalna_priest?(card_info),
    do: min_count?(card_info, 3, ["Radiant Elemental", "Animate Dead", "Sister Svalna"])

  defp rager_priest?(card_info),
    do:
      "Scourge Rager" in card_info.card_names and
        min_count?(card_info, 2, ["Animate Dead", "Grave Digging", "High Cultist Basaleph"])

  defp shellfish_priest?(%{card_names: card_names}),
    do: "Selfish Shellfish" in card_names && "Xyrella, the Devout" in card_names

  defp boon_priest?(ci) do
    min_count?(ci, 5, [
      "Radiant Elemental",
      "Switcheroo",
      "Boon of the Ascended",
      "Bless",
      "Power Word: Fortitude",
      "Focused Will",
      "Illuminate"
    ]) && type_count(ci, "Naga") < 5
  end

  defp naga_priest?(ci = %{card_names: card_names}) do
    "Serpent Wig" in card_names && type_count(ci, "Naga") >= 5
  end

  defp shadow_priest?(%{card_names: card_names}), do: "Darkbishop Benedictus" in card_names

  defp control_priest?(ci) do
    min_count?(ci, 2, ["Harmonic Pop", "Clean the Scene", "Whirlpool"])
  end

  defp thief_priest?(ci),
    do:
      min_count?(
        ci,
        5,
        [
          "Psychic Conjurer",
          "Mysterious Visitor",
          "Soothsayer's Caravan",
          "Copycat",
          "Identity Theft",
          "Incriminating Psychic",
          "Plagiarizarrr",
          "Mind Eater",
          "Theft Accusation",
          "Murloc Holmes",
          "The Harvester of Envy"
        ]
      )

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

      "Darkbishop Benedictus" in card_info.card_names ->
        :"Shadow Priest"

      wild_switcheroo_priest?(card_info) ->
        :"Switcheroo Priest"

      wild_combo_priest?(card_info) ->
        :"Combo Priest"

      overheal_priest?(card_info) ->
        :"Overheal Priest"

      wild_rez_priest?(card_info) ->
        :"Rez Priest"

      "Heartbreaker Hedanis" in card_info.card_names ->
        :"Hedanis Priest"

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      "Astral Automaton" in card_info.card_names ->
        "Automaton Priest"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp wild_rez_priest?(card_info) do
    min_count?(card_info, 3, [
      "Eternal Servitude",
      "Lesser Diamond Spellstone",
      "Mass Resurrection"
    ])
  end

  defp wild_combo_priest?(card_info) do
    min_count?(card_info, 3, [
      "Inner Fire",
      "Divine Spirit",
      "Bless",
      "Radiant Elemental",
      "Power Word: Fortitude",
      "Grave Horror"
    ])
  end

  defp wild_switcheroo_priest?(card_info) do
    min_count?(card_info, 3, [
      "Switcheroo",
      "The Darkness",
      "Stonetusk Boar"
    ]) and
      min_count?(card_info, 1, [
      "Topsy Turvy",
      "Inner Fire",
      "Bless"
    ])
  end
end
