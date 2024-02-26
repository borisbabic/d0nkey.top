defmodule Backend.Repo.Migrations.CreatePatreonTiers do
  use Ecto.Migration

  def change do
    create table(:patreon_tiers, primary_key: false) do
      add :id, :string, primary_key: true
      add :title, :string
      add :ad_free, :boolean, default: false, null: false

      timestamps()
    end
  end
end
