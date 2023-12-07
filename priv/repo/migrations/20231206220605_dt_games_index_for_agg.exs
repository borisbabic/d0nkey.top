defmodule Backend.Repo.Migrations.DtGamesIndexForAgg do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    """
    CREATE INDEX CONCURRENTLY IF NOT EXISTS dt_games_agg_query ON dt_games (
      game_type,
      inserted_at,
      COALESCE(player_deck_id, -1),
      COALESCE(opponent_class, 'any')
    );
    """
    |> execute()
  end

  def down do
    "DROP INDEX CONCURRENTLY IF EXISTS dt_games_agg_query; "
    |> execute()
  end
end
