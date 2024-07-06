defmodule Backend.DeckArchetyperTest do
  use Backend.DataCase, async: true

  alias Backend.Hearthstone.Deck
  alias Backend.DeckArchetyper
  # @test_cases [
  # {:"Big Beast Hunter", "AAECAR8I5e8DxfsDlPwD25EE4Z8EwLkE57kEm8kEC+rpA8OABKmfBNejBOWkBMCsBO2xBIiyBJa3BOC5BIPIBAA="},
  # {:"Quest Hunter", "AAECAR8G/fgDu4oE25EE458EhskEj6QFDNzqA9vtA/f4A9D5A6mfBKqfBLugBL+sBMGsBJ2wBIe3BIzUBAA="},
  # {:"Aggro Hunter", "AAECAR8C57kEhskEDurpA9zqA/T2A/f4A8X7A8OABNijBOWkBJ2wBO2xBIiyBOC5BIPIBIHJBAA="},
  # {:"Aggro Hunter", "AAECAR8C5e8DhskEDtzqA/f4A8X7A8OABKqfBLugBMukBOGkBJ2wBO2xBIiyBOC5BIPIBIHJBAA="},
  # {:"Naga Mage", "AAECAf0ECNTqA9jsA6CKBOWwBIe3BJbUBJjUBKneBAvQ7APT7APW7AOu9wP8ngSIsgS8sgSWtwTcuQThuQSywQQA"},
  # {:"Mech Mage", "AAECAf0EAqGxBOy6BA7S7APD+QPWoAThpASStQThtQTJtwTKtwTduQTjuQTkuQSywQTY2QSUpAUA"},
  # {:"Mech Mage", "AAECAf0EBMP5A/+iBKGxBOy6BA2TgQTWoAT6rASStQThtQTJtwTKtwTduQTjuQTkuQSywQTY2QSUpAUA"},
  # {:"Mech Mage", "AAECAf0EBKCKBP+iBJmwBKGxBA3D+QOSgQSTgQShkgT7ogT6rAThtQTJtwTKtwTduQSywQTx0wTY2QQA"},
  # {:"Big Spell Mage", "AAECAf0ECJ3uA6bvA9D5A6CKBP+iBO/TBJbUBJjUBAuSgQSTgQShkgT7ogT6rASZsASWtwTx0wSb1ASd1ASj1AQA"},
  # {:"Big Spell Mage", "AAECAf0EBtjsA53uA9D5A6CKBP+iBOWwBAzT7APO+QOSgQSTgQSljQShkgT7ogT6rASZsASNtQSWtwSd1AQA"},
  # {:"Holy Paladin", "AAECAZ8FCPvoA5HsA9D5A7+ABKiKBOCLBLCyBNC9BAvM6wPw9gOL+AO3gASLjQTunwSHtwTavQSS1ASh1ATa2QQA"},
  # {:"Holy Paladin", "AAECAZ8FCPvoA5HsA434A8f5A7+ABOCLBN65BKHiBAvM6wPw9gO2gASanwThpAT0pAT5pATQrATXvQTavQTa2QQA"},
  # {:"Handbuff Paladin", "AAECAZ8FCvvoA5HsA6L4A9n5A7+ABKqKBOCLBNCsBLCyBMeyBArw9gPz9gON+AOq+APJoAThtQTeuQSywQScxwTa2QQA"},
  # {:"Handbuff Paladin", "AAECAZ8FCPvoA5HsA434A8f5A7%2BABOCLBN65BKHiBAvM6wPw9gO2gASanwThpAT0pAT5pATQrATXvQTavQTa2QQA%2CAAECAZ8FCvvoA5HsA6L4A9n5A7%2BABKqKBOCLBNCsBLCyBMeyBArw9gPz9gON%2BAOq%2BAPJoAThtQTeuQSywQScxwTa2QQA%2CAAECAZ8FCvvoA5HsA434A8f5A9D5A9j5A6qKBOCLBNrTBJjUBArw9gOq%2BAPJoAT0pAT5pAThtQTeuQSywQTa2QSUpAUA"},
  ## could be mech paladin, aaahh, rough choice
  # {:"Handbuff Paladin", "AAECAZ8FCPvoA6L4A7+ABKqKBOCLBLCyBOy6BNS9BAvw9gOq+APJoATWoASStQThtQTeuQScxwTa0wTa2QSUpAUA"},
  # ]
  # describe "test_decks" do
  # for {archetype, deckcode} <- @test_cases do
  # {:ok, deck} = Deck.decode(deckcode)
  # assert archetype == DeckArchetyper.archetype(deck)
  # end
  # end

  test "No cards in deck no error" do
    deck = Deck.deckcode([], Deck.get_basic_hero("HUNTER"), 2) |> Deck.decode!()
    assert to_string(DeckArchetyper.archetype(deck)) =~ "Hunter"
  end

  # errored out streamer decks
  test "deck_archetyper doesnt' error" do
    deck =
      Deck.decode!(
        "AAECAfHhBAqoigSk7wTipAXLpQWeqgXzyAX8+QXt/wWLkgb/lwYK0e0Eh/YEsvcEtPcEkpMFoJkF8OgFg5IGkZcGgJgGAAA="
      )

    DeckArchetyper.archetype(deck)
    assert true
  end
end
