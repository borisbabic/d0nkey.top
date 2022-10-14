defmodule Backend.Repo.Migrations.DropLeaderboardsEntryUpdatedAt do
  use Ecto.Migration

  def change do
    alter table(:leaderboards_entry) do
      remove :updated_at
    end
  end
end
