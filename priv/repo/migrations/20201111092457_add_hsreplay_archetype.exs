defmodule Backend.Repo.Migrations.AddHsreplayArchetype do
  use Ecto.Migration

  def change do
    alter table(:deck) do
      add :hsreplay_archetype, :integer, null: true
    end
  end
end
