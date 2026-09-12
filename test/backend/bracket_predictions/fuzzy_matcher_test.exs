defmodule Backend.BracketPredictions.FuzzyMatcherTest do
  use ExUnit.Case, async: true
  alias Backend.BracketPredictions.FuzzyMatcher

  describe "calculate_similarity/2" do
    test "exact match returns 1.0" do
      assert FuzzyMatcher.calculate_similarity("XiaoT", "XiaoT") == 1.0
      assert FuzzyMatcher.calculate_similarity("xiaot", "XIAOT") == 1.0
    end

    test "stripping battletag gives high similarity" do
      assert FuzzyMatcher.calculate_similarity("XiaoT#1234", "XiaoT") >= 0.98
    end

    test "substring matching gives high similarity" do
      assert FuzzyMatcher.calculate_similarity("XiaoT (Team Liquid)", "XiaoT") >= 0.90
    end

    test "unrelated names have low similarity" do
      assert FuzzyMatcher.calculate_similarity("RandomGuy", "XiaoT") < 0.6
    end
  end

  describe "suggest_mappings/2" do
    test "suggests best matches for external names" do
      bf_names = ["XiaoT#1234", "PocketTrain", "UnknownPlayer#9999"]
      local_names = ["XiaoT", "PocketTrain", "Definition", "Tansoku"]

      suggestions = FuzzyMatcher.suggest_mappings(bf_names, local_names)

      assert suggestions["XiaoT#1234"].suggested_local_name == "XiaoT"
      assert suggestions["XiaoT#1234"].confidence >= 0.9

      assert suggestions["PocketTrain"].suggested_local_name == "PocketTrain"
      assert suggestions["PocketTrain"].confidence == 1.0

      assert suggestions["UnknownPlayer#9999"].suggested_local_name == nil
    end
  end

  describe "resolve_name/2" do
    test "resolves using mappings map or falls back to raw name" do
      mappings = %{"XiaoT#1234" => "XiaoT"}
      assert FuzzyMatcher.resolve_name("XiaoT#1234", mappings) == "XiaoT"
      assert FuzzyMatcher.resolve_name("Definition", mappings) == "Definition"
    end

    test "resolves case-insensitively using mappings map" do
      mappings = %{"xiaot#1234" => "XiaoT"}
      assert FuzzyMatcher.resolve_name("XIAOT#1234", mappings) == "XiaoT"
      assert FuzzyMatcher.resolve_name("XiaoT#1234", mappings) == "XiaoT"
    end
  end
end
