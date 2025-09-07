defmodule Backend.Repo.Migrations.AddTotalSizeToSeason do
  use Ecto.Migration

  def change do
    alter table(:leaderboards_seasons) do
      add :total_size, :integer, default: nil
    end
  end
end
