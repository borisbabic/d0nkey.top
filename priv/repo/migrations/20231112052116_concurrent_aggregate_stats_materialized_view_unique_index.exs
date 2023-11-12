defmodule Backend.Repo.Migrations.ConcurrentAggregateStatsMaterializedViewUniqueIndex do
  use Ecto.Migration

  def up do
    execute(
      "CREATE UNIQUE INDEX for_concurrency_agg_stats_uniq_index ON dt_aggregated_stats (rank,  period,  format,  deck_id,  opponent_class,  archetype)"
    )
  end

  def down do
    execute("DROP INDEX for_concurrency_agg_stats_uniq_index")
  end
end
