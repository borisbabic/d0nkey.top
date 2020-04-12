defmodule Backend.Battlefy.Team do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :name, String.t()
  end

  def from_raw_map(%{"name" => name}) do
    %__MODULE__{
      name: name
    }
  end
end
