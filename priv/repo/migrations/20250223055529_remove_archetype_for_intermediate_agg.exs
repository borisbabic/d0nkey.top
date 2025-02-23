defmodule Backend.Repo.Migrations.RemoveArchetypeForIntermediateAgg do
  use Ecto.Migration

  def change do
    alter table(:dt_intermediate_agg_stats) do
      remove :archetype
    end
  end
end
