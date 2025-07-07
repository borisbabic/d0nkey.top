defmodule Backend.Repo.Migrations.AddDefaultSheetToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :default_sheet_id, references(:deck_sheets)
      add :default_sheet_source, :string, default: "hsguru"
    end
  end
end
