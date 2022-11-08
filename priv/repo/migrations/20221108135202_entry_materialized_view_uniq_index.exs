defmodule Backend.Repo.Migrations.EntryMaterializedViewUniqIndex do
  use Ecto.Migration

  def change do
    create(unique_index(:leaderboards_entry_latest, [:rank, :season_id, :inserted_at]))
  end
end
