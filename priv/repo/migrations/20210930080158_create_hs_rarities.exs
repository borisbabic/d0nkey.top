defmodule Backend.Repo.Migrations.CreateHsRarities do
  use Ecto.Migration

  def change do
    create table(:hs_rarities) do
      add :name, :string
      add :slug, :string
      add :dust_value, {:array, :integer}
      add :crafting_cost, {:array, :integer}
      add :normal_dust_value, :integer
      add :gold_dust_value, :integer
      add :normal_crafting_cost, :integer
      add :gold_crafting_cost, :integer

      timestamps()
    end
  end
end
