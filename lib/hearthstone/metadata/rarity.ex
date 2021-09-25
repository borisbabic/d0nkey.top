defmodule Hearthstone.Metadata.Rarity do
  @moduledoc false

  use TypedStruct

  typedstruct enforce: true do
    field :id, integer()
    field :name, String.t()
    field :slug, String.t()
    field :dust_value, [integer()]
    field :crafting_cost, [integer()]
  end

  def from_raw_map(%{
        "id" => id,
        "name" => name,
        "slug" => slug,
        "dustValue" => dust_value,
        "craftingCost" => crafting_cost
      }) do
    %__MODULE__{
      id: id,
      name: name,
      slug: slug,
      crafting_cost: crafting_cost,
      dust_value: dust_value
    }
  end

  @spec dust_value_normal(__MODULE__.t()) :: integer()
  def dust_value_normal(%{dust_value: [normal | _]}), do: normal

  @spec dust_value_gold(__MODULE__.t()) :: integer()
  def dust_value_gold(%{dust_value: [_normal, gold | _]}), do: gold

  @spec crafting_cost_normal(__MODULE__.t()) :: integer()
  def crafting_cost_normal(%{crafting_cost: [normal | _]}), do: normal

  @spec crafting_cost_gold(__MODULE__.t()) :: integer()
  def crafting_cost_gold(%{crafting_cost: [_normal, gold | _]}), do: gold
end
