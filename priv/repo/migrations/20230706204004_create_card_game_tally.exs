defmodule Backend.Repo.Migrations.CreateCardGameTally do
  use Ecto.Migration

  def change do
    create table("dt_card_game_tally") do
      add :game_id, references(:dt_games, on_delete: :nothing), null: false
      add :card_id, :integer, null: false
      add :drawn, :boolean, default: true
      add :turn, :integer, default: 0
      add :mulligan, :boolean, default: true
      add :kept, :boolean, default: true
    end
  end
end
