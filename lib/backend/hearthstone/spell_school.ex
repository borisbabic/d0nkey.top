defmodule Backend.Hearthstone.SpellSchool do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  schema "hs_spell_schools" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(spell_school, %Hearthstone.Metadata.SpellSchool{} = struct) do
    attrs = Map.from_struct(struct)

    spell_school
    |> cast(attrs, [:id, :name, :slug])
    |> validate_required([:id, :name, :slug])
  end
end
