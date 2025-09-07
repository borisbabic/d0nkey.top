defmodule Backend.Leaderboards.Season do
  use Ecto.Schema
  import Ecto.Changeset
  @type t :: %__MODULE__{}

  schema "leaderboards_seasons" do
    field :leaderboard_id, :string
    field :region, :string
    field :season_id, :integer
    field :total_size, :integer, default: nil

    timestamps()
  end

  @doc false
  def changeset(season, attrs) do
    season
    |> cast(attrs, [:season_id, :leaderboard_id, :region, :total_size])
    |> validate_required([:season_id, :leaderboard_id, :region])
  end

  @spec uniq_string(t() | Hearthstone.Leaderboards.Season.t()) :: String.t()
  def uniq_string(season) do
    "#{season.leaderboard_id}_#{season.season_id}_#{season.region}"
  end
end
