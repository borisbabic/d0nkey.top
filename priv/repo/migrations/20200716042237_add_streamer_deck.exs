defmodule Backend.Repo.Migrations.AddStreamerDeck do
  use Ecto.Migration

  def change do
    create table(:streamer_deck, primary_key: false) do
      add :streamer_id, references(:streamer, on_delete: :delete_all), primary_key: true
      add :deck_id, references(:deck, on_delete: :delete_all), primary_key: true
      add :best_rank, :integer, null: false
      add :best_legend_rank, :integer, null: false
      add :first_played, :utc_datetime, null: false
      add :last_played, :utc_datetime, null: false
      timestamps()
    end

    create(index(:streamer_deck, [:deck_id]))
    create(index(:streamer_deck, [:streamer_id]))

    create(
      unique_index(:streamer_deck, [:deck_id, :streamer_id], name: :streamer_deck_unique_index)
    )
  end
end
