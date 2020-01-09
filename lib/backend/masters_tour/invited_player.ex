defmodule Backend.MastersTour.InvitedPlayer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invited_player" do
    field :battletag_full, :string
    field :tour_stop, :string
    field :type, :string
    field :reason, :string
    field :upstream_time, :utc_datetime
    field :tournament_slug, :string
    field :tournament_id, :string

    timestamps()
  end

  @doc false
  def changeset(invited, attrs) do
    invited
    |> cast(attrs, [
      :battletag_full,
      :tour_stop,
      :type,
      :reason,
      :upstream_time,
      :tournament_slug,
      :tournament_id
    ])
    |> validate_required([:battletag_full, :tour_stop, :upstream_time])
  end

  def shorten_battletag(battletag_full) do
    battletag_full
    |> String.splitter("#")
    |> Enum.at(0)
    |> to_string()
  end
end
