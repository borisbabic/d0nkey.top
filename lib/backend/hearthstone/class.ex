defmodule Backend.Hearthstone.Class do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  schema "hs_classes" do
    field :alternate_hero_card_ids, {:array, :integer}
    field :card_id, :integer
    field :hero_power_card_id, :integer
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(class, %Hearthstone.Metadata.Class{} = struct) do
    attrs = Map.from_struct(struct)

    class
    |> cast(attrs, [:id, :name, :slug, :alternate_hero_card_ids, :card_id, :hero_power_card_id])
    |> validate_required([:id, :name, :slug, :alternate_hero_card_ids])
  end

  @spec upcase(%__MODULE__{} | String.t()) :: String.t()
  def upcase(%{slug: slug}), do: upcase(slug)
  def upcase(rarity) when is_binary(rarity), do: String.upcase(rarity)
  def upcase(nil), do: nil
end
