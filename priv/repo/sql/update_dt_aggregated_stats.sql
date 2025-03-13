CREATE OR REPLACE FUNCTION update_dt_aggregated_stats_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
CREATE TABLE dt_aggregated_stats (
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

CREATE INDEX agg_stats_uniq_index ON temp_dt_aggregated_stats(total, COALESCE(deck_id, -1),  COALESCE(archetype, 'any'), COALESCE(opponent_class, 'any'), rank, period, format, player_has_coin);
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
agg_periods(
    format,
    START, 
    slug,
    game_type
) AS (
    SELECT p.format, p.START, p.slug, f.game_type FROM (SELECT
        UNNEST(formats) as format,
        COALESCE(period_start, now() - concat(hours_ago::text, ' hours')::interval) AS START,
        slug
    FROM
        public.dt_periods
    WHERE
        auto_aggregate) p
	INNER JOIN public.formats f ON value = p.format
	WHERE f.auto_aggregate
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
        dg.player_has_coin,
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
            END), 0), 1) AS winrate,
    SUM(case WHEN turns IS NOT NULL then turns else 0 end) as turns,
    SUM(case WHEN turns IS NOT NULL then 1 else 0 end) as turns_game_count,
    SUM(case WHEN duration IS NOT NULL then duration else 0 end) as duration,
    SUM(case WHEN duration IS NOT NULL then 1 else 0 end) as duration_game_count
FROM
    public.dt_games dg
    INNER JOIN public.deck d ON d.id = dg.player_deck_id
    INNER JOIN agg_periods p ON dg.inserted_at >= p.START AND p.format = dg.format
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
        AND dg.game_type = p.game_type
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
            GROUPING SETS (4,()),
            GROUPING SETS (6,())
),
card_stats AS (
    SELECT
        p.slug AS PERIOD,
        r.slug AS RANK,
        dcgt.deck_id AS deck_id,
        dcgt.card_id,
        dg.opponent_class,
        dg.format,
        dg.player_has_coin,
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
            END) AS mulligan_losses,
        sum(
            CASE WHEN dg.status = 'win'
                AND dcgt.mulligan = False and dcgt.drawn = False THEN
                1
            ELSE
                0
            END) AS tossed_wins,
        sum(
            CASE WHEN dg.status = 'loss'
                AND dcgt.mulligan = False and dcgt.drawn = False THEN
                1
            ELSE
                0
            END) AS tossed_losses
    FROM
        public.dt_card_game_tally dcgt
        INNER JOIN public.dt_games dg ON dg.id = dcgt.game_id
        INNER JOIN agg_periods p ON dg.inserted_at >= p.START AND p.format = dg.format
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
        AND dg.opponent_class IS NOT NULL
        AND dg.game_type = p.game_type
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
            GROUPING SETS (5,()),
            GROUPING SETS (7,())

),
merged_card_stats AS (
    SELECT
        cs.period,
        cs.rank,
        cs.deck_id,
        cs.card_id,
        cs.opponent_class,
        cs.format,
        cs.player_has_coin,
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
            END) mull_impact_factor,

            (cs.tossed_wins + cs.tossed_losses) tossed_total,
            (
            CASE WHEN (cs.tossed_wins + cs.tossed_losses) > 0 THEN
                (cs.tossed_wins + cs.tossed_losses) *(cs.tossed_wins::float /(cs.tossed_wins + cs.tossed_losses) - ds.winrate)
            ELSE
                0
            END) tossed_impact_factor
    FROM
        card_stats cs
        INNER JOIN deck_stats ds ON ds.period = cs.period
            AND cs.rank = ds.rank
            AND ds.deck_id = cs.deck_id
            AND ds.player_has_coin IS NOT DISTINCT FROM cs.player_has_coin
            AND COALESCE(ds.opponent_class, 'any') = COALESCE(cs.opponent_class, 'any')
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
        ds.player_has_coin,
        SUM(ds.total) AS total,
        SUM(ds.wins) AS wins,
        SUM(ds.losses) AS losses,
        CASE WHEN sum(ds.total) > 0 THEN
            SUM(ds.winrate * ds.total) / sum(ds.total)
        ELSE
            0
        END AS winrate,
        CASE WHEN sum(turns_game_count) > 0 THEN
            SUM(turns)::float / SUM(turns_game_count)
        ELSE 
            0
        END as turns,
        SUM(turns) AS total_turns,
        SUM(turns_game_count) AS turns_game_count,
        CASE WHEN SUM(duration_game_count) > 0 THEN 
            SUM(duration)::float / SUM(duration_game_count)
        ELSE
            0
        END as duration,
        SUM(duration) AS total_duration,
        SUM(duration_game_count) as duration_game_count,
        CASE WHEN SUM(ds.total) > 0 AND SUM(duration) > 0 THEN
            ( SUM(duration_game_count) * 3600::float / SUM(duration)) * (2 * (SUM(ds.winrate * ds.total) / SUM(ds.total))  - 1)
        ELSE
            0
        END as climbing_speed
    FROM
        deck_stats ds
    INNER JOIN deck d ON d.id = ds.deck_id
