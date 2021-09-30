defmodule Backend.Repo.Migrations.CreateHsMinionTypes do
  use Ecto.Migration

  def change do
    create table(:hs_minion_types) do
      add :name, :string
      add :slug, :string
      add :game_modes, {:array, :integer}

      timestamps()
    end
  end
end
