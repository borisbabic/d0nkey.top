defmodule Backend.Repo.Migrations.CardTallyDrawnIndexForAdvancedStats do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    """
    CREATE INDEX CONCURRENTLY IF NOT EXISTS dt_card_game_tally_card_id_drawn ON dt_card_game_tally (
      drawn,
      card_id
    );
    """
    |> execute()
  end
  def down do
    """
    DROP INDEX CONCURRENTLY IF EXISTS dt_card_game_tally_card_id_drawn;
    """
    |> execute()
  end
end
