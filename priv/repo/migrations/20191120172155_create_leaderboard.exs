defmodule Backend.Repo.Migrations.CreateLeaderboard do
  use Ecto.Migration

  def change do
    create table(:leaderboard) do
      add :season_id, :string
      add :upstream_id, :integer, null: false
      add :start_date, :utc_datetime, null: true
      add :leaderboard_id, :string, null: false
      add :region, :string

      timestamps()
    end

  end
end
