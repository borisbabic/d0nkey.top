defmodule Backend.Repo.Migrations.ChangeIntermediateAggUniqueIndex do
  use Ecto.Migration

  def up do
    """
    DROP INDEX CONCURRENTLY IF EXISTS hourly_agg_stats_uniq_index ;
    CREATE UNIQUE INDEX intermediate_agg_stats_unique_index CONCURRENRLY ON public.dt_intermediate_agg_stats (
      COALESCE(day_start, '1970-01-01'),
      COALESCE(hour_start, '1970-01-01 00:00:00'),
      rank,
      format,
      COALESCE(deck_id, -1),
      COALESCE(opponent_class, 'any'),
      COALESCE(archetype, 'any')
    )
    """
  end

  def down do
    """
    DROP INDEX CONCURRENTLY IF EXISTS intermediate_agg_stats_unique_index ;
    CREATE UNIQUE INDEX hourly_agg_stats_uniq_index CONCURRENRLY ON public.dt_intermediate_agg_stats (
      COALESCE(deck_id, -1),
      COALESCE(archetype, 'any'),
      COALESCE(opponent_class, 'any'),
      rank,
      COALESCE(hour_start, '1970-01-01 00:00:00'),
      format
    )
    """
  end
end
