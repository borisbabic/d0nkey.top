defmodule Backend.Hearthstone.Faction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}
  schema "hs_factions" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(faction, %Hearthstone.Metadata.Faction{} = struct) do
    attrs = Map.from_struct(struct)

    faction
    |> cast(attrs, [:name, :slug, :id])
    |> validate_required([:name, :slug, :id])
  end
end
