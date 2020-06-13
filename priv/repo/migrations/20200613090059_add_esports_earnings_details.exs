defmodule Backend.Repo.Migrations.AddEsportsEarningsDetails do
  use Ecto.Migration

  def change do
    create table(:ee_player_details) do
      add :game_id, :integer, null: false
      add :player_details, {:array, :map}, default: []
      timestamps()
    end
  end
end
