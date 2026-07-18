defmodule Backend.Repo.Migrations.AddPremiumOnlyToRanks do
  use Ecto.Migration

  def change do
    alter table(:ranks) do
      add :premium_only, :boolean, default: false, null: false
    end
  end
end
