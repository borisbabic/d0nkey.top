defmodule Backend.DeckArchetyper.HunterArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander Hunter"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Hunter"

      vanndar?(card_info) && big_beast_hunter?(card_info) ->
        :"Vanndar Beast Hunter"

      vanndar?(card_info) ->
        :"Vanndar Hunter"

      arcane_hunter?(card_info) && (big_beast_hunter?(card_info) or beast_hunter?(card_info)) ->
        :"Arcane Beast Hunter"

      arcane_hunter?(card_info) ->
        :"Arcane Hunter"

      secret_hunter?(card_info) ->
        :"Secret Hunter"

      rat_hunter?(card_info) ->
        :"Rattata Hunter"

      big_beast_hunter?(card_info) ->
        :"Big Beast Hunter"

      cleave_hunter?(card_info) ->
        :"Cleave Hunter"

      zoo_hunter?(card_info) ->
        :"Zoo Hunter"

      beast_hunter?(card_info) ->
        :"Beast Hunter"

      murloc?(card_info) ->
        :"Murloc Hunter"

      boar?(card_info) ->
        :"Boar Hunter"

      menagerie?(card_info) ->
        :"Menagerie Hunter"

      aggro_hunter?(card_info) ->
        :"Aggro Hunter"

      shockspitter?(card_info) ->
        :"Shockspitter Hunter"

      egg_hunter?(card_info) ->
        :"Egg Hunter"

      mystery_egg_hunter?(card_info) ->
        :"Mystery Egg Hunter"

      wildseed_hunter?(card_info) ->
        :"Wildseed Hunter"

      true ->
        fallbacks(card_info, "Hunter")
    end
  end

  defp beast_hunter?(ci) do
    min_count?(ci, 4, [
      "Fetch!",
      "Bunny Stomper",
      "Jungle Gym",
      "Painted Canvasaur",
      "Master's Call",
      "Ball of Spiders",
      "Kill Command"
    ])
  end

  defp zoo_hunter?(ci) do
    min_count?(ci, 4, [
      "Observer of Myths",
      "Hawkstrider Rancher",
      "Saddle Up!",
      "Shadehound",
      "R.C. Rampage",
      "Remote Control",
      "Jungle Gym"
    ])
  end

  defp egg_hunter?(ci),
    do: min_count?(ci, 3, ["Foul Egg", "Nerubian Egg", "Ravenous Kraken", "Yelling Yodeler"])

  defp secret_hunter?(ci),
    do:
      min_count?(ci, 3, [
        "Lesser Emerald Spellstone",
        "Costumed Singer",
        "Anonymous Informant",
        "Titanforged Traps",
        "Product 9",
        "Starstrung Bow"
      ])

  def shockspitter?(ci) do
    "Shockspitter" in ci.card_names
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

      lion_hunter?(card_info) ->
        :"Lion Hunter"

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp lion_hunter?(card_info) do
    min_count?(card_info, 2, ["Mok'Nathal Lion", "Mystery Egg"])
  end

  defp mystery_egg_hunter?(card_info) do
    min_count?(card_info, 1, ["Mystery Egg"])
  end

  defp cleave_hunter?(card_info) do
    min_count?(card_info, 3, ["Hollow Hound", "Stonebound Gargon", "Always a Bigger Jormungar"]) &&
      min_count?(card_info, 2, [
        "Absorbent Parasite",
        "Beastial Madness",
        "Messenger Buzzard",
        "Hope of Quel'Thalas"
      ])
  end

  defp arcane_hunter?(card_info),
    do:
      min_count?(card_info, 2, ["Halduron Brightwing", "Silvermoon Farstrider", "Arcane Quiver"]) &&
        min_spell_school_count?(card_info, 4, "arcane")

  defp rat_hunter?(ci),
    do:
      min_count?(ci, 4, [
        "Leartherworking Kit",
        "Rodent Nest",
        "Sin'dorei Scentfinder",
        "Defias Blastfisher",
        "Shadehound",
        "Rats of Extraordinary Size"
      ])

  defp big_beast_hunter?(ci),
    do:
      min_count?(ci, 2, ["King Krush", "Stranglehorn Heart", "Faithful Companions", "Banjosaur"])

  defp aggro_hunter?(ci),
    do:
      min_count?(ci, 2, [
        "Doggie Biscuit",
        "Bunch of Bananas",
        "Vicious Slitherspear",
        "Ancient Krakenbane",
        "Arrow Smith",
        "Raj Naz'jan"
      ])

  def wildseed_hunter?(ci),
    do: min_count?(ci, 3, ["Spirit Poacher", "Stag Charge", "Wild Spirits", "Ara'lon"])
end
