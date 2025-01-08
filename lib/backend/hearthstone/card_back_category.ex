defmodule Backend.Hearthstone.CardBackCategory do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}
  schema "hs_card_back_categories" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(card_back_category, %Hearthstone.Metadata.CardBackCategory{} = struct) do
    attrs = Map.from_struct(struct)

    card_back_category
    |> cast(attrs, [:id, :name, :slug])
    |> validate_required([:id, :name, :slug])
  end
end
