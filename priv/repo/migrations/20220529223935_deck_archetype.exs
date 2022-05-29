defmodule Backend.Repo.Migrations.DeckArchetype do
  use Ecto.Migration

  def change do
    alter(table(:deck)) do
      add :archetype, :string, default: nil
    end
  end
end
