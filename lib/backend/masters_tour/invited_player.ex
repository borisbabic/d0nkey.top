defmodule Backend.MastersTour.InvitedPlayer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invited_player" do
    field :battletag_full, :string
    field :tour_stop, :string
    field :type, :string
    field :reason, :string

    timestamps()
  end

  @doc false
  def changeset(invited, attrs) do
    invited
    |> cast(attrs, [:battletag_full, :tour_stop])
    |> validate_required([:battletag_full, :tour_stop])
  end
end
