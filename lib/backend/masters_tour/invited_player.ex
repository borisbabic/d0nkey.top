defmodule Backend.MastersTour.InvitedPlayer do
  @moduledoc false
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
    |> update_change(:battletag_full, &String.trim/1)
    |> validate_required([:battletag_full, :tour_stop, :upstream_time])
  end

  @spec shorten_battletag(Backend.Blizzard.battletag()) :: String.t()
  def shorten_battletag(battletag_full) do
    battletag_full
    # some in the db still have it, meh, don't feel like changing it
    |> String.trim()
    |> String.splitter("#")
    |> Enum.at(0)
    |> to_string()
  end

  @spec uniq_string(InvitedPlayer.t()) :: String.t()
  def uniq_string(ip) do
    String.trim(ip.battletag_full) <> ip.tour_stop
  end
end
