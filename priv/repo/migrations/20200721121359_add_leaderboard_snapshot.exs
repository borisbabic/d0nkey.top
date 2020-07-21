defmodule Backend.Repo.Migrations.AddLeaderboardSnapshot do
  use Ecto.Migration

  def change do
    create table(:leaderboard_snapshot) do
      add :upstream_updated_at, :utc_datetime
      add :season_id, :integer, null: false
      add :leaderboard_id, :string, null: false
      add :region, :string, null: false
      add :entries, {:array, :map}, default: []
      timestamps()
    end

    create(
      unique_index(
        :leaderboard_snapshot,
        [
          :upstream_updated_at,
          :season_id,
          :leaderboard_id,
          :region
        ],
        name: :snapshot_unique_index
      )
    )
  end
end
