defmodule Backend.Hearthstone.Type do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  schema "hs_type" do
    field :game_modes, {:array, :integer}
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(type, %Hearthstone.Metadata.Type{} = struct) do
    attrs = Map.from_struct(struct)

    type
    |> cast(attrs, [:id, :name, :slug, :game_modes])
    |> validate_required([:id, :name, :slug, :game_modes])
  end
end
