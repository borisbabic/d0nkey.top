defmodule Backend.Repo.Migrations.LogAggregateStatsLog do
  use Ecto.Migration

  def up() do
    create_table()
    create_function()
    create_trigger()
  end

  def down() do
    drop_trigger()
    drop_function()
    drop_table()
  end

  def create_table() do
    create table("logs_dt_aggregation") do
      add :formats, {:array, :integer}
      add :ranks, {:array, :string}
      add :periods, {:array, :string}
      timestamps(updated_at: false)
    end
  end

  def drop_table() do
    execute("DROP TABLE logs_dt_aggregation")
  end

  def create_function() do
    sql = """
      CREATE FUNCTION log_dt_aggregation_refresh() RETURNS event_trigger LANGUAGE plpgsql AS
      $$
      DECLARE mview text;
      BEGIN
      SELECT objid::regclass::text INTO mview FROM pg_event_trigger_ddl_commands() WHERE object_type = 'materialized view';
      if mview LIKE 'dt_aggregated_stats' then
        INSERT INTO logs_dt_aggregation (formats, ranks, periods, inserted_at)
        SELECT array_agg(DISTINCT(format)), array_agg(DISTINCT(rank)), array_agg(DISTINCT(period)), now() FROM public. dt_aggregated_stats;
      END IF;
      END; $$;
    """

    execute(sql)
  end

  def drop_function() do
    execute("DROP FUNCTION log_dt_aggregation_refresh")
  end

  def create_trigger() do
    sql = """
      CREATE EVENT TRIGGER log_dt_aggregation_refresh ON ddl_command_end
        WHEN TAG IN ('REFRESH MATERIALIZED VIEW')
        EXECUTE FUNCTION log_dt_aggregation_refresh();
    """

    execute(sql)
  end

  def drop_trigger() do
    execute("DROP EVENT TRIGGER IF EXISTS log_dt_aggregation_refresh")
  end
end
