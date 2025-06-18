defmodule Backend.Repo.Migrations.AddCollection do
  use Ecto.Migration

  def change do
    create table(:hs_collections, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :region, :string
      add :battletag, :string
      add :public, :boolean, default: false
      add :update_received, :naive_datetime
      add :cards, :map, []
    end

    create(
      unique_index(:hs_collections, [:battletag, :region],
        name: :collection_battletag_region_unique_index
      )
    )
  end
end
