defmodule GeekLounge.Hearthstone.Round do
  @moduledoc false
  use TypedStruct

  alias GeekLounge.Hearthstone.Match

  typedstruct do
    field :round, integer()
    field :name, String.t()
    field :matches, [Match.t()]
  end

  def from_raw_map(map) do
    %__MODULE__{
      round: map["round"],
      name: map["name"],
      matches: map["matches"] |> Enum.map(&Match.from_raw_map/1)
    }
  end
end
