defmodule Backend.Repo.Migrations.CreateLeaderboardsSeasonSizes do
  use Ecto.Migration

  def change do
    create table(:leaderboards_season_sizes) do
      add :season_id, references(:leaderboards_seasons, on_delete: :delete_all), null: false
      add :total_size, :integer, null: false
      add :inserted_at, :naive_datetime, null: false, default: fragment("now()")
    end

    create index(:leaderboards_season_sizes, [:season_id, :inserted_at])

    execute """
            INSERT INTO leaderboards_season_sizes (season_id, total_size, inserted_at)
            SELECT id, total_size, COALESCE(updated_at, inserted_at, NOW())
            FROM leaderboards_seasons
            WHERE total_size IS NOT NULL AND total_size > 0;
            """,
            ""
  end
end
