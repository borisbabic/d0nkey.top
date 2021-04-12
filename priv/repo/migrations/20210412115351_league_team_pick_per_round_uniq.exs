defmodule Backend.Repo.Migrations.LeagueTeamPickPerRoundUniq do
  use Ecto.Migration

  def change do
    drop(
      unique_index(:league_team_picks, [:pick, :team_id],
        name: :league_team_picks_league_team_pick_uniq
      )
    )

    create(
      unique_index(:league_team_picks, [:pick, :team_id, :round],
        name: :league_team_picks_league_team_pick_round_uniq
      )
    )
  end
end
