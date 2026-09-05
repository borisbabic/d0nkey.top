defmodule Backend.PlayedCardsArchetyperTest do
  use Backend.DataCase, async: true

  alias Backend.PlayedCardsArchetyper
  alias Backend.PlayedCardsArchetyper.ArchetyperHelper
  alias Backend.PlayedCardsArchetyper.PriestArchetyper

  describe "ArchetyperHelper.any?/2" do
    test "string target only checks played cards" do
      played_info = %{card_names: ["Azalina Soulsever"], start_of_game_card_names: []}
      sog_info = %{card_names: [], start_of_game_card_names: ["Azalina Soulsever"]}

      assert ArchetyperHelper.any?(played_info, ["Azalina Soulsever"])
      refute ArchetyperHelper.any?(sog_info, ["Azalina Soulsever"])
    end

    test "explicit {:played, cards} only checks played cards" do
      played_info = %{card_names: ["Azalina Soulsever"], start_of_game_card_names: []}
      sog_info = %{card_names: [], start_of_game_card_names: ["Azalina Soulsever"]}

      assert ArchetyperHelper.any?(played_info, [{:played, ["Azalina Soulsever"]}])
      assert ArchetyperHelper.any?(played_info, {:played, "Azalina Soulsever"})
      refute ArchetyperHelper.any?(sog_info, [{:played, ["Azalina Soulsever"]}])
    end

    test "explicit {:start_of_game, cards} only checks start of game cards" do
      played_info = %{card_names: ["Azalina Soulsever"], start_of_game_card_names: []}
      sog_info = %{card_names: [], start_of_game_card_names: ["Azalina Soulsever"]}

      assert ArchetyperHelper.any?(sog_info, [{:start_of_game, ["Azalina Soulsever"]}])
      assert ArchetyperHelper.any?(sog_info, {:start_of_game, "Azalina Soulsever"})
      refute ArchetyperHelper.any?(played_info, [{:start_of_game, ["Azalina Soulsever"]}])
    end

    test "plain list of strings as first argument works for played cards" do
      assert ArchetyperHelper.any?(["Azalina Soulsever"], ["Azalina Soulsever"])
      assert ArchetyperHelper.any?(["Azalina Soulsever"], [{:played, ["Azalina Soulsever"]}])
      refute ArchetyperHelper.any?(["Azalina Soulsever"], [{:start_of_game, ["Azalina Soulsever"]}])
    end

    test "extract_card_names extracts all card name strings" do
      config_cards = [
        "Enthralled Shade",
        {:start_of_game, ["Azalina Soulsever"]},
        {:played, ["Mind Sweeper", "Unshackle Soul"]}
      ]

      assert ArchetyperHelper.extract_card_names(config_cards) == [
               "Enthralled Shade",
               "Azalina Soulsever",
               "Mind Sweeper",
               "Unshackle Soul"
             ]
    end
  end

  describe "PriestArchetyper start_of_game rule" do
    test "matches Thief Priest when Azalina Soulsever is in start_of_game" do
      card_info = %{
        card_names: ["Cleansing Cleric"],
        start_of_game_card_names: ["Azalina Soulsever"],
        debug: false
      }

      assert PriestArchetyper.standard(card_info) == :"Thief Priest"
    end

    test "matches Thief Priest when Azalina Soulsever was played" do
      card_info = %{
        card_names: ["Azalina Soulsever"],
        start_of_game_card_names: [],
        debug: false
      }

      assert PriestArchetyper.standard(card_info) == :"Thief Priest"
    end
  end

  describe "PlayedCardsArchetyper.archetype pipeline" do
    test "archetypes based on start_of_game cards" do
      assert PlayedCardsArchetyper.archetype([], ["Azalina Soulsever"], "PRIEST", 2) == :"Thief Priest"
      assert PlayedCardsArchetyper.archetype(["Azalina Soulsever"], [], "PRIEST", 2) == :"Thief Priest"
      assert PlayedCardsArchetyper.archetype([], [], "PRIEST", 2) == :"Other Priest"
    end

    test "supports arity 3 with cards, start_of_game, class" do
      assert PlayedCardsArchetyper.archetype([], ["Azalina Soulsever"], "PRIEST") == :"Thief Priest"
    end

    test "supports played_cards map format" do
      played_cards = %{
        player_cards: [],
        player_start_of_game: ["Azalina Soulsever"]
      }

      assert PlayedCardsArchetyper.archetype(played_cards, "PRIEST", 2, false) == :"Thief Priest"
    end
  end
end
