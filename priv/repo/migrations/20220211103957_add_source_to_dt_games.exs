defmodule Backend.Repo.Migrations.AddSourceToDtGames do
  use Ecto.Migration

  def change do
    alter(table(:dt_games)) do
      add :source_id, references(:dt_sources, on_delete: :nothing), null: true
    end

  end
end
