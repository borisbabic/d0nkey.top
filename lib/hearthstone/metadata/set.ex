defmodule Hearthstone.Metadata.Set do
  @moduledoc false

  use TypedStruct
  alias __MODULE__

  typedstruct enforce: true do
    field :id, integer()
    field :name, String.t()
    field :slug, String.t()
    field :collectible_count, integer()
    field :collectible_revealed_count, integer()
    field :non_collectible_count, integer()
    field :non_collectible_revealed_count, integer()
    field :type, String.t()

    # optional
    # for legacy
    field :alias_set_ids, [integer()]
  end

  def from_raw_map(map = %{"id" => id, "name" => name, "slug" => slug}) do
    %__MODULE__{
      id: id,
      name: name,
      slug: slug,
      type: map["type"],
      collectible_count: map["collectibleCount"],
      collectible_revealed_count: map["collectibleRevealedCount"],
      non_collectible_count: map["nonCollectibleCount"],
      non_collectible_revealed_count: map["nonCollectibleReveleadCount"],
      alias_set_ids: map["alias_set_ids"] || []
    }
  end

  @spec adventure?(Set.t()) :: boolean()
  def adventure?(%{type: "adventure"}), do: true
  def adventure?(_), do: false

  @spec expansion?(Set.t()) :: boolean()
  def expansion?(%{type: "expansion"}), do: true
  def expansion?(_), do: false
end
