defmodule Backend.UserManager.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :battletag, :string
    field :bnet_id, :integer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:battletag, :bnet_id])
    |> validate_required([:battletag, :bnet_id])
    |> unique_constraint(:bnet_id)
  end
end
