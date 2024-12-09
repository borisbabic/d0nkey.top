# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.PaladinArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Card

  def standard(card_info) do
    cond do
      highlander?(card_info) && pure_paladin?(card_info) ->
        :"Highlander Pure Paladin"

      pure_paladin?(card_info) && dude_paladin?(card_info) ->
        :Chadadin

      earthen_paladin?(card_info) && pure_paladin?(card_info) ->
        :"Gaia Pure Paladin"

      pure_paladin?(card_info) ->
        :"Pure Paladin"

      highlander?(card_info) ->
        :"Highlander Paladin"

      excavate_paladin?(card_info) ->
        :"Excavate Paladin"

      handbuff_paladin?(card_info) ->
        :"Handbuff Paladin"

      aggro_paladin?(card_info) ->
        :"Aggro Paladin"

      menagerie?(card_info) ->
        :"Menagerie Paladin"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Paladin"

      dude_paladin?(card_info) ->
        :"Dude Paladin"

      drunk?(card_info) ->
        :"Drunk Paladin"

      lynessa_otk?(card_info) ->
        "Lynessa Paladin"

      earthen_paladin?(card_info) ->
        :"Gaia Paladin"

      libram?(card_info) ->
        :"Libram Paladin"

      holy_paladin?(card_info) ->
        :"Holy Paladin"

      big_paladin?(card_info) ->
        :"Big Paladin"

      murloc?(card_info) ->
        :"Murloc Paladin"

      "Cardboard Golem" in card_info.card_names ->
        :"Aura Paladin"

      "Pipsi Painthoof" in card_info.card_names ->
        :"Pipsi Paladin"

      "Sunsapper Lynessa" in card_info.card_names ->
        :"Lynessa Paladin"

      true ->
        fallbacks(card_info, "Paladin")
    end
  end

  def drunk?(card_info) do
    min_count?(card_info, 2, ["Divine Brew", "Sea Shanty"])
  end

  defp lynessa_otk?(card_info) do
    match?({_, ["Sunsapper Lynessa"]}, lowest_highest_cost_cards(card_info)) and
      "Grillmaster" in card_info.card_names and
      min_count?(card_info, 1, ["Griftah, Trusted Vendor", "Holy Glowsticks", "Mixologist"])
  end

  defp libram?(card_info, min_count \\ 2) do
    min_count?(card_info, min_count, [
      "Libram of Faith",
      "Libram of Clarity",
      "Libram of Divinity",
      "Libram of Wisdom",
      "Libram of Justice",
      "Libram of Hope",
      "Libram of Judgement"
    ])
  end

  defp excavate_paladin?(card_info) do
    min_count?(
      card_info,
      3,
      ["Shroomscavate", "Sir Finley, the Intrepid", "Fossilized Kaleidosaur" | neutral_excavate()]
    )
  end

  defp aggro_paladin?(card_info) do
    min_count?(card_info, 6, [
      "Vicous Slitherspear",
      "Worgen Inflitrator",
      "Flash Sale",
      "For Quel'Thalas!",
      "Seal of Blood",
      "Blessing of Kings",
      "Sunwing Squawker",
      "Foul Egg",
      "Sanguine Soldier",
      "Blood Matriarch Liadrin",
      "Gold Panner",
      "Crusader Aura",
      "Sinstone Totem",
      "Crooked Cook",
      "Sea Giant",
      "Leeroy Jenkins",
      "Boogie Down",
      "Mining Casualties",
      "Buffet Biggun",
      "Muster for Battle",
      "Miracle Salesman",
      "Flash Sale",
      "Disco Maul",
      "Nerubian Egg",
      "Sea Giant",
      "Righteous Protector"
    ])
  end

  defp big_paladin?(ci),
    do:
      min_count?(ci, 1, ["Front Lines", "Kangor, Dancing King", "Lead Dancer"]) &&
        min_count?(ci, 2, [
          "Pipsi Painthoof",
          "Ragnaros the Firelord",
          "Annoy-o-Troupe",
          "Tirion Fordring",
          "Stoneborn General",
          "Neptulon the Tidehunter",
          "Flesh Behemoth",
          "Thaddius, Monstrosity"
        ])

  defp holy_paladin?(ci) do
    min_count?(ci, 3, [
      "Hi Ho Silverwing",
      "Flickering Lightbot",
      "Holy Cowboy",
      "Starlight Groove",
      "Holy Glowsticks"
    ])
  end

  defp handbuff_paladin?(ci) do
    min_count?(ci, 2, ["Painter's Virtue", "Instrument Tech"]) or
      min_count?(ci, 3, [
        "Grimestreet Outfitter",
        "Muscle-o Tron",
        "Outfit Tailor",
        "Painter's Virtue",
        "Overlord Runthak"
      ])
  end

  defp earthen_paladin?(ci),
    do: min_count?(ci, 2, ["Stoneheart King", "Disciple of Amitus"])

  defp dude_paladin?(ci),
    do:
      min_count?(ci, 3, [
        "Vacation Planner",
        "Jury Duty",
        "Promotion",
        "Soldier's Caravan",
        "Stewart the Steward",
        "Muster for Battle",
        "Lothraxion the Redeemed",
        "Jukebox Totem",
        "Warhorse Trainer",
        "Stand Against Darkness"
      ])

  defp pure_paladin?(%{full_cards: full_cards}), do: !Enum.any?(full_cards, &Card.neutral?/1)

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

      libram?(card_info) ->
        :"Libram Paladin"

      pure_paladin?(card_info) ->
        :"Pure Paladin"

      "King Togwaggle" in card_info.card_names ->
        String.to_atom("Tog #{class_name}")

      wild_exodia_paladin?(card_info) ->
        :"Exodia Paladin"

      earthen_paladin?(card_info) ->
        :"Gaia Paladin"

      holy_wrath_paladin?(card_info) ->
        :"Holy Wrath Paladin"

      "Mecha'thun" in card_info.card_names ->
        String.to_atom("Mecha'thun #{class_name}")

      wild_shanty_paladin?(card_info) ->
        :"Sea Shanty Paladin"

      "Painter's Virtue" in card_info.card_names ->
        :"Handbuff Paladin"

      "Call to Arms" in card_info.card_names ->
        :"CtA Paladin"

      thekal?(card_info) ->
        :"Thekal Paladin"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp thekal?(card_info) do
    min_count?(card_info, 2, ["High Priest Thekal", "Molten Giant"])
  end

  defp holy_wrath_paladin?(card_info) do
    "Holy Wrath" in card_info.card_names and
      min_count?(card_info, 1, ["Shirvallah, the Tiger", "The Ceaseless Expanse"]) and
      min_count?(card_info, 1, ["Lorekeeper Polkelt", "Order in the Court"])
  end

  defp wild_exodia_paladin?(card_info) do
    min_count?(card_info, 3, [
      "Uther of the Ebon Blade",
      "Sing-Along Buddy",
      "Garrison Commander"
    ])
  end

  defp wild_shanty_paladin?(card_info) do
    min_count?(card_info, 2, [
      "Sea Shanty",
      "Mr. Smite"
    ])
  end
end
