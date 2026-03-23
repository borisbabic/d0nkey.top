# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.PriestArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers

  def standard(card_info) do
    cond do
      # quest?(card_info) ->
      #   :"Quest Priest"

      egg_priest?(card_info) ->
        :"Egg Priest"

      control_priest?(card_info) ->
        :"Control Priest"

      imbue?(card_info, 4) ->
        :"Imbue Priest"

      thief?(card_info, 5) ->
        :"Thief Priest"

      "Wilted Shadow" in card_info.card_names ->
        :"Wilted Priest"

      quest?(card_info) ->
        :"Quest Priest"

      "Tyrande" in card_info.card_names ->
        :"Tyrande Priest"

      handbuff_priest?(card_info) ->
        :"Handbuff Priest"

      hitchhiker?(card_info) ->
        :"42 Priest"

      "Alexstraza, Guardian of Life" in card_info.card_names ->
        :"Alex Priest"

      "Ruby Sanctum" in card_info.card_names ->
        :"Sanctum Priest"

      "Medivh the Hallowed" in card_info.card_names ->
        :"Medivh Priest"

      true ->
        fallbacks(card_info, "Priest")
    end
  end

  defp handbuff_priest?(card_info) do
    min_count?(card_info, 4, [
      "Amber Priestess",
      "Divine Star",
      "Nexus-Prince Shaffar",
      "Disciple of the Dove",
      "Hourglass Attendant",
      "Overlord Runthak",
      "Power Word: Barrier",
      "Cleanings Lightspawn",
      "Divine Augur",
      "Eternus",
      "Bumbling Bellhop",
      "Job Shadower",
      "Soldier of the Bronze",
      "Crater Experiment"
    ])
  end

  defp egg_priest?(card_info) do
    min_count?(card_info, 2, ["The Egg of Khelos", "Holy Eggbearer"])
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

  def pain?(ci, additional_cards \\ []) do
    min_count?(ci, 4, [
      "Job Shadower",
      "Acupuncture",
      "Brain Masseuse",
      "Nightshade Tea",
      "Hot Coals",
      "Trogg Exile",
      "Sauna Regular",
      "Trusty Fishing Rod"
      | additional_cards
    ])
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
    min_count?(ci, 3, [
      "Sleepy Resident",
      "Dirty Rat",
      "Shadow Word: Ruin",
      "Holy Nova",
      "For all Time",
      "Medivh's Triumph",
      "Devouring Plague",
      "Eternal Firebolt",
      "The Black Blood"
    ])
  end

  def wild(card_info) do
    cond do
      questline?(card_info) and highlander?(card_info) ->
        :"HL Questline Priest"

      quest?(card_info) and highlander?(card_info) ->
        String.to_atom("HL #{quest_abbreviation(card_info)} Quest Priest")

      "The Harvester of Envy" in card_info.card_names and highlander?(card_info) ->
        :"HL Thief Priest"

      "Darkbishop Benedictus" in card_info.card_names and highlander?(card_info) ->
        :"HL Shadow Priest"

      imbue?(card_info, 4) and highlander?(card_info) ->
        :"HL Imbue Priest"

      highlander?(card_info) ->
        :"Highlander Priest"

      questline?(card_info) ->
        :"Questline Priest"

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest Priest")

      boar?(card_info) ->
        :"Boar Priest"

      baku?(card_info) ->
        :"Odd Priest"

      genn?(card_info) ->
        :"Even Priest"

      "King Togwaggle" in card_info.card_names ->
        :"Tog Priest"

      "Darkbishop Benedictus" in card_info.card_names ->
        :"Shadow Priest"

      "Timewinder Zarimi" in card_info.card_names ->
        :"Zarimi Priest"

      wild_switcheroo_priest?(card_info) ->
        :"Switcheroo Priest"

      overheal_priest?(card_info) ->
        :"Overheal Priest"

      wild_rez_priest?(card_info) ->
        :"Rez Priest"

      "Heartbreaker Hedanis" in card_info.card_names ->
        :"Hedanis Priest"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun Priest"

      "Astral Automaton" in card_info.card_names ->
        :"Automaton Priest"

      thief?(card_info, 5) ->
        :"Thief Priest"

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
        fallbacks(card_info, "Priest")
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
      "Intertwined Fate",
      "Keymaster Alabaster",
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
end
