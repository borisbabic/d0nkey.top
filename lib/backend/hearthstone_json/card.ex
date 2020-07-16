defmodule Backend.HearthstoneJson.Card do
  @moduledoc false
  import TypedStruct

  typedstruct enforce: false do
    field :id, String.t()
    field :dbf_id, integer, required: true
    field :name, String.t()
    field :text, String.t()
    field :flavor, String.t()
    field :artist, String.t()
    field :attack, integer
    field :card_class, String.t()
    field :collectible, boolean
    field :cost, integer
    field :elite, boolean
    field :faction, String.t()
    field :health, integer
    field :mechanics, [String.t()]
    field :rarity, String.t()
    field :set, String.t()
    field :type, String.t()
  end

  def from_raw_map(map = %{"dbfId" => _}) do
    map
    |> Recase.Enumerable.convert_keys(&Recase.to_snake/1)
    |> from_raw_map()
  end

  def from_raw_map(map = %{"dbf_id" => _}) do
    %__MODULE__{
      id: map["id"],
      dbf_id: map["dbf_id"],
      name: map["name"],
      text: map["text"],
      flavor: map["flavor"],
      artist: map["artist"],
      attack: map["attack"],
      card_class: map["card_class"],
      collectible: map["collectible"],
      cost: map["cost"],
      elite: map["elite"],
      faction: map["faction"],
      health: map["health"],
      mechanics: map["mechanics"],
      rarity: map["rarity"],
      set: map["set"],
      type: map["type"]
    }
  end
end
