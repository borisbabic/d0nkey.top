defmodule Backend.Leaderboards.SeasonSize do
  @moduledoc """
  Schema representing a total size snapshot of a leaderboard season over time.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Leaderboards.Season

  schema "leaderboards_season_sizes" do
    field :total_size, :integer
    belongs_to :season, Season

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(season_size, attrs) do
    season_size
    |> cast(attrs, [:total_size, :season_id, :inserted_at])
    |> validate_required([:total_size, :season_id])
  end
end
