defmodule Backend.Repo.Migrations.LineupDecksDeleteAll do
  use Ecto.Migration

  def change do
    drop constraint(:lineup_decks, :lineup_decks_lineup_id_fkey)

    alter table(:lineup_decks) do
      modify(:lineup_id, references(:lineups, on_delete: :delete_all))
    end
  end
end
