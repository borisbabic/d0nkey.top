defmodule Hearthstone.Metadata.Type do
  @moduledoc "Card types"

  use TypedStruct

  typedstruct enforce: true do
    field :id, integer()
    field :name, String.t()
    field :slug, String.t()
    field :game_modes, [integer()]
  end

  def from_raw_map(%{"id" => id, "name" => name, "slug" => slug, "gameModes" => game_modes}) do
    %__MODULE__{
      id: id,
      name: name,
      slug: slug,
      game_modes: game_modes
    }
  end
end
