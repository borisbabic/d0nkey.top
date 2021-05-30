defmodule Backend.GMStream.Stream do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gm_streams" do
    field :stream, :string
    field :stream_id, :string

    timestamps()
  end

  @doc false
  def changeset(stream, attrs) do
    stream
    |> cast(attrs, [:stream_id, :stream])
    |> validate_required([:stream_id, :stream])
  end
end
