defmodule Backend.Repo.Migrations.CreateLeaderboardsEntry do
  use Ecto.Migration

  def change do
    create table(:leaderboards_entry) do
      add :rank, :integer
      add :account_id, :string, default: nil
      add :rating, :integer
      add :season_id, references(:leaderboards_seasons, on_delete: :nothing)

      timestamps()
    end

    create index(:leaderboards_entry, [:season_id])
    create index(:leaderboards_entry, [:account_id])
  end
end
