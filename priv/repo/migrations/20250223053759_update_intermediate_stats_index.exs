defmodule Backend.Repo.Migrations.UpdateIntermediateStatsIndex do
  use Ecto.Migration

  def up do
    execute("DROP INDEX IF EXISTS intermediate_agg_stats_unique_index ;")

    """
    CREATE UNIQUE INDEX intermediate_agg_stats_unique_index ON public.dt_intermediate_agg_stats (
      COALESCE(day, '1970-01-01'),
      COALESCE(hour_start, '1970-01-01 00:00:00'),
      rank,
      format,
      COALESCE(deck_id, -1),
      COALESCE(opponent_class, 'any'),
      CAST(player_has_coin as text)
    )
    """
    |> execute()
  end

  def down do
    execute("DROP INDEX IF EXISTS intermediate_agg_stats_unique_index ;")

    """
    CREATE UNIQUE INDEX intermediate_agg_stats_unique_index ON public.dt_intermediate_agg_stats (
      COALESCE(day, '1970-01-01'),
      COALESCE(hour_start, '1970-01-01 00:00:00'),
      rank,
      format,
      COALESCE(deck_id, -1),
      COALESCE(opponent_class, 'any'),
      COALESCE(archetype, 'any')
    )
    """
    |> execute()
  end
end
