defmodule Backend.Repo.Migrations.AddGameModeToFormat do
  use Ecto.Migration

  def change do
    alter table(:formats) do
      add :game_type, :integer, default: 7
    end
  end
end
