defmodule Backend.UserManager.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :battletag, :string
    field :bnet_id, :integer
    field :battlefy_slug, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:battletag, :bnet_id, :battlefy_slug])
    |> validate_required([:battletag, :bnet_id])
    |> unique_constraint(:bnet_id)
  end

  def display_name(%__MODULE__{battletag: bt}),
    do: bt |> Backend.MastersTour.InvitedPlayer.shorten_battletag()
end
