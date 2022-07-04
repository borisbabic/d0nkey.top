defmodule Backend.HearthstoneTest do
  use Backend.DataCase
  alias Backend.Hearthstone

  @priest_code "AAEBAa0GKB74B/oO1hGDuwKwvALRwQLZwQLfxAKQ0wLy7AKXhwPmiAO9mQPrmwP8owPIvgPDzAPXzgP70QPi3gP44wOb6wOf6wOm7wO79wO+nwSEowSLowTlsASJsgTHsgSktgSWtwTbuQTsyQSW1ASY1ASa1ASX7wQAAA=="
  setup_all do
    {:ok, deck} = Hearthstone.create_or_get_deck(@priest_code)
    Backend.Repo.delete(deck)
    :ok
  end

  test "creates a deck with the class" do
    {:ok, deck} = Hearthstone.create_or_get_deck(@priest_code)
    refute deck.class == nil
  end
end
