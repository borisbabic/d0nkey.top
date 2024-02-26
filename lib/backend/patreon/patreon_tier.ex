defmodule Backend.Patreon.PatreonTier do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}
  schema "patreon_tiers" do
    field :ad_free, :boolean, default: false
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(patreon_tier, attrs) do
    patreon_tier
    |> cast(attrs, [:id, :title, :ad_free])
    |> validate_required([:id, :title, :ad_free])
  end
end
