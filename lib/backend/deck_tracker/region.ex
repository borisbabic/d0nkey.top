defmodule Hearthstone.DeckTracker.Region do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dt_regions" do
    field :auto_aggregate, :boolean, default: false
    field :code, :string
    field :display, :string

    timestamps()
  end

  @doc false
  def changeset(region, attrs) do
    region
    |> cast(attrs, [:code, :display, :auto_aggregate])
    |> validate_required([:code, :display, :auto_aggregate])
  end
end
