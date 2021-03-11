defmodule Backend.Repo.Migrations.LeagueTeamPickUniqueness do
  use Ecto.Migration

  def change do
    create(
      unique_index(:league_team_picks, [:pick, :team_id],
        name: :league_team_picks_league_team_pick_uniq
      )
    )
  end
end
