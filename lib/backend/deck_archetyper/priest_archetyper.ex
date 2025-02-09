# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.PriestArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Card

  def standard(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander Priest"

      menagerie?(card_info) ->
        :"Menagerie Priest"

      automaton_priest?(card_info) ->
        :"Automaton Priest"

      anchorite(card_info) ->
        :"Anchorite Priest"

      overheal_priest?(card_info) ->
        :"Overheal Priest"

      zarimi?(card_info) and pain?(card_info) ->
        :"Pain Zarimi Priest"

      zarimi?(card_info) ->
        :"Zarimi Priest"

      aggro_zealot?(card_info) ->
        :"Aggro Zealot Priest"

      pain?(card_info) ->
        :"Pain Priest"

      protoss?(card_info, 4) ->
        :"Protoss Priest"

      topdeck?(card_info) ->
        :"Topdeck Priest"

      thief?(card_info, 5) ->
        :"Thief Priest"

      zealot_otk?(card_info) ->
        :"Zealot OTK Priest"

      control_priest?(card_info) ->
        :"Control Priest"

      hitchhiker?(card_info) ->
        :"42 Priest"

      "Photographer Fizzle" in card_info.card_names ->
        :"Fizzle Priest"

      murloc?(card_info) ->
        :"Murloc Priest"

      armor?(card_info) ->
        :"Armor Priest"

      true ->
        fallbacks(card_info, "Priest")
    end
  end

  @spec zealot_otk?(ArchetyperHelpers.card_info()) :: boolean()
  defp zealot_otk?(card_info) do
    min_count?(card_info, 4, [
      "Hallucination",
      "Chrono Boost",
      "Chillin' Vol'jin",
      "The Ceaseless Expanse"
    ])
  end

  @standard_resummon ["Rest in Peace", "Cubicle", "Lesser Diamond Spellstone"]
  @wild_resummon ["Grave Rune", "Twilight's Call", "Amulet of Undying", "Embalming Ritual"]
  @all_resummon @standard_resummon ++ @wild_resummon
  defp armor?(ci) do
    "Arkonite Defense Crystal" in ci.card_names and
      min_count?(ci, 2, @all_resummon)
  end

  defp hitchhiker?(ci) do
    "Mystified To'cha" in ci.card_names
  end

  defp zarimi?(ci) do
    "Timewinder Zarimi" in ci.card_names and type_count(ci, "Dragon") > 3
  end

  defp topdeck?(ci) do
    min_count?(ci, 3, [
      "Overplanner",
      "Narain Soothfancy",
      "Twilight Medium",
      "Envoy of Prosperity"
    ])
  end

  def pain?(ci) do
    min_count?(ci, 4, [
      "Job Shadower",
      "Acupuncture",
      "Brain Masseuse",
      "Nightshade Tea",
      "Hot Coals",
      "Trogg Exile",
      "Sauna Regular",
      "Trusty Fishing Rod"
    ])
  end

  defp aggro_zealot?(card_info) do
    min_count?(card_info, 2, [
      "Brain Masseuse",
      "Overzealous Healer",
      "Catch of the Day",
      "Miracle Salesman"
    ]) and chrono?(card_info)
  end

  defp chrono?(card_info) do
    min_count?(card_info, 2, ["Hallucination", "Chrono Boost"])
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
          "Pet Parrot",
          "Ravenous Kraken",
          "Cover Artist"
        ])

  defp anchorite(ci) do
    min_count?(ci, 2, ["Crazed Alchemist", "Anchorite"])
  end

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

  defp control_priest?(ci) do
    min_count?(ci, 2, [
      "Sleepy Resident",
      "Dirty Rat",
      "Ignis, the Eternal Flame",
      "Serenity",
      "Harmonic Pop",
      "Repackage",
      "Lightbomb",
      "Shadow Word: Ruin",
      "Holy Nova",
      "Shadow Word: Steal",
      "Fight Over Me"
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

      "King Togwaggle" in card_info.card_names ->
        String.to_atom("Tog #{class_name}")

      min_count?(card_info, 2, ["Darkbishop Benedictus", "Prince Renathal"]) ->
        :"XL Shadow Priest"

      "Darkbishop Benedictus" in card_info.card_names ->
        :"Shadow Priest"

      "Timewinder Zarimi" in card_info.card_names ->
        :"Zarimi Priest"

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
        :"Mecha'thun #{class_name}"

      "Astral Automaton" in card_info.card_names ->
        :"Automaton Priest"

      thief?(card_info, 5) ->
        :"Thief Priest"

      "Radiant Elemental" in card_info.card_names ->
        :"Radiant Priest"

      techw?(card_info) ->
        :"TechW Priest"

      "Nazmani Bloodweaver" in card_info.card_names ->
        :"Nazmani Priest"

      armor?(card_info) ->
        :"Armor Priest"

      "Divine Spirit" in card_info.card_names ->
        :"Divine Spirit Priest"

      type_count(card_info, "Pirate") > 4 ->
        :"Pirate Priest"

      "Crabrider" in card_info.card_names ->
        :"Crabrider Priest"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp thief?(card_info, min_count) do
    min_count?(card_info, min_count, [
      "Crystalline Oracle",
      "Psychic Conjurer",
      "Psionic Probe",
      "Theft Accusation",
      "Chameleos",
      "Mindeater",
      "Soothsayer's Caravan",
      "Envoy of Lazul",
      "Madame Lazul",
      "Curious Glimmerroot",
      "Copycat",
      "Mindrender Illucia",
      "Shifting Shade",
      "Incriminating PSychic",
      "Drakonid Operative",
      "Tram Heist",
      "Devour Mind",
      "Archbishop Benedictus",
      "Drakkari Trickster",
      "Mischief Maker",
      "Fate Splitter",
      "Murloc Holmes",
      "Southsea Scoundrel",
      "Tony, King of Piracy",
      "King Togwaggle",
      "The Harvester of Envy",
      "Mystery Visitor",
      "Identity Theft",
      "Tram Heist",
      "Mind Vision",
      "Cloning Device"
    ])
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
      "Divine Spirit",
      "Radiant Elemental",
      "Power Word: Shield",
      "Potion of Madness"
    ]) and
      min_count?(card_info, 1, [
        "Topsy Turvy",
        "Inner Fire",
        "Bless"
      ])
  end

  defp wild_switcheroo_priest?(card_info) do
    min_count?(card_info, 2, [
      "Switcheroo",
      "Stonetusk Boar"
    ]) and
      min_count?(card_info, 1, [
        "Topsy Turvy",
        "Inner Fire",
        "Bless"
      ])
  end

  @techw_cards ["Spellward Jeweler", "Kobold Monk"]
  defp techw?(card_info) do
    names = for card <- card_info.full_cards, Card.minion?(card), uniq: true, do: Card.name(card)
    !Enum.empty?(names) and !Enum.any?(names, &(!(&1 in @techw_cards)))
  end
end
