defmodule Backend.Repo.Migrations.RecursiveAggStatsRefresh do
  use Ecto.Migration

  def up() do
    create_function()
    create_trigger()
  end

  def down() do
    drop_trigger()
    drop_function()
  end

  def create_function do
    create_function = """
    CREATE FUNCTION recursive_aggregation_refresh() RETURNS event_trigger LANGUAGE plpgsql AS
    $$
    DECLARE cnt int;
    DECLARE mview text;
    declare r record;
    begin
      SELECT objid::regclass::text INTO mview FROM pg_event_trigger_ddl_commands() WHERE object_type = 'materialized view';
      SELECT count(1) INTO cnt FROM pg_stat_activity WHERE query LIKE '%REFRESH MATERIALIZED VIEW CONCURRENTLY dt_aggregated_stats%' and pid != pg_backend_pid();
      IF cnt < 1 and mview LIKE 'dt_aggregated_stats' then
        REFRESH MATERIALIZED VIEW CONCURRENTLY dt_aggregated_stats WITH DATA ;
      END IF;
    END $$;
    """

    execute(create_function)
  end

  def drop_function() do
    execute("DROP FUNCTION recursive_aggregation_refresh")
  end

  def create_trigger() do
    sql = """
      CREATE EVENT TRIGGER recursive_aggregation_refresh ON ddl_command_end
        WHEN TAG IN ('REFRESH MATERIALIZED VIEW')
        EXECUTE FUNCTION recursive_aggregation_refresh();
    """

    execute(sql)
  end

  def drop_trigger() do
    execute("DROP EVENT TRIGGER IF EXISTS recursive_aggregation_refresh")
  end
end
