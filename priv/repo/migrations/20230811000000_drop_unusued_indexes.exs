defmodule Backend.Repo.Migrations.DropUnusuedIndexes do
  use Ecto.Migration

  def change do
    drop_if_exists index("leaderboards_entry", [:rank, :season_id])
    drop_if_exists index("leaderboards_entry", [:season_id, :rank])
    drop_if_exists index("leaderboards_entry", [:season_id])
  end
end
