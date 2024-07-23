defmodule Backend.Hearthstone.DeckcodeEmbiggenerTest do
  use ExUnit.Case, async: true

  alias Backend.Hearthstone.DeckcodeEmbiggener

  test "should include all rarities" do
    test_code =
      "AAECAZICCImLBPGkBOnQBJbUBJjUBO/eBJfvBL7wBBCt7AOsgASvgASwgASJnwSunwTanwSwpQTPrAT/vQTwvwSuwASB1ASy3QTW3gTB3wQA"

    embiggened = DeckcodeEmbiggener.embiggen(test_code)
    assert embiggened =~ "🟨"
    assert embiggened =~ "🟪"
    assert embiggened =~ "🟦"
    assert embiggened =~ "⬜"
  end

  test "should decode deck" do
    test_code = "AAEDAQcAD5OWBJeWBJiWBNSWBP+WBPmgBLGhBMahBNWhBLmiBMCiBMOiBMWiBJ2jBJ+jBAA="
    embiggened = DeckcodeEmbiggener.embiggen(test_code)
    assert embiggened =~ "Warrior"
  end
end
