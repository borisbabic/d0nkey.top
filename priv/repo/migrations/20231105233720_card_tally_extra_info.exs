defmodule Backend.Repo.Migrations.CardTallyExtraInfo do
  use Ecto.Migration

  def change do
    alter table(:dt_card_game_tally) do
      add :deck_id, references(:deck, on_delete: :delete_all), null: true
      add :inserted_at, :naive_datetime, null: true
    end
  end
end
