defmodule Backend.Repo.Migrations.EntriesGroupBySeasonRankIndexActual do
  use Ecto.Migration

  def change do
    create index(:leaderboards_entry, [:season_id, :rank])
  end
end
