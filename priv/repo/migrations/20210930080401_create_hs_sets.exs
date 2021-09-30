defmodule Backend.Repo.Migrations.CreateHsSets do
  use Ecto.Migration

  def change do
    create table(:hs_sets, primary_key: false) do
      add :id, :integer, primary_key: true
      add :name, :string
      add :slug, :string
      add :collectible_count, :integer
      add :collectible_revealed_count, :integer
      add :non_collectible_count, :integer
      add :non_collectible_revelead_count, :integer, null: true
      add :type, :string

      timestamps()
    end
  end
end
