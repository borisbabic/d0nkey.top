defmodule Backend.Repo.Migrations.DeckSheetListing do
  use Ecto.Migration

  def change do
    create table(:deck_sheet_listings) do
      add :deck_id, references(:deck, on_delete: :delete_all), null: false
      add :sheet_id, references(:deck_sheets, on_delete: :delete_all), null: false
      add :name, :string, null: true
      add :comment, :string, null: true
      add :source, :string, null: true
      add :extra_columns, :map, default: %{}
    end
  end
end
