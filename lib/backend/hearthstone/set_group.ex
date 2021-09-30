defmodule Backend.Hearthstone.SetGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hs_set_groups" do
    field :icon, :string
    field :name, :string
    field :slug, :string
    field :standard, :boolean, default: false
    field :svg, :string
    field :year, :integer
    field :year_range, :string

    timestamps()
  end

  @doc false
  def changeset(set_group, %Hearthstone.Metadata.SetGroup{} = struct) do
    attrs = Map.from_struct(struct)

    set_group
    |> cast(attrs, [:name, :slug, :icon, :standard, :svg, :year, :year_range])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
  end
end
