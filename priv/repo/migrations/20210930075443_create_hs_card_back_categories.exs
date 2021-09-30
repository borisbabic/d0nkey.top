defmodule Backend.Repo.Migrations.CreateHsCardBackCategories do
  use Ecto.Migration

  def change do
    create table(:hs_card_back_categories) do
      add :name, :string
      add :slug, :string

      timestamps()
    end
  end
end
