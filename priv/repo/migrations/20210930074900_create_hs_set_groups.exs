defmodule Backend.Repo.Migrations.CreateSetGroups do
  use Ecto.Migration

  def change do
    create table(:hs_set_groups) do
      add :name, :string
      add :slug, :string
      add :icon, :string, null: true
      add :standard, :boolean, default: false, null: true
      add :svg, :string, null: true
      add :year, :integer, null: true
      add :year_range, :string, null: true

      timestamps()
    end

    create unique_index(:hs_set_groups, [:slug])
  end
end
