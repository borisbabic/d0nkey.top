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

  describe "ShamanArchetyper :all and start_of_game rules" do
    test "Zee Shaman matches when Mug'Zee is in start of game and a Zee card was played" do
      card_info = %{
        card_names: ["Beaming Sidekick"],
        start_of_game_card_names: ["Mug'Zee"],
        debug: false
      }

      assert ShamanArchetyper.standard(card_info) == :"Zee Shaman"
    end

    test "Zee Shaman does not match without Mug'Zee in start of game" do
      card_info = %{
        card_names: ["Beaming Sidekick"],
        start_of_game_card_names: [],
        debug: false
      }

      assert ShamanArchetyper.standard(card_info) == :"Other Shaman"
    end

    test "Zee Shaman does not match without any Zee card played" do
      card_info = %{
        card_names: ["Lightning Bolt"],
        start_of_game_card_names: ["Mug'Zee"],
        debug: false
      }

      assert ShamanArchetyper.standard(card_info) == :"Other Shaman"
    end

    test "Mug Shaman matches when Mug'Zee is in start of game and a Mug card was played" do
      card_info = %{
        card_names: ["Ascendance"],
        start_of_game_card_names: ["Mug'Zee"],
        debug: false
      }

      assert ShamanArchetyper.standard(card_info) == :"Mug Shaman"
    end

    test "Mug Shaman does not match without Mug'Zee in start of game" do
      card_info = %{
        card_names: ["Ascendance"],
        start_of_game_card_names: [],
        debug: false
      }

      assert ShamanArchetyper.standard(card_info) == :"Other Shaman"
    end

    test "Harold Shaman matches when a Harold card is played and Mug'Zee is NOT in start of game" do
      card_info = %{
        card_names: ["Twilight Egg"],
        start_of_game_card_names: [],
        debug: false
      }

      assert ShamanArchetyper.standard(card_info) == :"Harold Shaman"
    end

    test "Harold Shaman is excluded when Mug'Zee IS in start of game" do
      card_info = %{
        card_names: ["Twilight Egg"],
        start_of_game_card_names: ["Mug'Zee"],
        debug: false
      }

      assert ShamanArchetyper.standard(card_info) == :"Other Shaman"
    end

    test "PlayedCardsArchetyper pipeline archetypes Shaman decks correctly" do
      assert PlayedCardsArchetyper.archetype(["Beaming Sidekick"], ["Mug'Zee"], "SHAMAN", 2) == :"Zee Shaman"
      assert PlayedCardsArchetyper.archetype(["Ascendance"], ["Mug'Zee"], "SHAMAN", 2) == :"Mug Shaman"
      assert PlayedCardsArchetyper.archetype(["Twilight Egg"], [], "SHAMAN", 2) == :"Harold Shaman"
      assert PlayedCardsArchetyper.archetype(["Twilight Egg"], ["Mug'Zee"], "SHAMAN", 2) == :"Other Shaman"
    end
  end
end
