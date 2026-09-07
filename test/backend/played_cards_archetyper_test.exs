defmodule Backend.PlayedCardsArchetyperTest do
  use Backend.DataCase, async: true

  alias Backend.PlayedCardsArchetyper
  alias Backend.PlayedCardsArchetyper.ArchetyperHelper
  alias Backend.PlayedCardsArchetyper.PriestArchetyper
  alias Backend.PlayedCardsArchetyper.ShamanArchetyper

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

  describe "ArchetyperHelper :all and :any logic" do
    test ":all requires all elements to match" do
      both_played = %{card_names: ["CardA", "CardB"], start_of_game_card_names: []}
      one_played = %{card_names: ["CardA"], start_of_game_card_names: []}
      none_played = %{card_names: ["CardC"], start_of_game_card_names: []}

      assert ArchetyperHelper.matches?(both_played, {:all, ["CardA", "CardB"]})
      refute ArchetyperHelper.matches?(one_played, {:all, ["CardA", "CardB"]})
      refute ArchetyperHelper.matches?(none_played, {:all, ["CardA", "CardB"]})

      assert ArchetyperHelper.all?(both_played, ["CardA", "CardB"])
      refute ArchetyperHelper.all?(one_played, ["CardA", "CardB"])
    end

    test ":any matches when at least one element matches" do
      one_played = %{card_names: ["CardA"], start_of_game_card_names: []}
      none_played = %{card_names: ["CardC"], start_of_game_card_names: []}

      assert ArchetyperHelper.matches?(one_played, {:any, ["CardA", "CardB"]})
      refute ArchetyperHelper.matches?(none_played, {:any, ["CardA", "CardB"]})
    end

    test "plain lists evaluate as implicit :any" do
      one_played = %{card_names: ["CardA"], start_of_game_card_names: []}
      none_played = %{card_names: ["CardC"], start_of_game_card_names: []}

      assert ArchetyperHelper.matches?(one_played, ["CardA", "CardB"])
      refute ArchetyperHelper.matches?(none_played, ["CardA", "CardB"])
    end

    test "supports arbitrary nesting of :all, :any, plain lists, and start_of_game" do
      rule = {:all, [{:any, ["CardA", "CardB"]}, {:start_of_game, ["Mug'Zee"]}]}

      matching_a = %{card_names: ["CardA"], start_of_game_card_names: ["Mug'Zee"]}
      matching_b = %{card_names: ["CardB"], start_of_game_card_names: ["Mug'Zee"]}
      missing_sog = %{card_names: ["CardA"], start_of_game_card_names: []}
      missing_played = %{card_names: ["CardC"], start_of_game_card_names: ["Mug'Zee"]}

      assert ArchetyperHelper.matches?(matching_a, rule)
      assert ArchetyperHelper.matches?(matching_b, rule)
      refute ArchetyperHelper.matches?(missing_sog, rule)
      refute ArchetyperHelper.matches?(missing_played, rule)

      deep_rule = {:all, [{:any, [{:all, ["CardA", "CardB"]}, "CardC"]}, {:start_of_game, ["Mug'Zee"]}]}

      assert ArchetyperHelper.matches?(
               %{card_names: ["CardA", "CardB"], start_of_game_card_names: ["Mug'Zee"]},
               deep_rule
             )

      refute ArchetyperHelper.matches?(
               %{card_names: ["CardA"], start_of_game_card_names: ["Mug'Zee"]},
               deep_rule
             )

      assert ArchetyperHelper.matches?(
               %{card_names: ["CardC"], start_of_game_card_names: ["Mug'Zee"]},
               deep_rule
             )
    end

    test "extract_card_names recursively extracts cards from :all and :any" do
      nested_config = [
        {:all,
         [
           {:start_of_game, ["Mug'Zee"]},
           ["Beaming Sidekick", "Carrier Whelp"]
         ]}
      ]

      assert ArchetyperHelper.extract_card_names(nested_config) == [
               "Mug'Zee",
               "Beaming Sidekick",
               "Carrier Whelp"
             ]

      deep_config = {:any, ["CardA", {:all, ["CardB", "CardC"]}]}
      assert ArchetyperHelper.extract_card_names(deep_config) == ["CardA", "CardB", "CardC"]
    end
  end
end
