defmodule Backend.Repo.Migrations.CreateDtAggregatedStatsForLocalDev do
  use Ecto.Migration

  def up do
    sql = """
       CREATE TABLE IF NOT EXISTS dt_aggregated_stats (
        -- DON'T REFERENCE deck. It seems to block insertions into the deck table while this executes if you reference
        deck_id integer,
        period varchar,
        rank varchar,
        opponent_class varchar,
        archetype varchar,
        format integer,
        winrate double precision,
        wins integer,
        losses integer,
        total integer,
        turns double precision,
        duration double precision,
        climbing_speed double precision,
        player_has_coin boolean,
        card_stats jsonb
    );
    """

    execute sql
  end

  def down do
  end
end
