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
    # field :source, Backend.MastersTour.InvitedPlayer.SourceType, default: :official
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
    String.trim(ip.battletag_full) <> ip.tour_stop
  end
end

defmodule Backend.MastersTour.InvitedPlayer.SourceType do
  @moduledoc """
  Ecto type for the source field
  """
  @behaviour Ecto.Type

  @type source :: :official | :unofficial | :other_ladder
  @spec cast(InvitedPlayer.source() | atom) :: bool
  def is_valid_source?(source) when is_atom(source) do
    [:official, :unofficial, :other_ladder] |> Enum.any?(fn s -> s == source end)
  end

  def type, do: :string

  @spec cast(InvitedPlayer.source() | atom) :: {:ok, InvitedPlayer.source()}
  def cast(atom_source) when is_atom(atom_source) do
    if is_valid_source?(atom_source) do
      {:ok, Atom.to_string(atom_source)}
    else
      :error
    end
  end

  def cast(_) do
    :error
  end

  def load(string_source) when is_binary(string_source) do
    String.to_existing_atom(string_source)
  end

  def dump(casted) when is_atom(casted) do
    {:ok, Atom.to_string(casted)}
  end

  def dump(_) do
    :error
  end
end
