defmodule Backend.Repo.Migrations.PlayedCardsGameIdIndex do
  use Ecto.Migration
  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create_if_not_exists index(:dt_game_played_cards, [:game_id], concurrently: true)
  end
end
