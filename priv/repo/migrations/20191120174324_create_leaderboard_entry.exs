defmodule Backend.Repo.Migrations.CreateLeaderboardEntry do
  use Ecto.Migration

  def change do
    create table(:leaderboard_entry) do
      add :battletag, :string, null: false
      add :position, :integer, null: false
      add :rating, :integer, null: true
      add :snapshot_id, references(:leaderboard_snapshot, on_delete: :nothing)

      timestamps()
    end

    create index(:leaderboard_entry, [:snapshot_id])
  end
end
