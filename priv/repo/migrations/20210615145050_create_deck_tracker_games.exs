defmodule Backend.Repo.Migrations.CreateDeckTrackerGames do
  use Ecto.Migration

  def change do
    create(table(:dt_games)) do
      add :player_btag, :string, null: false
      # changed to nullable in  future migration
      add :player_rank, :integer, null: false
      add :player_legend_rank, :integer, null: true
      add :player_deck_id, references(:deck, on_delete: :delete_all), null: true

      add :opponent_btag, :string, null: false
      # changed to nullable in  future migration
      add :opponent_rank, :integer, null: false
      add :opponent_legend_rank, :integer, null: true
      add :opponent_deck_id, references(:deck, on_delete: :delete_all), null: true

      add :game_id, :string, null: false
      add :game_type, :integer, null: false
      add :format, :integer, null: false
      add :status, :string, null: false
      add :region, :string, null: false
      add :duration, :integer, null: true
      add :turns, :integer, null: true

      add :created_by_id, references(:api_users, on_delete: :nothing), null: true
    end

    create(index(:dt_games, [:player_btag]))
    create(unique_index(:dt_games, [:game_id]))
  end
end
