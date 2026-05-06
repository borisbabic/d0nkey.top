defmodule Backend.Repo.Migrations.AddSetAltSlug do
  use Ecto.Migration

  def change do
    alter table(:hs_sets) do
      add :alt_slug, :string, default: nil, null: true
    end
  end
end
