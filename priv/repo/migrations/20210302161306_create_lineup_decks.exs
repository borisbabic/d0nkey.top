defmodule Backend.Repo.Migrations.CreateLineupDecks do
  use Ecto.Migration

  def change do
    create table(:lineup_decks) do
      add :lineup_id, references(:lineups, on_delete: :nothing)
      add :deck_id, references(:deck, on_delete: :nothing)
    end

    create(unique_index(:lineup_decks, [:lineup_id, :deck_id], name: :lineup_deck))
  end
end
