defmodule Backend.Repo.Migrations.CreateHsSpellSchools do
  use Ecto.Migration

  def change do
    create table(:hs_spell_schools) do
      add :name, :string
      add :slug, :string

      timestamps()
    end
  end
end
