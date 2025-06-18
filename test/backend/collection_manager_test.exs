defmodule Backend.CollectionManagerTest do
  use Backend.DataCase
  alias Backend.CollectionManager
  alias Backend.CollectionManager.CollectionDto
  alias Backend.CollectionManager.CollectionDto.Card

  @base_dto %CollectionDto{
    battletag: "D0nkey#2470",
    region: 2,
    cards: [Card.new(31, %{plain_count: 1})],
    updated: NaiveDateTime.utc_now()
  }

  test "upsert_collection/1 upserts valid collection" do
    battletag = Ecto.UUID.generate()
    dto = Map.put(@base_dto, :battletag, battletag)

    assert {:ok, %{battletag: ^battletag, public: false}} =
             CollectionManager.upsert_collection(dto)
  end

  test "upsert_collection/1 upserts newer collection" do
    battletag = Ecto.UUID.generate()
    dto = Map.put(@base_dto, :battletag, battletag)

    later =
      dto
      |> Map.put(:updated, NaiveDateTime.utc_now() |> Timex.shift(hours: 1))
      |> Map.put(:cards, [Card.new(-4) | dto.cards])

    assert {:ok, %{battletag: ^battletag, public: false, cards: first_cards}} =
             CollectionManager.upsert_collection(dto)

    assert {:ok, %{battletag: ^battletag, public: false, cards: second_cards}} =
             CollectionManager.upsert_collection(later)

    diff = Enum.count(second_cards) - Enum.count(first_cards)
    assert 1 = diff
  end

  test "upsert_collection/1 doesn't upsert older collection" do
    battletag = Ecto.UUID.generate()
    dto = Map.put(@base_dto, :battletag, battletag)

    before =
      dto
      |> Map.put(:updated, NaiveDateTime.utc_now() |> Timex.shift(years: -10))
      |> Map.put(:cards, [])

    assert {:ok, %{battletag: ^battletag, public: false, cards: [_ | _]}} =
             CollectionManager.upsert_collection(dto)

    assert {:ok, %{battletag: ^battletag, public: false, cards: [_ | _]}} =
             CollectionManager.upsert_collection(before)
  end

  test "parse_map and upsert dto" do
    battletag = Ecto.UUID.generate()
    map = %{"battletag" => battletag, "region" => 2, "cards" => []}
    {:ok, dto} = CollectionDto.from_raw_map(map, NaiveDateTime.utc_now())

    assert {:ok, %{battletag: ^battletag, public: false, cards: []}} =
             CollectionManager.upsert_collection(dto)
  end
end
