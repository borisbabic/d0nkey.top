defmodule Backend.Hearthstone.GameMode do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}
  schema "hs_game_modes" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(game_mode, %Hearthstone.Metadata.GameMode{} = struct) do
    attrs = Map.from_struct(struct)

    game_mode
    |> cast(attrs, [:id, :name, :slug])
    |> validate_required([:id, :name, :slug])
  end
end
