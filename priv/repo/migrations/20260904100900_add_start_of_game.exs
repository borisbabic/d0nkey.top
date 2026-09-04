defmodule Backend.Repo.Migrations.AddStartOfGame do
  use Ecto.Migration

  def change do
    alter table(:dt_game_played_cards) do
      add :player_start_of_game, {:array, :integer}, default: []
      add :opponent_start_of_game, {:array, :integer}, default: []
    end
  end
end
