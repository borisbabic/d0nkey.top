defmodule Backend.Repo.Migrations.CreateHsFactions do
  use Ecto.Migration

  def change do
    create table(:hs_factions) do
      add :name, :string
      add :slug, :string

      timestamps()
    end
  end
end
