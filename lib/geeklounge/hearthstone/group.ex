defmodule GeekLounge.Hearthstone.Group do
  @moduledoc false
  use TypedStruct
  alias GeekLounge.Hearthstone.Match
  alias GeekLounge.Hearthstone.Standing

  typedstruct do
    field :id, String.t()
    field :name, String.t()
    field :matches, [Match.t()]
    field :standings, [Standing.t()]
  end

  def from_raw_map(map) do
    %__MODULE__{
      id: map["id"],
      name: map["name"],
      matches: map["matches"] |> Enum.map(&Match.from_raw_map/1),
      standings: map["standings"] |> Enum.map(&Standing.from_raw_map/1)
    }
  end
end
