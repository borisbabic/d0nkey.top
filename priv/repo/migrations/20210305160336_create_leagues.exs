defmodule Backend.Repo.Migrations.CreateLeagues do
  use Ecto.Migration

  def change do
    create table(:leagues) do
      add :name, :string, null: false
      add :competition, :string, null: false
      add :competition_type, :string, null: false
      add :point_system, :string, null: false
      add :max_teams, :integer, null: false
      add :roster_size, :integer, null: false
      add :owner_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:leagues, [:owner_id])
  end
end
