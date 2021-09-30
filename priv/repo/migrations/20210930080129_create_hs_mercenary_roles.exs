defmodule Backend.Repo.Migrations.CreateHsMercenaryRoles do
  use Ecto.Migration

  def change do
    create table(:hs_mercenary_roles) do
      add :name, :string
      add :slug, :string

      timestamps()
    end
  end
end
