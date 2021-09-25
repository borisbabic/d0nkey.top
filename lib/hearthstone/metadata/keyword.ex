defmodule Hearthstone.Metadata.Keyword do
  @moduledoc false

  use TypedStruct

  typedstruct enforce: true do
    field :id, integer()
    field :game_modes, [integer()]
    field :name, String.t()
    field :slug, String.t()
    field :ref_text, String.t()
    field :text, String.t()
  end

  def from_raw_map(%{
        "gameModes" => game_modes,
        "id" => id,
        "name" => name,
        "refText" => ref_text,
        "slug" => slug,
        "text" => text
      }) do
    %__MODULE__{
      id: id,
      game_modes: game_modes,
      name: name,
      slug: slug,
      ref_text: ref_text,
      text: text
    }
  end
end
