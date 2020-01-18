defmodule Backend.Battlefy.Team do
  use TypedStruct

  typedstruct enforce: true do
    field :name, String.t()
  end

  def from_raw_map(%{"name" => name}) do
    %__MODULE__{
      name: name
    }
  end
end
