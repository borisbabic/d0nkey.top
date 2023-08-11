defmodule Backend.Repo.Migrations.LeaderboardsEntryCurrent do
  use Ecto.Migration

  def change do
    create table(:leaderboards_current_entries) do
      add :rank, :integer
      add :account_id, :string
      add :rating, :float, default: nil
      add :season_id, references(:leaderboards_seasons, on_delete: :nothing)
      timestamps(updated_at: false)
    end

    create unique_index(:leaderboards_current_entries, [:season_id, :rank])
  end
end
