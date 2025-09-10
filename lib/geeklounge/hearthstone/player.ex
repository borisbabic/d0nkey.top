defmodule GeekLounge.Hearthstone.Player do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :id, String.t()
    field :display_name, String.t()
    field :avatar_url, String.t()
    field :battletag, String.t()
  end

  def from_raw_map(raw) do
    %__MODULE__{
      id: raw["id"],
      display_name: raw["display_name"],
      battletag: raw["battleTag"]
    }
  end
end
