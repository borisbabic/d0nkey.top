defmodule Hearthstone.DeckTracker.Source do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dt_sources" do
    field :source, :string
    field :version, :string
    timestamps()
  end

  @doc false
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:source, :version])
    |> validate_required([:source, :version])
    |> unique_constraint([:source, :version], name: :dt_source_source_version)
  end
end
