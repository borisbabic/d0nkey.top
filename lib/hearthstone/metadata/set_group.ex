defmodule Hearthstone.Metadata.SetGroup do
  @moduledoc false

  use TypedStruct
  alias __MODULE__
  alias Hearthstone.Metadata.Set

  typedstruct enforce: true do
    # required
    field :name, String.t()
    field :slug, String.t()
    field :card_sets, [String.t()]

    # optional
    field :icon, String.t() | nil
    field :standard, boolean() | nil
    field :svg, String.t() | nil
    field :year, integer() | nil
    field :year_range, String.t() | nil
  end

  def from_raw_map(map = %{"name" => name, "slug" => slug, "cardSets" => card_sets}) do
    %__MODULE__{
      name: name,
      slug: slug,
      card_sets: card_sets,
      icon: map["icon"],
      standard: map["standard"],
      svg: map["svg"],
      year: map["year"],
      year_range: map["yearRange"]
    }
  end

  @spec contains_set?(SetGroup.t(), Set.t()) :: boolean()
  def contains_set?(%{card_sets: card_sets}, %{slug: slug}), do: slug in card_sets
end
