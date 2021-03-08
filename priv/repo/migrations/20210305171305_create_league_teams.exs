defmodule Backend.Repo.Migrations.CreateLeagueTeams do
  use Ecto.Migration

  def change do
    create table(:league_teams) do
      add :owner_id, references(:users, on_delete: :nothing), null: false
      add :league_id, references(:leagues, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:league_teams, [:owner_id])
    create index(:league_teams, [:league_id])
  end
end
