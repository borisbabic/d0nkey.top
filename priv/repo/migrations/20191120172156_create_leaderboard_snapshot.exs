defmodule Backend.Repo.Migrations.CreateLeaderboardSnapshot do
  use Ecto.Migration

  def change do
    create table(:leaderboard_snapshot) do
      add :leaderboard_id, references(:leaderboard, on_delete: :nothing)

      timestamps()
    end

    create index(:leaderboard_snapshot, [:leaderboard_id])
  end
end
