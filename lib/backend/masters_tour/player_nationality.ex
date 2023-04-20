defmodule Backend.MastersTour.PlayerNationality do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @required [:mt_battletag_full, :tour_stop, :nationality]
  @optional [:actual_battletag_full, :twitch]
  schema "mt_player_nationality" do
    field :mt_battletag_full, :string
    field :tour_stop, :string
    field :nationality, :string
    field :actual_battletag_full, :string, default: nil
    field :twitch, :string, default: nil
    timestamps()
  end

  @doc false
  def changeset(cs, attrs) do
    cs
    |> cast(attrs, @required ++ @optional)
    |> update_change(:actual_battletag_full, &String.trim/1)
    |> update_change(:mt_battletag_full, &String.trim/1)
    |> validate_required(@required)
  end
end
