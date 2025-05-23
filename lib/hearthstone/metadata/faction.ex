defmodule Hearthstone.Metadata.Faction do
  @moduledoc false

  use TypedStruct

  typedstruct enforce: true do
    field :id, integer()
    field :name, String.t()
    field :slug, String.t()
  end

  def from_raw_map(%{"id" => id, "name" => name, "slug" => slug}) do
    %__MODULE__{
      id: id,
      name: name,
      slug: slug
    }
  end
end
