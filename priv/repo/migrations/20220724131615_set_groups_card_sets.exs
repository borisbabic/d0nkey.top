defmodule Backend.Repo.Migrations.SetGroupsCardSets do
  use Ecto.Migration

  def change do
    alter table(:hs_set_groups) do
      add :card_sets, {:array, :string}, default: []
    end
  end
end
