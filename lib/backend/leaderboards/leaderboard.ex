defmodule Backend.Leaderboards.Leaderboard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "leaderboard" do
    field :leaderboard_id, :string
    field :region, :string
    field :season_id, :string
    field :start_date, :utc_datetime
    field :upstream_id, :integer

    timestamps()
  end

  @doc false
  def changeset(leaderboard, attrs) do
    leaderboard
    |> cast(attrs, [:season_id, :leaderboard_id, :region, :upstream_id, :start_date])
    |> validate_required([:season_id, :leaderboard_id, :region, :upstream_id, :start_date])
  end
end
