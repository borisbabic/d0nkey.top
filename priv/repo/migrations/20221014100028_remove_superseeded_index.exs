defmodule Backend.Repo.Migrations.RemoveSuperseededIndex do
  use Ecto.Migration

  def change do
    drop index(:leaderboards_entry, [:rank, :season_id])
  end
end
