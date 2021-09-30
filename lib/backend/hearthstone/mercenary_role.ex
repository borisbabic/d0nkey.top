defmodule Backend.Hearthstone.MercenaryRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  schema "hs_mercenary_roles" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(mercenary_role, %Hearthstone.Metadata.MercenaryRole{} = struct) do
    attrs = Map.from_struct(struct)

    mercenary_role
    |> cast(attrs, [:id, :name, :slug])
    |> validate_required([:id, :name, :slug])
  end
end
