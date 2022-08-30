defmodule Backend.Repo.Migrations.CreateLeaderboardsSeasons do
  use Ecto.Migration

  def change do
    create table(:leaderboards_seasons) do
      add :season_id, :integer
      add :leaderboard_id, :string
      add :region, :string

      timestamps()
    end

    create unique_index(:leaderboards_seasons, [:leaderboard_id, :region, :season_id])
  end
end
