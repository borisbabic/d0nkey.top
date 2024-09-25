defmodule Backend.Repo.Migrations.CardTallyKeptIndexForAdvancedStats do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    """
    CREATE INDEX CONCURRENTLY IF NOT EXISTS dt_card_game_tally_card_id_kept ON dt_card_game_tally (
      card_id,
      kept
    );
    """
    |> execute()
  end
  def down do
    """
    DROP INDEX CONCURRENTLY IF EXISTS dt_card_game_tally_card_id_kept;
    """
    |> execute()
  end
end
