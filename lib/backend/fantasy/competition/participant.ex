defmodule Backend.Fantasy.Competition.Participant do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :name, String.t()
  end
end
