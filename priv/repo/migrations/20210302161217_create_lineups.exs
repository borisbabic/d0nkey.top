defmodule Backend.Repo.Migrations.CreateLineups do
  use Ecto.Migration

  def change do
    create table(:lineups) do
      add :tournament_id, :string
      add :tournament_source, :string
      add :name, :string

      timestamps()
    end

    create(
      unique_index(:lineups, [:tournament_id, :tournament_source, :name], name: :lineup_uniq_index)
    )
  end
end
