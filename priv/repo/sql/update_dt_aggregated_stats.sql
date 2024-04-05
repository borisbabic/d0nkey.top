CREATE OR REPLACE FUNCTION update_dt_aggregated_stats()
    RETURNS VOID
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    CREATE MATERIALIZED VIEW temp_dt_aggregated_stats AS
    WITH agg_ranks(
        min_rank,
        max_rank,
        min_legend_rank,
        max_legend_rank,
        slug
) AS (
        SELECT
            min_rank,
            max_rank,
            min_legend_rank,
            max_legend_rank,
            slug
        FROM
            public.ranks
        WHERE
            auto_aggregate = TRUE
),
agg_formats(
    value
) AS (
    SELECT
        value
    FROM
        public.formats
    WHERE
        auto_aggregate = TRUE
),
agg_periods(
    START, slug
) AS (
    SELECT
        COALESCE(period_start, now() - concat(hours_ago::text, ' hours')::interval) AS PERIOD,
        slug
    FROM
        public.dt_periods
    WHERE
        auto_aggregate
),
agg_regions(
    code
) AS (
    SELECT
        code
    FROM
        public.dt_regions
    WHERE
        auto_aggregate
),
deck_stats AS (
    SELECT
        p.slug AS PERIOD,
        r.slug AS RANK,
        dg.player_deck_id AS deck_id,
        dg.opponent_class,
        dg.format,
        sum(
            CASE WHEN dg.status = 'win' THEN
                1
            ELSE
                0
            END) AS wins,
    sum(
        CASE WHEN dg.status = 'loss' THEN
            1
        ELSE
            0
        END) AS losses,
    sum(
        CASE WHEN dg.status IN ('win', 'loss') THEN
            1
        ELSE
            0
        END) AS total,
CAST(SUM(
        CASE WHEN dg.status = 'win' THEN
            1
        ELSE
            0
        END) AS float) / COALESCE(NULLIF(SUM(
            CASE WHEN dg.status IN ('win', 'loss') THEN
                1
            ELSE
                0
            END), 0), 1) AS winrate
FROM
    public.dt_games dg
    INNER JOIN public.deck d ON d.id = dg.player_deck_id
    INNER JOIN agg_periods p ON dg.inserted_at >= p.START
    INNER JOIN agg_formats f ON dg.format = f.value
    INNER JOIN agg_ranks r ON (r.min_rank = 0
            OR dg.player_rank >= min_rank)
        AND (r.max_rank IS NULL
            OR dg.player_rank <= r.max_rank)
        AND (r.min_legend_rank = 0
            OR dg.player_legend_rank >= min_legend_rank)
        AND (r.max_legend_rank IS NULL
            OR dg.player_legend_rank <= r.max_legend_rank)
    WHERE
        dg.inserted_at <= now()
        AND dg.game_type = 7
        AND dg.opponent_class IS NOT NULL
        AND dg.player_deck_id IS NOT NULL
        AND dg.region IN (
            SELECT
                code
            FROM
                agg_regions)
        GROUP BY
            1,
            2,
            3,
            5,
            GROUPING SETS (4,())
),
card_stats AS (
    SELECT
        p.slug AS PERIOD,
        r.slug AS RANK,
        dcgt.deck_id AS deck_id,
        dcgt.card_id,
        dg.opponent_class,
        dg.format,
        sum(
            CASE WHEN dg.status = 'win'
                AND dcgt.kept
                AND dcgt.mulligan THEN
                1
            ELSE
                0
            END) AS kept_wins,
        sum(
            CASE WHEN dg.status = 'loss'
                AND dcgt.kept
                AND dcgt.mulligan THEN
                1
            ELSE
                0
            END) AS kept_losses,
        sum(
            CASE WHEN dg.status = 'win'
                AND dcgt.drawn THEN
                1
            ELSE
                0
            END) AS drawn_wins,
        sum(
            CASE WHEN dg.status = 'loss'
                AND dcgt.drawn THEN
                1
            ELSE
                0
            END) AS drawn_losses,
        sum(
            CASE WHEN dg.status = 'win'
                AND dcgt.mulligan THEN
                1
            ELSE
                0
            END) AS mulligan_wins,
        sum(
            CASE WHEN dg.status = 'loss'
                AND dcgt.mulligan THEN
                1
            ELSE
                0
            END) AS mulligan_losses
    FROM
        public.dt_card_game_tally dcgt
        INNER JOIN agg_periods p ON dcgt.inserted_at >= p.START
        INNER JOIN public.dt_games dg ON dg.id = dcgt.game_id
        INNER JOIN agg_formats f ON dg.format = f.value
        INNER JOIN agg_ranks r ON (r.min_rank = 0
                OR dg.player_rank >= min_rank)
            AND (r.max_rank IS NULL
                OR dg.player_rank <= r.max_rank)
            AND (r.min_legend_rank = 0
                OR dg.player_legend_rank >= min_legend_rank)
            AND (r.max_legend_rank IS NULL
                OR dg.player_legend_rank <= r.max_legend_rank)
    WHERE
        dcgt.inserted_at <= now()
        AND dg.opponent_class IS NOT NULL
        AND dg.game_type = 7
        AND dg.region IN (
            SELECT
                code
            FROM
                agg_regions)
        GROUP BY
            1,
            2,
            3,
            4,
            6,
            GROUPING SETS (5,())
),
merged_card_stats AS (
    SELECT
        cs.period,
        cs.rank,
        cs.deck_id,
        cs.card_id,
        cs.opponent_class,
        cs.format,
        cs.kept_wins + cs.kept_losses AS kept_total,
(
            CASE WHEN (cs.kept_wins + cs.kept_losses) > 0 THEN
                (cs.kept_wins + cs.kept_losses) *(cs.kept_wins::float /(cs.kept_wins + cs.kept_losses) - ds.winrate)
            ELSE
                0
            END) kept_impact_factor,
(cs.drawn_wins + cs.drawn_losses) drawn_total,
(
            CASE WHEN (cs.drawn_wins + cs.drawn_losses) > 0 THEN
                (cs.drawn_wins + cs.drawn_losses) *(cs.drawn_wins::float /(cs.drawn_wins + cs.drawn_losses) - ds.winrate)
            ELSE
                0
            END) drawn_impact_factor,
(cs.mulligan_wins + cs.mulligan_losses) mull_total,
(
            CASE WHEN (cs.mulligan_wins + cs.mulligan_losses) > 0 THEN
                (cs.mulligan_wins + cs.mulligan_losses) *(cs.mulligan_wins::float /(cs.mulligan_wins + cs.mulligan_losses) - ds.winrate)
            ELSE
                0
            END) mull_impact_factor
    FROM
        card_stats cs
        INNER JOIN deck_stats ds ON ds.period = cs.period
            AND cs.rank = ds.rank
            AND ds.deck_id = cs.deck_id
            AND COALESCE(cs.opponent_class, 'any') = COALESCE(ds.opponent_class, 'any')
            AND cs.format = ds.format
),
grouped_deck_stats AS (
    SELECT
        ds.period,
        ds.rank,
        ds.deck_id,
        ds.opponent_class,
        COALESCE(d.archetype, initcap(d.class)) AS archetype,
        ds.format,
        SUM(ds.total) AS total,
        SUM(ds.wins) AS wins,
        SUM(ds.losses) AS losses,
        CASE WHEN sum(ds.total) > 0 THEN
            SUM(ds.winrate * ds.total) / sum(ds.total)
        ELSE
            0
        END AS winrate
    FROM
        deck_stats ds
    INNER JOIN deck d ON d.id = ds.deck_id
GROUP BY
    1,
    2,
    4,
    6,
    GROUPING SETS ((3),
(5))
),
prepared_card_stats AS (
    SELECT
        cs.period,
        cs.rank,
        cs.deck_id,
        cs.opponent_class,
        COALESCE(d.archetype, initcap(d.class)) AS archetype,
        cs.format,
        jsonb_build_object('card_id', cs.card_id, 'kept_total', sum(cs.kept_total), 'kept_impact', CASE WHEN sum(cs.kept_total) > 0 THEN
                sum(cs.kept_impact_factor) / sum(cs.kept_total)
            ELSE
                0
            END, 'mull_total', sum(cs.mull_total), 'mull_impact', CASE WHEN sum(cs.mull_total) > 0 THEN
                sum(cs.mull_impact_factor) / sum(cs.mull_total)
            ELSE
                0
            END, 'drawn_total', sum(cs.drawn_total), 'drawn_impact', CASE WHEN sum(cs.drawn_total) > 0 THEN
                sum(cs.drawn_impact_factor) / sum(cs.drawn_total)
            ELSE
                0
            END) AS card_stats
    FROM
        merged_card_stats cs
        INNER JOIN deck d ON d.id = cs.deck_id
    GROUP BY
        1,
        2,
        4,
        6,
        cs.card_id,
        GROUPING SETS ((3),
(5))
),
grouped_card_stats AS (
    SELECT
        cs.period,
        cs.rank,
        cs.deck_id,
        cs.opponent_class,
        cs.archetype,
        cs.format,
        jsonb_agg(cs.card_stats) AS card_stats
    FROM
        prepared_card_stats cs
    GROUP BY
        1,
        2,
        3,
        4,
        5,
        6
)
SELECT
    ds.*,
    cs.card_stats
