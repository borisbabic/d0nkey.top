defmodule Backend.Repo.Migrations.EntryRatingDecimal do
  use Ecto.Migration

  def change do
    alter table(:leaderboards_entry) do
      modify :rating, :float
    end
  end
end
