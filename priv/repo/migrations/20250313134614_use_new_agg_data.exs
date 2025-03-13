defmodule Backend.Repo.Migrations.UseNewAggData do
  use Ecto.Migration

  def up do
    sql = """
    DO $$
    BEGIN
      ALTER MATERIALIZED VIEW IF EXISTS dt_aggregated_stats RENAME to mv_dt_aggregated_stats;
      ALTER TABLE IF EXISTS dt_aggregation_meta RENAME to mv_dt_aggregation_meta;
      ALTER TABLE IF EXISTS test_dt_aggregation_meta RENAME to dt_aggregation_meta;
      ALTER TABLE IF EXISTS test_dt_aggregated_stats RENAME TO dt_aggregated_stats;
    END $$;
    """

    execute sql
  end

  def down do
    sql = """
    DO $$
    BEGIN
      ALTER TABLE IF EXISTS dt_aggregation_meta RENAME to test_dt_aggregation_meta;
      ALTER TABLE IF EXISTS dt_aggregated_stats RENAME TO test_dt_aggregated_stats;
      ALTER MATERIALIZED VIEW IF EXISTS mv_dt_aggregated_stats RENAME to dt_aggregated_stats;
      ALTER TABLE IF EXISTS mv_dt_aggregation_meta RENAME to dt_aggregation_meta;
    END $$;
    """

    execute sql
  end
end
