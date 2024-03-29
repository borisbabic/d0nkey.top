defmodule Backend.Hearthstone.DeckTest do
  use Backend.DataCase, async: true

  alias Backend.Hearthstone.Deck

  test "should decode code with multiple card copies" do
    test_code =
      "AAECAZICAAADAgWSAgbmBQrKnAMK/60DCvm1AwrlugMK77oDCvnMAwqbzgMKudIDCvDUAwqJ4AMKiuADCozkAwqunwQK2Z8ECg=="

    assert {:ok, %{cards: [_ | _]}} = Backend.Hearthstone.Deck.decode(test_code)
  end

  test "should correctly decode weird highlander code" do
    test_code =
      "AAEBAQce38QC9s8CkvgC/KMDkbED9sID cIDk9AD99QDtt4Dju0Dpu8DxfUDm4EEvIoE YwE owEn58EhqAEiaAEi7cEjtQEmNQEmtQEnNQEuNkEw5IFy5IFzJIF4qQFAAA="

    assert {:ok, %{cards: cards}} = Backend.Hearthstone.Deck.decode(test_code)
    assert 30 = cards |> Enum.count()
    assert 30 = cards |> Enum.uniq() |> Enum.count()
  end

  test "should encode then decode deckcode with gazillion cards" do
    raw_cards = [
      254,
      254,
      503,
      503,
      742,
      742,
      52810,
      52810,
      55039,
      55039,
      56057,
      56057,
      56677,
      56677,
      56687,
      56687,
      59001,
      59001,
      59163,
      59163,
      59705,
      59705,
      60016,
      60016,
      61449,
      61449,
      61450,
      61450,
      61964,
      61964,
      2,
      2,
      2,
      2,
      2,
      274,
      274,
      274,
      274,
      274,
      274,
      254,
      254,
      254,
      254,
      254,
      254,
      254,
      254,
      503,
      503,
      503,
      503,
      503,
      503,
      503,
      503,
      742,
      742,
      742,
      742,
      742,
      742,
      742,
      742,
      52810,
      52810,
      52810,
      52810,
      52810,
      52810,
      52810,
      52810,
      55039,
      55039,
      55039,
      55039,
      55039,
      55039,
      55039,
      55039,
      56057,
      56057,
      56057,
      56057,
      56057,
      56057,
      56057,
      56057,
      56677,
      56677,
      56677,
      56677,
      56677,
      56677,
      56677,
      56677,
      56687,
      56687,
      56687,
      56687,
      56687,
      56687,
      56687,
      56687,
      59001,
      59001,
      59001,
      59001,
      59001,
      59001,
      59001,
      59001,
      59163,
      59163,
      59163,
      59163,
      59163,
      59163,
      59163,
      59163,
      59705,
      59705,
      59705,
      59705,
      59705,
      59705,
      59705,
      59705,
      60016,
      60016,
      60016,
      60016,
      60016,
      60016,
      60016,
      60016,
      61449,
      61449,
      61449,
      61449,
      61449,
      61449,
      61449,
      61449,
      61450,
      61450,
      61450,
      61450,
      61450,
      61450,
      61450,
      61450,
      61964,
      61964,
      61964,
      61964,
      61964,
      61964,
      61964,
      61964
    ]

    cards = Backend.Hearthstone.Deck.canonicalize_cards(raw_cards) |> Enum.sort()
    format = 2
    hero = 274
    deckcode = Backend.Hearthstone.Deck.deckcode(cards, hero, format)

    assert {:ok, %{cards: ^cards, hero: ^hero, format: ^format, deckcode: new_code}} =
             Backend.Hearthstone.Deck.decode(deckcode)
  end
end
