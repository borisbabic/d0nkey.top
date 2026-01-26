defmodule Backend.Repo.Migrations.CompareToLeaderboardsIndex do
  use Ecto.Migration
  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    execute(
      "CREATE INDEX CONCURRENTLY IF NOT EXISTS leaderboards_season_id_account_id_inserted_at_rank_index  ON leaderboards_entry (season_id, account_id, inserted_at, rank) INCLUDE (rating)"
    )
  end

  def down do
    execute(
      "DROP INDEX CONCURRENTLY IF EXISTS leaderboards_season_id_account_id_inserted_at_rank_index"
    )
  end
end
