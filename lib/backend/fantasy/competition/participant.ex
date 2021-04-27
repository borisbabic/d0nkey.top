defmodule Backend.Fantasy.Competition.Participant do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: false do
    field :name, String.t(), enfore: true
    field :meta, Map.t(), default: nil
  end

  def in_battlefy?(%{meta: %{in_battlefy: true}}), do: true
  def in_battlefy?(_), do: false
end
