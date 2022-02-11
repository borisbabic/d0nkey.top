defmodule Backend.Repo.Migrations.DtSource do
  use Ecto.Migration

  def change do
    create table(:dt_sources) do
      add :source, :string, null: false
      add :version, :string, null: false

      timestamps()
    end
    create(unique_index(:dt_sources, [:source, :version], name: :dt_source_source_version))
  end
end
