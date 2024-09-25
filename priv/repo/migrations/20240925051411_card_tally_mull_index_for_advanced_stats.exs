defmodule Backend.Repo.Migrations.CardTallyMullIndexForAdvancedStats do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    """
    CREATE INDEX CONCURRENTLY IF NOT EXISTS dt_card_game_tally_card_id_mulligan ON dt_card_game_tally (
      mulligan,
      card_id
    );
    """
    |> execute()
  end
  def down do
    """
    DROP INDEX CONCURRENTLY IF EXISTS dt_card_game_tally_card_id_mulligan;
    """
    |> execute()
  end
end
