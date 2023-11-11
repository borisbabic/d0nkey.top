defmodule Backend.Repo.Migrations.AggregateStatsMaterializedViewUniqueIndex do
  use Ecto.Migration

  def up do
    execute("""
    CREATE UNIQUE INDEX agg_stats_uniq_index ON dt_aggregated_stats (
      rank,
      period,
      format,
      COALESCE(deck_id, -1),
      COALESCE(opponent_class, 'any'),
      COALESCE(archetype, 'any')
    )
    """)
  end

  def down() do
    execute("DROP INDEX agg_stats_uniq_index")
  end
end
