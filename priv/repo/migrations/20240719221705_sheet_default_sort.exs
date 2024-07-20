defmodule Backend.Repo.Migrations.SheetDefaultSort do
  use Ecto.Migration

  def change do
    alter table(:deck_sheets) do
      add :default_sort, :string, default: "asc_inserted_at"
    end
  end
end
