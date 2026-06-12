defmodule Iyingdi.Hearthstone.Deck do
  @moduledoc false

  use TypedStruct

  typedstruct do
    field :id, String.t()
    field :code, String.t()
    field :player, String.t()
    field :name, String.t()
    field :set_name, String.t()
    field :created, integer()
    field :visible?, boolean
  end

  def from_raw_map(%{"deck" => deck}) when is_map(deck) do
    from_raw_map(deck)
  end

  def from_raw_map(map) when is_map(map) do
    %__MODULE__{
      id: map["id"],
      code: map["code"],
      player: map["player"],
      name: map["name"],
      set_name: map["setName"] || map["set_name"],
      created: map["integer"],
      visible?: map["visible"] == 1
    }
  end
end
