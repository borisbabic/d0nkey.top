defmodule Backend.Repo.Migrations.AddCardMapToCollection do
  use Ecto.Migration

  def change do
    alter table(:hs_collections) do
      add :card_map, :map, []
      add :card_map_updated_at, :naive_datetime
    end
  end
end
