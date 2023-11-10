defmodule Backend.Repo.Migrations.CardTallyGameIdIndex do
  use Ecto.Migration
  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create_if_not_exists index(:dt_card_game_tally, [:game_id], concurrently: true)
  end
end
