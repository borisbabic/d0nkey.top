defmodule Backend.DeckArchetyper.Twist.WondersArchetyper do
  @moduledoc "Archetyper for wonders twist mode"
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.DeckArchetyper
  alias Backend.Hearthstone.Deck
  @spec archetype(DeckArchetyper.card_info()) :: atom() | nil

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def archetype(card_info) do
    class_name = Deck.class_name(card_info.deck)

    cond do
      mill_rogue?(card_info) ->
        :"Mill Rogue"
      aggro_shaman?(card_info) ->
        :"Aggro Shaman"

      jade?(card_info) and cthun?(card_info) ->
        String.to_atom("Jade C'Thun #{class_name}")

      jade?(card_info) and nzoth?(card_info) ->
        String.to_atom("Jade N'Zoth #{class_name}")

      nzoth?(card_info) ->
        String.to_atom("N'Zoth #{class_name}")

      cthun?(card_info) ->
        String.to_atom("C'Thun #{class_name}")

      jade?(card_info) ->
        String.to_atom("Jade #{class_name}")

      "Mysterious Challenger" in card_info.card_names ->
        :"Secret Paladin"

      dude?(card_info) ->
        :"Dude Paladin"

      "Grim Patron" in card_info.card_names ->
        String.to_atom("Patron #{class_name}")

      freeze_mage?(card_info) ->
        :"Freeze Mage"

      min_keyword_count?(card_info, 9, "overload") ->
        String.to_atom("Overload #{class_name}")

      type_count(card_info, "Dragon") > 4 ->
        String.to_atom("Dragon #{class_name}")

      type_count(card_info, "Pirate") > 4 ->
        String.to_atom("Pirate #{class_name}")

      type_count(card_info, "Beast") > 4 ->
        String.to_atom("Beast #{class_name}")

      true ->
        nil
    end
  end

  defp aggro_shaman?(card_info) do
    min_count?(card_info, 3, ["Patches the Pirate", "Tunnel Trogg", "Jade Golemn", "Flamewreathed Faceless"])
  end
  defp mill_rogue?(card_info) do
    min_count?(card_info, 2, ["Coldlight Oracle", "Gang Up"])
  end

  defp freeze_mage?(card_info) do
    min_count?(card_info, 2, ["Frost Nova", "Ice Block", "Blizzard"])
  end

  defp nzoth?(card_info) do
    "N'Zoth, the Corruptor" in card_info.card_names
  end

  defp jade?(card_info) do
    min_count?(card_info, 1, ["Jade Spirit", "Aya Blackpaw"])
  end

  defp cthun?(card_info) do
    "C'Thun" in card_info.card_names
  end

  defp dude?(card_info) do
    min_count?(card_info, 3, [
      "Warhorse Trainer",
      "Stand Against Darkness",
      "Muster for Battle",
      "Steward of Darkshire",
      "Quartermaster"
    ])
  end
end
