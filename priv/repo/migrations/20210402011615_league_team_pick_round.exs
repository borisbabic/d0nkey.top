defmodule Backend.Repo.Migrations.LeagueTeamPickRound do
  use Ecto.Migration

  def change do
    alter table("league_team_picks") do
      add :round, :integer, null: false, default: 1
    end
  end
end
