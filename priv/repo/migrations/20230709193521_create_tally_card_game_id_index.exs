defmodule Backend.Repo.Migrations.CreateTallyCardGameIdIndex do
  use Ecto.Migration
  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create_if_not_exists index(:dt_card_game_tally, [:card_id, :game_id], concurrently: true)
  end
end
