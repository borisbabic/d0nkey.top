defmodule Backend.Repo.Migrations.CreateHsGameModes do
  use Ecto.Migration

  def change do
    create table(:hs_game_modes) do
      add :name, :string
      add :slug, :string

      timestamps()
    end
  end
end
