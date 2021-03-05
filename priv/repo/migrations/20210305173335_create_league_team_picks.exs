defmodule Backend.Repo.Migrations.CreateLeagueTeamPicks do
  use Ecto.Migration

  def change do
    create table(:league_team_picks) do
      add :pick, :string
      add :team_id, references(:league_teams, on_delete: :nothing)

      timestamps()
    end

    create index(:league_team_picks, [:team_id])
  end
end
