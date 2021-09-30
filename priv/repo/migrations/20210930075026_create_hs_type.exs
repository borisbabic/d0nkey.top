defmodule Backend.Repo.Migrations.CreateHsType do
  use Ecto.Migration

  def change do
    create table(:hs_type) do
      add :name, :string
      add :slug, :string
      add :game_modes, {:array, :integer}

      timestamps()
    end
  end
end