FROM
    grouped_deck_stats ds
    LEFT JOIN grouped_card_stats cs ON cs.rank = ds.rank
        AND cs.period = ds.PERIOD
        AND cs.format = ds.format
        AND COALESCE(cs.deck_id, -1) = COALESCE(ds.deck_id, -1)
    AND COALESCE(ds.opponent_class, 'any') = COALESCE(cs.opponent_class, 'any')
    AND COALESCE(cs.archetype, 'any') = COALESCE(ds.archetype, 'any');

ALTER INDEX agg_stats_uniq_index RENAME TO old_agg_stats_uniq_index;
CREATE UNIQUE INDEX agg_stats_uniq_index ON temp_dt_aggregated_stats(rank, period, format, COALESCE(deck_id, -1), COALESCE(opponent_class, 'any'), COALESCE(archetype, 'any'));
ALTER MATERIALIZED VIEW dt_aggregated_stats RENAME TO old_dt_aggregated_stats;
ALTER MATERIALIZED VIEW temp_dt_aggregated_stats RENAME TO dt_aggregated_stats;
DROP MATERIALIZED VIEW IF EXISTS old_dt_aggregated_stats;
-- UPDATE AGG LOG
INSERT INTO logs_dt_aggregation (formats, ranks, periods, regions, inserted_at) SELECT array_agg(DISTINCT(format)), array_agg(DISTINCT(rank)), array_agg(DISTINCT(period)), (SELECT array_agg(code) FROM public.dt_regions WHERE auto_aggregate), now() FROM public.dt_aggregated_stats;
-- UPDATE AGGREGATION COUNT
CREATE TABLE public.dt_aggregation_counts_new AS
SELECT
    FORMAT,
    PERIOD,
    RANK,
    COUNT(*)::bigint AS COUNT,
    SUM(TOTAL)::bigint AS TOTAL_SUM,
    SUM(
    CASE
        WHEN TOTAL >= 200 THEN 1
        ELSE 0
    END
    )::bigint AS COUNT_200,
    SUM(
    CASE
        WHEN TOTAL >= 400 THEN 1
        ELSE 0
    END
    )::bigint AS COUNT_400,
    SUM(
    CASE
        WHEN TOTAL >= 800 THEN 1
        ELSE 0
    END
    )::bigint AS COUNT_800,
    SUM(
    CASE
        WHEN TOTAL >= 1600 THEN 1
        ELSE 0
    END
    )::bigint AS COUNT_1600,
    SUM(
    CASE
        WHEN TOTAL >= 3200 THEN 1
        ELSE 0
    END
    )::bigint AS COUNT_3200,
    SUM(
    CASE
        WHEN TOTAL >= 6400 THEN 1
        ELSE 0
    END
    )::bigint AS COUNT_6400,
    SUM(
    CASE
        WHEN TOTAL >= 12800 THEN 1
        ELSE 0
    END
    )::bigint AS COUNT_12800,
    now() as inserted_at
FROM
    PUBLIC.DT_AGGREGATED_STATS
WHERE
    DECK_ID IS NOT NULL
    AND ARCHETYPE IS NULL
GROUP BY
    1,
    2,
    3;
ALTER TABLE IF EXISTS dt_aggregation_counts RENAME TO dt_aggregation_counts_old;
ALTER TABLE IF EXISTS dt_aggregation_counts_new RENAME TO dt_aggregation_counts;
DROP TABLE IF EXISTS dt_aggregation_counts_old;
END;
$$;

