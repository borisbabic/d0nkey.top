defmodule Backend.Repo.Migrations.AddTimestampsToListings do
  use Ecto.Migration

  def change do
    alter table(:deck_sheet_listings) do
      timestamps(null: true)
    end
  end
end
