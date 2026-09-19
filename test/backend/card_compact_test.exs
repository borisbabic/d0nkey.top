defmodule Backend.CardCompactTest do
  use ExUnit.Case, async: true
  alias Backend.Hearthstone.Card
  alias Backend.HearthstoneJson

  describe "Card.art_url/1 and HearthstoneJson.art_url/1" do
    test "returns correct 256x square art URL for string card id" do
      assert HearthstoneJson.art_url("CS2_029") == "https://art.hearthstonejson.com/v1/256x/CS2_029.jpg"
      assert Card.art_url(%{card_id: "CS2_029"}) == "https://art.hearthstonejson.com/v1/256x/CS2_029.jpg"
    end

    test "handles nil and unknown ids gracefully" do
      assert HearthstoneJson.art_url(nil) == nil
      assert Card.art_url(nil) == nil
    end
  end

  describe "Card.durability_or_health/1" do
    test "checks health first, then durability" do
      # Minion with health
      minion = %{health: 5, durability: nil}
      assert Card.durability_or_health(minion) == 5

      # Weapon with durability and no health
      weapon = %{health: nil, durability: 3}
      assert Card.durability_or_health(weapon) == 3

      # Both health and durability present (health takes precedence)
      both = %{health: 7, durability: 2}
      assert Card.durability_or_health(both) == 7

      # Neither present
      spell = %{health: nil, durability: nil}
      assert Card.durability_or_health(spell) == nil
      assert Card.durability_or_health(nil) == nil
    end
  end
end
