defmodule Backend.Repo.Migrations.IncreasedSheetListingComment do
  use Ecto.Migration

  def change do
    alter table(:deck_sheet_listings) do
      modify :comment, :string, size: 4096
    end
  end
end
