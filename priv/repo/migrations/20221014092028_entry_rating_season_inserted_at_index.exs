defmodule Backend.Repo.Migrations.EntryRatingSeasonInsertedAtIndex do
  use Ecto.Migration

  def change do
    create index(:leaderboards_entry, [:rank, :season_id, :inserted_at])
  end
end
