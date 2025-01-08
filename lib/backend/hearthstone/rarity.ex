defmodule Backend.Hearthstone.Rarity do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}
  schema "hs_rarities" do
    field :crafting_cost, {:array, :integer}
    field :dust_value, {:array, :integer}
    field :gold_crafting_cost, :integer
    field :gold_dust_value, :integer
    field :name, :string
    field :normal_crafting_cost, :integer
    field :normal_dust_value, :integer
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(rarity, %Hearthstone.Metadata.Rarity{} = struct) do
    attrs = Map.from_struct(struct)

    rarity
    |> cast(attrs, [:id, :name, :slug, :dust_value, :crafting_cost])
    |> put_dust_values(attrs)
    |> put_crafting_costs(attrs)
    |> validate_required([:id, :name, :slug, :dust_value, :crafting_cost])
  end

  defp put_dust_values(cs, %{dust_value: [normal, gold | _]}),
    do:
      cast(cs, %{normal_dust_value: normal, gold_dust_value: gold}, [
        :normal_dust_value,
        :gold_dust_value
      ])

  defp put_dust_values(cs, _), do: cs

  defp put_crafting_costs(cs, %{crafting_cost: [normal, gold | _]}),
    do:
      cast(cs, %{normal_crafting_cost: normal, gold_crafting_cost: gold}, [
        :normal_crafting_cost,
        :gold_crafting_cost
      ])

  defp put_crafting_costs(cs, _), do: cs

  @spec upcase(%__MODULE__{} | String.t()) :: String.t()
  def upcase(%{slug: slug}), do: upcase(slug)
  def upcase(rarity) when is_binary(rarity), do: String.upcase(rarity)
  def upcase(nil), do: nil
end
