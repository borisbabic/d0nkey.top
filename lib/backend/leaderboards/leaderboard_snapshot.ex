defmodule Backend.Leaderboards.LeaderboardSnapshot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "leaderboard_snapshot" do
    belongs_to :leaderboard, Backend.Leaderboards.Leaderboard
    timestamps()
  end

  @doc false
  def changeset(leaderboard_snapshot, attrs) do
    leaderboard_snapshot
    |> cast(attrs, [])
    |> validate_required([])
  end
end
