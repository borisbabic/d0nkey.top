defmodule Backend.PlayedCardsArchetyper.NextLevelGeneratorTest do
  use ExUnit.Case, async: true
  alias Backend.PlayedCardsArchetyper.NextLevelGenerator
  doctest NextLevelGenerator

  test "groups pairs by the most shared card" do
    pairs = [~w(A B), ~w(A C), ~w(A D), ~w(A E), ~w(B C), ~w(B D), ~w(D E)]

    assert NextLevelGenerator.generate("Example Archetype", pairs) == """
                 "Example Archetype": [
                   {:all,
                    [
                      ["A"],
                      ["B", "C", "D", "E"]
                    ]},
                   {:all,
                    [
                      ["B"],
                      ["C", "D"]
                    ]},
                   {:all,
                    [
                      ["D"],
                      ["E"]
                    ]}
                 ],\
           """
  end

  test "lists single cards directly" do
    assert NextLevelGenerator.generate("Spell Mage", [["Fireball"], ["Frostbolt"]]) == """
                 "Spell Mage": [
                   "Fireball",
                   "Frostbolt"
                 ],\
           """
  end

  test "generated code evaluates to a matching config" do
    {[{archetype, matchers}], _} =
      NextLevelGenerator.generate("Example Archetype", [~w(A B), ~w(B C), ["D"]])
      |> then(&"[#{&1}]")
      |> Code.eval_string()

    assert archetype == :"Example Archetype"
    assert Backend.PlayedCardsArchetyper.ArchetyperHelper.matches?(~w(B C), matchers)
    assert Backend.PlayedCardsArchetyper.ArchetyperHelper.matches?(~w(D), matchers)
    refute Backend.PlayedCardsArchetyper.ArchetyperHelper.matches?(~w(A C), matchers)
  end
end
