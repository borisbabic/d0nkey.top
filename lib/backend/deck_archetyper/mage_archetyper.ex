# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.MageArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    rommath? = "Grand Magister Rommath" in card_info.card_names
    lightshow? = "Lightshow" in card_info.card_names

    cond do
      highlander?(card_info) ->
        :"Highlander Mage"

      arcane_mage?(card_info) && (quest?(card_info) || questline?(card_info)) ->
        :"Arcane Quest Mage"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Mage"

      vanndar?(card_info) ->
        :"Vanndar Mage"

      menagerie?(card_info) ->
        :"Menagerie Mage"

      rommath? ->
        :"Rommath Mage"

      naga_mage?(card_info) && rainbow_mage?(card_info) ->
        :"Rainbow Naga Mage"

      rainbow_mage?(card_info) ->
        :"Rainbow Mage"

      arcane_mage?(card_info) ->
        :"Arcane Mage"

      naga_mage?(card_info) && arcane_mage?(card_info) ->
        :"Arcane Naga Mage"

      secret_mage?(card_info) ->
        :"Secret Mage"

      naga_mage?(card_info) && secret_mage?(card_info) ->
        :"Secret Naga Mage"

      burn_mage?(card_info) && secret_mage?(card_info) ->
        :"Burn Secret Mage"

      naga_mage?(card_info) && burn_mage?(card_info) && secret_mage?(card_info) ->
        :"Secret Burn Naga Mage"

      naga_mage?(card_info) && casino_mage?(card_info) ->
        :"Casino Naga Mage"

      casino_mage?(card_info) ->
        :"Casino Mage"

      frost_mage?(card_info) ->
        :"Frost Mage"

      burn_mage?(card_info) && naga_mage?(card_info) ->
        :"Burn Naga Mage"

      naga_mage?(card_info) && skeleton_mage?(card_info) ->
        :"Spooky Naga Mage"

      naga_mage?(card_info) ->
        :"Naga Mage"

      mech_mage?(card_info) ->
        :"Mech Mage"

      excavate_mage?(card_info) ->
        :"Excavate Mage"

      burn_mage?(card_info) && skeleton_mage?(card_info) ->
        :"Burn Spooky Mage"

      burn_mage?(card_info) ->
        :"Burn Mage"

      skeleton_mage?(card_info) ->
        :"Spooky Mage"

      ping_mage?(card_info) ->
        :"Ping Mage"

      big_spell_mage?(card_info) ->
        :"Big Spell Mage"

      burn_spell_mage?(card_info) ->
        :"Burn Spell Mage"

      spell_mage?(card_info) ->
        :"Spell Mage"

      murloc?(card_info) ->
        :"Murloc Mage"

      boar?(card_info) ->
        :"Boar Mage"

      lightshow? ->
        :"Lightshow Mage"

      "The Galactic Projection Orb" in card_info.card_names ->
        :"Orb Mage"

      true ->
        fallbacks(card_info, "Mage")
    end
  end

  defp excavate_mage?(ci) do
    min_count?(ci, 3, [
      "Cryopreservation",
      "Reliquary Researcher",
      "Blastmage Miner" | neutral_excavate()
    ])
  end

  def rainbow_mage?(ci),
    do:
      min_count?(ci, 3, [
        "Discovery of Magic",
        "Inquisitive Creation",
        "Sif",
        "Elemental Inspiration"
      ])

  def burn_mage?(ci), do: min_count?(ci, 2, ["Vexallus", "Aegwynn, the Guardian"])

  def arcane_mage?(card_info),
    do:
      min_count?(card_info, 3, [
        "Vexalllus",
        "Arcsplitter",
        "Arcane Wyrm",
        "Magister's Apprentice"
      ]) && min_spell_school_count?(card_info, 4, "arcane")

  def casino_mage?(card_info),
    do:
      min_count?(card_info, 3, [
        "Energy Shaper",
        "Grand Magister Rommath",
        "The Sunwell",
        "Vast Wisdowm",
        "Prismatic Elemental"
      ])

  defp frost_mage?(ci) do
    case spell_school_map(ci) |> Map.to_list() do
      # only frost
      [{"frost", _}] -> true
      _ -> false
    end
  end

  defp skeleton_mage?(ci),
    do:
      min_count?(ci, 4, [
        "Volatile Skeleton",
        "Nightcloak Sanctum",
        "Cold Case",
        "Deathborne",
        "Kel'Thuzad, the Inevitable"
      ])

  defp secret_mage?(ci),
    do:
      min_count?(ci, 2, [
        "Anonymous Informant",
        "Chatty Bartender",
        "Orion, Mansion Manager",
        "Sunreaver Spy",
        "Crossroads Gossiper",
        "Scuttlebutt Ghoul"
      ]) ||
        min_secret_count?(ci, 3)

  defp naga_mage?(%{card_names: card_names}), do: "Spitelash Siren" in card_names
  defp mech_mage?(%{card_names: card_names}), do: "Mecha-Shark" in card_names

  defp big_spell_mage?(ci = %{card_names: card_names}),
    do:
      !mech_mage?(ci) && "Grey Sage Parrot" in card_names &&
        min_count?(ci, 1, ["Rune of the Archmage", "Drakefire Amulet"])

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

      ping_mage?(card_info) ->
        :"Ping Mage"

      "Sif" in card_info.card_names ->
        :"Sif Mage"

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      wild_orb_mage?(card_info) ->
        :"Orb Mage"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp spell_mage?(card_info) do
    min_count?(card_info, 2, [
      "Malfunction",
      "Spot the Difference",
      # what hdt uses for unknown cards
      "NOOOOOOOOOOOO",
      "Yogg in the Box",
      "Manufacturing Error"
    ])
  end

  defp burn_spell_mage?(card_info) do
    spell_mage?(card_info) and
      min_count?(card_info, 4, [
        "Flame Geyser",
        "Frostbolt",
        "Lightshow",
        "Molten Rune",
        "Fireball"
      ])
  end

  defp ping_mage?(card_info) do
    min_count?(card_info, 4, [
      "Wildfire",
      "Reckless Apprentice",
      "Sing-Along Buddy",
      "Magister Dawngrasp",
      "Mordresh Fire Eye"
    ])
  end

  defp wild_orb_mage?(card_info) do
    min_count?(card_info, 3, [
      "The Galactic Projection Orb",
      "Potion of Illusion",
      "Grey Sage Parrot"
    ])
  end
end
