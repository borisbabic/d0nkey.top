defmodule Backend.Leaderboards.LeaderboardEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "leaderboard_entry" do
    field :battletag, :string
    field :position, :integer
    field :rating, :integer
    belongs_to :snapshot, Backend.Leaderboards.LeaderboardSnapshot

    timestamps()
  end

  @doc false
  def changeset(leaderboard_entry, attrs) do
    leaderboard_entry
    |> cast(attrs, [:battletag, :position, :rating])
    |> validate_required([:battletag, :position])
  end
end
