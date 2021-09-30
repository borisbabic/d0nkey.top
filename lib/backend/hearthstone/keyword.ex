defmodule Backend.Hearthstone.Keyword do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  schema "hs_keywords" do
    field :game_modes, {:array, :integer}
    field :name, :string
    field :ref_text, :string
    field :slug, :string
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(keyword, %Hearthstone.Metadata.Keyword{} = struct) do
    attrs = Map.from_struct(struct)

    keyword
    |> cast(attrs, [:id, :name, :slug, :game_modes, :ref_text, :text])
    |> validate_required([:id, :name, :slug, :game_modes, :ref_text, :text])
  end
end
