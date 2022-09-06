defmodule Backend.Repo.Migrations.EntryGroupByIndex do
  use Ecto.Migration

  def change do
    create index(:leaderboards_entry, [:rank, :season_id])
  end
end
