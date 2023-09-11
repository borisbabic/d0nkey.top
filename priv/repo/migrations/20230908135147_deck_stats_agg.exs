defmodule Backend.Repo.Migrations.DeckStatsAgg do
  use Ecto.Migration

  def change do
    create table(:dt_deck_stats) do
      add :deck_id, references(:deck, on_delete: :delete_all), null: false
      add :wins, :integer, null: false
      add :losses, :integer, null: false
      add :total, :integer, null: false
      add :winrate, :float, null: false
      add :hour_start, :utc_datetime, null: false
      add :rank, :string, null: false
      add :opponent_class, :string, null: false
      timestamps(updated_at: false)
    end

    create unique_index(:dt_deck_stats, [:hour_start, :deck_id, :rank, :opponent_class])
  end
end
