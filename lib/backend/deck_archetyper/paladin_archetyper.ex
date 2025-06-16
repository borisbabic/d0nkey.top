# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.PaladinArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Card

  def standard(card_info) do
    cond do
      imbue?(card_info) ->
        :"Imbue Paladin"

      menagerie?(card_info) ->
        :"Menagerie Paladin"

      aggro_paladin?(card_info) ->
        :"Aggro Paladin"

      drunk?(card_info) ->
        :"Drunk Paladin"

      tree?(card_info) ->
        :"Tree Paladin"

      lynessa_otk?(card_info) ->
        :"Lynessa OTK Paladin"

      terran?(card_info, 4) ->
        :"Terran Paladin"

      libram?(card_info) ->
        :"Libram Paladin"

      murloc?(card_info) ->
        :"Murloc Paladin"

      "Cardboard Golem" in card_info.card_names ->
        :"Aura Paladin"

      "Sunsapper Lynessa" in card_info.card_names ->
        :"Lynessa Paladin"

      "Pipsi Painthoof" in card_info.card_names ->
        :"Pipsi Paladin"

      true ->
        fallbacks(card_info, "Paladin")
    end
  end

  def drunk?(card_info) do
    min_count?(card_info, 2, ["Divine Brew", "Sea Shanty"])
  end

  defp tree?(card_info) do
    min_count?(card_info, 3, ["Ursine Maul", "Ursol", "Shaladrassil"]) and
      1 == Enum.count(card_info.full_cards, &(Card.cost(&1) > 6 and Card.spell?(&1)))
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

  defp aggro_paladin?(card_info) do
    min_count?(card_info, 6, [
      "Vicious Slitherspear",
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
      "Busy-Bot",
      "Hand of A'dal",
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
      "Smoldering Strength",
      "Nerubian Egg",
      "Sea Giant",
      "Maze Guide",
      "Righteous Protector"
    ]) or
      min_count?(card_info, 2, ["Crusader Aura", "Flash Sale"])
  end

  defp pure_paladin?(%{full_cards: full_cards}), do: !Enum.any?(full_cards, &Card.neutral?/1)

  def wild(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander Paladin"

      questline?(card_info) ->
        :"Questline Paladin"

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest Paladin")

      boar?(card_info) ->
        :"Boar Paladin"

      baku?(card_info) ->
        :"Odd Paladin"

      genn?(card_info) ->
        :"Even Paladin"

      "Sunsapper Lynessa" in card_info.card_names and libram?(card_info) ->
        :"Lynessa Libram Paladin"

      libram?(card_info) ->
        :"Libram Paladin"

      pure_paladin?(card_info) ->
        :"Pure Paladin"

      "King Togwaggle" in card_info.card_names ->
        :"Tog Paladin"

      wild_exodia_paladin?(card_info) ->
        :"Exodia Paladin"

      earthen_paladin?(card_info) ->
        :"Gaia Paladin"

      holy_wrath_paladin?(card_info) ->
        :"Holy Wrath Paladin"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun Paladin"

      wild_shanty_paladin?(card_info) ->
        :"Sea Shanty Paladin"

      "Painter's Virtue" in card_info.card_names ->
        :"Handbuff Paladin"

      "Call to Arms" in card_info.card_names ->
        :"CtA Paladin"

      thekal?(card_info) ->
        :"Thekal Paladin"

      true ->
        fallbacks(card_info, "Paladin")
    end
  end

  defp thekal?(card_info) do
    min_count?(card_info, 2, ["High Priest Thekal", "Molten Giant"])
  end

  defp earthen_paladin?(ci),
    do: min_count?(ci, 2, ["Stoneheart King", "Disciple of Amitus"])

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
