defmodule Backend.Repo.Migrations.CardTallyDeckIdInsertedAtIndex do
  use Ecto.Migration
  @disable_migration_lock true

  def change do
    create_if_not_exists index(:dt_card_game_tally, [:inserted_at, :deck_id], concurrently: false)
  end
end
