defmodule Backend.Repo.Migrations.CreateDeckInteractions do
  use Ecto.Migration

  def change do
    create table(:deck_interactions) do
      add :copied, :integer
      add :expanded, :integer
      add :period_start, :utc_datetime, primary_key: true
      add :deck_id, references(:deck, on_delete: :nothing), primary_key: true

      timestamps()
    end

    create(index(:deck_interactions, [:deck_id]))
    create(index(:deck_interactions, [:period_start]))

    create(
      unique_index(:deck_interactions, [:deck_id, :period_start],
        name: :deck_interaction_unique_index
      )
    )
  end
end
