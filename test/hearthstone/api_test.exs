defmodule Hearthstone.ApiTest do
  use ExUnit.Case

  alias Hearthstone.Api

  describe "metadata" do
    test "get_metadata is successfull" do
      assert {:ok, %{sets: [_ | _]}} = Api.get_metadata()
    end

    test "get_cards is successfull" do
      assert {:ok, %{cards: [_ | _]}} = Api.get_cards()
    end

    test "next_page successfully returns the next page" do
      {:ok, cards_response = %{page: original_page}} = Api.get_cards()
      assert {:ok, %{page: next_page}} = Api.next_page(cards_response)
      assert original_page + 1 == next_page
    end

    test "get_mercenaries is successfull and returns only mercs" do
      assert {:ok, %{cards: cards = [_ | _]}} = Api.get_mercenaries()
      refute Enum.any?(cards, &(&1.mercenary_hero == nil))
    end
  end
end
