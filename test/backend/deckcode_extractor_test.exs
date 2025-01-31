defmodule Hearthstone.DeckcodeExtractorText do
  @moduledoc false
  use ExUnit.Case, async: true
  alias Hearthstone.DeckcodeExtractor
  alias Backend.Hearthstone.Deck

  describe "extract_codes" do
    test "should extract short code" do
      test_code =
        "AAECAZICBp/zBamVBticBvajBsekBoviBgyunwTb+gW+mQaaoAagoAbvqQbDugbQygbzygat4gad4wad6wYAAQP0swbHpAb3swbHpAbo3gbHpAYAAA=="

      assert [^test_code] = DeckcodeExtractor.extract_codes(test_code)
    end

    test "should extract long code with link" do
      test_code = """
      ### Dungar Druid
      # Class: Druid
      # Format: Standard
      #
      # 2x (0) Forbidden Fruit
      # 2x (0) Innervate
      # 2x (1) Arkonite Revelation
      # 1x (1) Cactus Construct
      # 2x (1) Malfurion's Gift
      # 2x (2) Trail Mix
      # 2x (3) Frost Lotus Seedling
      # 2x (3) New Heights
      # 2x (3) Pendant of Earth
      # 2x (7) Crystal Cluster
      # 2x (8) Hydration Station
      # 2x (8) Splitting Spacerock
      # 2x (8) Star Grazer
      # 1x (8) Thunderbringer
      # 1x (9) Travelmaster Dungar
      # 1x (9) Zilliax Deluxe 3000
      #   1x (0) Zilliax Deluxe 3000
      #   1x (4) Virus Module
      #   1x (5) Perfect Module
      # 1x (10) Eonar, the Life-Binder
      # 1x (10) Yogg-Saron, Unleashed
      #
      AAECAZICBp/zBamVBticBvajBsekBoviBgyunwTb+gW+mQaaoAagoAbvqQbDugbQygbzygat4gad4wad6wYAAQP0swbHpAb3swbHpAbo3gbHpAYAAA==
      # To use this deck, copy it to your clipboard and create a new deck in Hearthstone
      # Find this deck on https://hsreplay.net/decks/VQInuhtkaRvYVPPnbg213g/
      """

      assert [_extracted] = DeckcodeExtractor.extract_codes(test_code)
    end
  end

  describe "extract_decks" do
    test "should extract short deck" do
      test_code =
        "AAECAZICBp/zBamVBticBvajBsekBoviBgyunwTb+gW+mQaaoAagoAbvqQbDugbQygbzygat4gad4wad6wYAAQP0swbHpAb3swbHpAbo3gbHpAYAAA=="

      real = Deck.decode!(test_code) |> Deck.deckcode()
      assert [^real] = DeckcodeExtractor.extract_decks(test_code)
    end

    test "should extract long deck with link" do
      test_code = """
      ### Dungar Druid
      # Class: Druid
      # Format: Standard
      #
      # 2x (0) Forbidden Fruit
      # 2x (0) Innervate
      # 2x (1) Arkonite Revelation
      # 1x (1) Cactus Construct
      # 2x (1) Malfurion's Gift
      # 2x (2) Trail Mix
      # 2x (3) Frost Lotus Seedling
      # 2x (3) New Heights
      # 2x (3) Pendant of Earth
      # 2x (7) Crystal Cluster
      # 2x (8) Hydration Station
      # 2x (8) Splitting Spacerock
      # 2x (8) Star Grazer
      # 1x (8) Thunderbringer
      # 1x (9) Travelmaster Dungar
      # 1x (9) Zilliax Deluxe 3000
      #   1x (0) Zilliax Deluxe 3000
      #   1x (4) Virus Module
      #   1x (5) Perfect Module
      # 1x (10) Eonar, the Life-Binder
      # 1x (10) Yogg-Saron, Unleashed
      #
      AAECAZICBp/zBamVBticBvajBsekBoviBgyunwTb+gW+mQaaoAagoAbvqQbDugbQygbzygat4gad4wad6wYAAQP0swbHpAb3swbHpAbo3gbHpAYAAA==
      # To use this deck, copy it to your clipboard and create a new deck in Hearthstone
      # Find this deck on https://hsreplay.net/decks/VQInuhtkaRvYVPPnbg213g/
      """

      real = test_code |> Deck.decode!() |> Deck.deckcode()
      assert [^real] = DeckcodeExtractor.extract_decks(test_code)
    end
  end
end
