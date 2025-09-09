defmodule Backend.Repo.Migrations.AddBuggedSources do
  use Ecto.Migration

  def change do
    create table(:dt_bugged_sources) do
      add :filter_out, :boolean, default: true
      add :source_id, references(:dt_sources, on_delete: :delete_all), null: true
      timestamps()
    end
  end
end
