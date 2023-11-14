defmodule Backend.Repo.Migrations.RemoveRecursiveAggStatsRefresh do
  use Ecto.Migration

  def up do
    execute("DROP EVENT TRIGGER IF EXISTS recursive_aggregation_refresh")
    execute("DROP FUNCTION IF EXISTS recursive_aggregation_refresh")
  end

  def down do
  end
end
