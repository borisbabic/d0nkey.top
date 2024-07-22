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

      mech_paladin?(card_info) ->
        :"Mech Paladin"

      drunk?(card_info) ->
        :"Drunk Paladin"

      lynessa_otk?(card_info) ->
        "Lynessa Paladin"

      earthen_paladin?(card_info) ->
        :"Gaia Paladin"

      holy_paladin?(card_info) ->
        :"Holy Paladin"

      kazakusan?(card_info) ->
        :"Kazakusan Paladin"

      big_paladin?(card_info) ->
        :"Big Paladin"

      order_luladin?(card_info) ->
        :"Order LULadin"

      vanndar?(card_info) ->
        :"Vanndar Paladin"

      murloc?(card_info) ->
        :"Murloc Paladin"

      boar?(card_info) ->
        :"Boar Paladin"

      true ->
        fallbacks(card_info, "Paladin")
    end
  end

  defp drunk?(card_info) do
    min_count?(card_info, 2, ["Divine Brew", "Sea Shanty"])
  end

  defp lynessa_otk?(card_info) do
    match?({_, ["Sunsapper Lynessa"]}, lowest_highest_cost_cards(card_info)) and
      "Grillmaster" in card_info.card_names and
      min_count?(card_info, 1, ["Griftah, Trusted Vendor", "Holy Glowsticks", "Mixologist"])
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

  defp pure_paladin?(%{full_cards: full_cards}), do: !Enum.any?(full_cards, &not_paladin?/1)

  defp order_luladin?(ci = %{card_names: card_names}),
    do:
      "Order in the Court" in card_names &&
        min_count?(ci, 2, ["The Jailer", "Reno Jackson", "The Countess"])

  defp not_paladin?(card) do
    case Card.class(card, "PALADIN") do
      {:ok, "PALADIN"} -> false
      _ -> true
    end
  end

  defp mech_paladin?(%{card_names: card_names}), do: "Radar Detector" in card_names

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
        "Mecha'thun #{class_name}"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp holy_wrath_paladin?(card_info) do
    min_count?(card_info, 2, ["Holy Wrath", "Shirvallah, the Tiger"]) and
      min_count?(card_info, 1, ["Lorekeeper Polkelt", "Order in the Court"])
  end

  defp wild_exodia_paladin?(card_info) do
    min_count?(card_info, 3, [
      "Uther of the Ebon Blade",
      "Sing-Along Buddy",
      "Garrison Commander"
    ])
  end
end
