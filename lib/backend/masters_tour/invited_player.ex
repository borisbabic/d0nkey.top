defmodule Backend.MastersTour.InvitedPlayer do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @type source :: :official | :unofficial | :other_ladder

  schema "invited_player" do
    field :battletag_full, :string
    field :tour_stop, :string
    field :type, :string
    field :reason, :string
    field :upstream_time, :utc_datetime
    field :tournament_slug, :string
    field :tournament_id, :string
    field :official, :boolean, default: true
    timestamps()
  end

  @doc false
  def changeset(invited, attrs) do
    invited
    |> cast(
      attrs,
      [
        :battletag_full,
        :tour_stop,
        :type,
        :reason,
        :upstream_time,
        :tournament_slug,
        :official,
        :tournament_id
      ]
    )
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
    String.trim(ip.battletag_full) <> ip.tour_stop <> to_string(ip.official)
  end

  @doc """
  Uniques the players for each tour while prioritizing by source
  """
  @spec prioritize([InvitedPlayer.t()]) :: [InvitedPlayer.t()]
  def prioritize(invited_players) do
    prioritize(invited_players, &Util.id/1)
  end

  def prioritize(invited_players, transform_battletag) do
    sort = fn first, second -> first.official && !second.official end

    invited_players
    |> Enum.group_by(fn ip -> ip.tour_stop end)
    |> Enum.flat_map(fn {_, tsg} ->
      tsg
      |> Enum.group_by(fn ip -> transform_battletag.(ip.battletag_full) end)
      |> Enum.map(fn {_, ips} ->
        ips
        |> Enum.sort(sort)
        |> Enum.at(0)
      end)
    end)
  end

  @doc """
  Uniques the players for each tour while prioritizing by source
  """
  @spec source(InvitedPlayer.t()) :: source
  def source(%__MODULE__{official: official}) do
    if official do
      :official
    else
      :unofficial
    end
  end
end
