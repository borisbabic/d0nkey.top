defmodule Backend.Repo.Migrations.CreateDtHourlyAggregatedStats do
  use Ecto.Migration

  def create_table() do
    create table(:dt_hourly_aggregated_stats) do
      add :hour_start, :utc_datetime
      add :rank, :string
      add :deck_id, references(:deck, on_delete: :delete_all), null: true
      add :opponent_class, :string
      add :archetype, :string, null: true
      add :format, :integer
      add :winrate, :float
      add :wins, :decimal
      add :losses, :decimal
      add :total, :decimal
      add :turns, :integer
      add :total_turns, :integer
      add :turns_game_count, :integer
      add :duration, :integer
      add :total_duration, :integer
      add :duration_game_count, :integer
      add :climbing_speed, :float
      add :card_stats, :map
    end
  end

  def up do
    create_table()

    execute("""
    CREATE UNIQUE INDEX hourly_agg_stats_uniq_index ON public.dt_hourly_aggregated_stats(
    COALESCE(deck_id, -1),
    COALESCE(archetype, 'any'),
    COALESCE(opponent_class, 'any'),
    rank,
    hour_start,
    format
    );
    """)
  end

  def down do
    drop table(:dt_hourly_aggregated_stats)
  end
end
