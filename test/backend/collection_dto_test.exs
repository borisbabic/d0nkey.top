defmodule Backend.CollectionManager.CollectionDtoTest do
  @moduledoc false
  use ExUnit.Case
  alias Backend.CollectionManager.CollectionDto

  @valid_map %{
    "BnetRegion" => "2",
    "battleTag" => "D0nkey#2470",
    "cards" => []
  }
  test "parses map correctly" do
    assert {:ok, %{region: 2, battletag: "D0nkey#2470", cards: [], updated: %NaiveDateTime{}}} =
             CollectionDto.from_raw_map(@valid_map, NaiveDateTime.utc_now())
  end

  test "error with unknown card" do
    id = "THIS_IS_AN_INVALID_ID"
    map = Map.put(@valid_map, "cards", [%{"id" => id}])
    assert {:error, error_msg} = CollectionDto.from_raw_map(map, NaiveDateTime.utc_now())
    assert error_msg =~ id
  end
end
