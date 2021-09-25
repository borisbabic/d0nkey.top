defmodule Hearthstone.Metadata.CardBackCategory do
  @moduledoc false

  use TypedStruct

  typedstruct do
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
