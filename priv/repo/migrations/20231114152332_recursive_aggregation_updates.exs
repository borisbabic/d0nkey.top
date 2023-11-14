defmodule Backend.Repo.Migrations.RecursiveAggregationUpdates do
  use Ecto.Migration

  def up do
    """
    CREATE OR REPLACE FUNCTION looped_update_dt_aggregated_stats ()
    RETURNS VOID
    LANGUAGE plpgsql
    as $$
    DECLARE r record;
    BEGIN
      LOOP
        SELECT update_dt_aggregated_stats() INTO r;
        INSERT INTO logs_dt_aggregation (formats, ranks, periods, inserted_at) SELECT array_agg(DISTINCT(format)), array_agg(DISTINCT(rank)), array_agg(DISTINCT(period)), now() FROM public. dt_aggregated_stats;
        EXIT WHEN false = true;
      END LOOP;
    END $$;
    """
    |> execute()
  end

  def down() do
    execute("DROP FUNCTION IF EXISTS looped_update_dt_aggregated_stats")
  end
end