GROUP BY
    1,
    2,
    4,
    6,
    GROUPING SETS ((3),
(5)),
    7
),
prepared_card_stats AS (
    SELECT
        cs.period,
        cs.rank,
        cs.deck_id,
        cs.opponent_class,
        COALESCE(d.archetype, initcap(d.class)) AS archetype,
        cs.format,
        cs.player_has_coin,
        jsonb_build_object(
            'card_id', cs.card_id, 
            'kept_total', sum(cs.kept_total), 
            'kept_impact', CASE WHEN sum(cs.kept_total) > 0 THEN
                sum(cs.kept_impact_factor) / sum(cs.kept_total)
            ELSE
                0
            END, 
            'mull_total', sum(cs.mull_total), 
            'mull_impact', CASE WHEN sum(cs.mull_total) > 0 THEN
                sum(cs.mull_impact_factor) / sum(cs.mull_total)
            ELSE
                0
            END, 
            'tossed_total', sum(cs.tossed_total), 
            'tossed_impact', CASE WHEN sum(cs.tossed_total) > 0 THEN
                sum(cs.tossed_impact_factor) / sum(cs.tossed_total)
            ELSE
                0
            END, 
            'kept_percent', CASE WHEN sum(cs.tossed_total + cs.mull_total) > 0 THEN
                sum(cs.mull_total) / sum(cs.tossed_total + cs.mull_total)
            ELSE
                0
            END, 
            'drawn_total', sum(cs.drawn_total), 
            'drawn_impact', CASE WHEN sum(cs.drawn_total) > 0 THEN
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
(5)),
player_has_coin
),
grouped_card_stats AS (
    SELECT
        cs.period,
        cs.rank,
        cs.deck_id,
        cs.opponent_class,
        cs.archetype,
        cs.format,
        cs.player_has_coin,
        jsonb_agg(cs.card_stats) AS card_stats
    FROM
        prepared_card_stats cs
    GROUP BY
        1,
        2,
        3,
        4,
        5,
        6,
        7
)
INSERT INTO  dt_aggregated_stats (
	deck_id,
	period,
	rank,
	opponent_class,
	archetype,
	format,
	total,
	winrate,
	wins,
	losses,
	turns,
	duration,
	climbing_speed,
	player_has_coin,
	card_stats
)
SELECT 
	ds.deck_id,
	ds.period,
	ds.rank,
	ds.opponent_class,
	ds.archetype,
	ds.format,
	ds.total,
	ds.winrate,
	ds.wins,
	ds.losses,
	ds.turns,
	ds.duration,
	ds.climbing_speed,
	ds.player_has_coin,
	cs.card_stats
FROM
    grouped_deck_stats ds
    LEFT JOIN grouped_card_stats cs ON cs.rank = ds.rank
        AND cs.period = ds.PERIOD
        AND cs.format = ds.format
        AND COALESCE(ds.deck_id, -1) = COALESCE(cs.deck_id, -1)
        AND COALESCE(ds.opponent_class, 'any') = COALESCE(cs.opponent_class, 'any')
        AND COALESCE(ds.archetype, 'any') = COALESCE(cs.archetype, 'any')
        AND cs.player_has_coin IS NOT DISTINCT FROM ds.player_has_coin;

ALTER INDEX IF EXISTS agg_stats_uniq_index RENAME TO old_agg_stats_uniq_index;
ALTER INDEX IF EXISTS agg_stats_uniq_index RENAME TO agg_stats_uniq_index;
ALTER TABLE IF EXISTS dt_aggregated_stats RENAME TO old_dt_aggregated_stats;
ALTER TABLE dt_aggregated_stats RENAME TO dt_aggregated_stats;
DROP TABLE IF EXISTS old_dt_aggregated_stats;
-- UPDATE AGG LOG
-- DO NOT COMMIT THE BELOW COMMENTED OUT
INSERT INTO logs_dt_aggregation (formats, ranks, periods, regions, inserted_at) SELECT array_agg(DISTINCT(format)), array_agg(DISTINCT(rank)), array_agg(DISTINCT(period)), (SELECT array_agg(code) FROM public.dt_regions WHERE auto_aggregate), now() FROM public.dt_aggregated_stats;
-- UPDATE AGGREGATION COUNT
CREATE TABLE public.dt_aggregation_meta_new AS
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
    (SUM(total * winrate) / SUM(total)) AS overall_winrate,
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
ALTER TABLE IF EXISTS dt_aggregation_meta RENAME TO dt_aggregation_meta_old;
ALTER TABLE IF EXISTS dt_aggregation_meta_new RENAME TO dt_aggregation_meta;
DROP TABLE IF EXISTS dt_aggregation_meta_old;
END;
$$;

