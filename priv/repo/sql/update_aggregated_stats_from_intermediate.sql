CREATE OR REPLACE FUNCTION update_dt_agg_stats_from_intermediate()
    RETURNS VOID
    LANGUAGE plpgsql
    AS $$
DECLARE 
_num_hours int;
BEGIN
CREATE TABLE dt_temp_new_agg_stats AS
with agg_periods(
    format,
    days,
    hour_starts,
    slug
) AS (
    SELECT 
    temp.format,
    temp.days,
    array(SELECT DISTINCT(i.hour_start) FROM public.dt_intermediate_agg_stats i WHERE i.hour_start::date != ANY(temp.days) AND i.format = temp.format AND i.hour_start >= temp.start and i.hour_start < DATE_TRUNC('hour', temp.end_time)) as hour_starts,
    temp.slug
    FROM
    (
        SELECT 
        p.format,  
        array(SELECT DISTINCT(i.day) FROM public.dt_intermediate_agg_stats i WHERE i.format = p.format AND i.day >= p.start and i.day < DATE_TRUNC('day', p.end_time)) as days,
        p.slug,
        p.start,
        p.end_time
        FROM (SELECT
            UNNEST(formats) as format,
            COALESCE(period_start, now() - concat(hours_ago::text, ' hours')::interval) AS START,
            COALESCE(period_end, now()) AS end_time,
            slug
        FROM
            public.dt_periods
        WHERE
            auto_aggregate) p
        INNER JOIN public.formats f ON value = p.format
        WHERE f.auto_aggregate 
    ) temp
), BASE_CARD_STATS AS (
		SELECT
			RANK,
			DECK_ID,
			PLAYER_HAS_COIN,
			OPPONENT_CLASS,
			FORMAT,
            ARCHETYPE,
            PERIOD,
			-- WINRATE,
			-- WINS,
			-- LOSSES,
			-- TOTAL,
			-- TURNS,
			-- TOTAL_TURNS,
			-- TURNS_GAME_COUNT,
			-- DURATION,
			-- TOTAL_DURATION,
			-- DURATION_GAME_COUNT,
			COALESCE(CARD_STATS->>'card_id', '0')::BIGINT AS CARD_ID,
			COALESCE(CARD_STATS->>'kept_total', '0')::BIGINT AS KEPT_TOTAL,
			COALESCE(CARD_STATS->>'mull_total', '0')::BIGINT AS MULL_TOTAL,
			COALESCE(CARD_STATS->>'drawn_total', '0')::BIGINT AS DRAWN_TOTAL,
			COALESCE(CARD_STATS->>'kept_impact', '0')::FLOAT AS KEPT_IMPACT,
			COALESCE(CARD_STATS->>'mull_impact', '0')::FLOAT AS MULL_IMPACT,
			COALESCE(CARD_STATS->>'drawn_impact', '0')::FLOAT AS DRAWN_IMPACT,
			COALESCE(CARD_STATS->>'kept_percent', '0')::FLOAT AS KEPT_PERCENT,
			COALESCE(CARD_STATS->>'tossed_total', '0')::BIGINT AS TOSSED_TOTAL,
			COALESCE(CARD_STATS->>'tossed_impact', '0')::FLOAT AS TOSSED_IMPACT
		FROM
			(
				SELECT
					RANK,
					DECK_ID,
					PLAYER_HAS_COIN,
					OPPONENT_CLASS,
					HS.FORMAT,
                    COALESCE(d.archetype, initcap(d.class)) as ARCHETYPE,
                    p.slug as PERIOD,
					-- WINRATE,
					-- WINS,
					-- LOSSES,
					-- TOTAL,
					-- TURNS,
					-- TOTAL_TURNS,
					-- TURNS_GAME_COUNT,
					-- DURATION,
					-- TOTAL_DURATION,
					-- DURATION_GAME_COUNT,
					-- CLIMBING_SPEED,
					JSONB_ARRAY_ELEMENTS(COALESCE(CARD_STATS, '[{}]')) AS CARD_STATS
				FROM
					PUBLIC.dt_intermediate_agg_stats HS
                INNER JOIN agg_periods p ON p.format = hs.format AND ((hs.day = ANY(p.days)) OR (hs.hour_start = ANY(p.hour_starts)))
                INNER JOIN public.deck d ON hs.DECK_ID = d.id
				WHERE card_stats IS NOT NULL
			) ds
	),
	PREPARED_DECK_STATS AS (
		SELECT
			RANK,
			DECK_ID,
			OPPONENT_CLASS,
			PLAYER_HAS_COIN,
			hs.FORMAT,
            COALESCE(d.archetype, initcap(d.class)) as archetype,
			p.slug as period,
			SUM(TOTAL)::bigint AS TOTAL,
			SUM(WINS)::bigint AS WINS,
			SUM(LOSSES)::bigint AS LOSSES,
			(CASE WHEN SUM(total) > 0 THEN SUM(WINS) / SUM(TOTAL) ELSE 0 END)::float AS WINRATE,
			(CASE
				WHEN SUM(TURNS_GAME_COUNT) > 0 THEN SUM(TOTAL_TURNS) / SUM(TURNS_GAME_COUNT)
				ELSE 0
			END)::float AS TURNS,
			SUM(TOTAL_TURNS)::bigint AS TOTAL_TURNS,
			SUM(TURNS_GAME_COUNT)::bigint AS TURNS_GAME_COUNT,
			(CASE
				WHEN SUM(DURATION_GAME_COUNT) > 0 THEN SUM(TOTAL_DURATION) / SUM(DURATION_GAME_COUNT)
				ELSE 0
			END)::float AS DURATION,
			SUM(TOTAL_DURATION)::bigint AS TOTAL_DURATION,
			SUM(DURATION_GAME_COUNT)::bigint AS DURATION_GAME_COUNT,
			(CASE WHEN SUM(TOTAL) > 0 AND SUM(DURATION) > 0 THEN
				( SUM(DURATION_GAME_COUNT) * 3600::float / SUM(DURATION)) * (2 * (SUM(WINRATE * TOTAL) / SUM(TOTAL))  - 1)
			ELSE
				0
			END)::float as climbing_speed
		FROM
			PUBLIC.dt_intermediate_agg_stats HS
            INNER JOIN agg_periods p ON p.format = hs.format AND ((hs.day = ANY(p.days)) OR (hs.hour_start = ANY(p.hour_starts)))
            INNER JOIN public.deck d ON hs.DECK_ID = d.id
		GROUP BY
			1,
            GROUPING SETS((2), (6)),
			3,
			4,
			5,
            7
	),
	PREPARED_CARD_STATS AS (
		SELECT
			RANK,
			DECK_ID,
			OPPONENT_CLASS,
			PLAYER_HAS_COIN,
			FORMAT,
            archetype,
            period,
			JSON_BUILD_OBJECT(
				'card_id',
				CARD_ID,
				'kept_total',
				SUM(KEPT_TOTAL),
				'mull_total',
				SUM(MULL_TOTAL),
				'drawn_total',
				SUM(DRAWN_TOTAL),
				'tossed_total',
				SUM(TOSSED_TOTAL),
				'kept_impact',
				CASE
					WHEN SUM(CS.KEPT_TOTAL) > 0 THEN SUM(CS.KEPT_IMPACT * CS.KEPT_TOTAL) / SUM(CS.KEPT_TOTAL)
					ELSE 0
				END,
				'mull_impact',
				CASE
					WHEN SUM(CS.MULL_TOTAL) > 0 THEN SUM(CS.MULL_IMPACT * CS.MULL_TOTAL) / SUM(CS.MULL_TOTAL)
					ELSE 0
				END,
				'drawn_impact',
				CASE
					WHEN SUM(CS.DRAWN_TOTAL) > 0 THEN SUM(CS.DRAWN_IMPACT * CS.DRAWN_TOTAL) / SUM(CS.DRAWN_TOTAL)
					ELSE 0
				END,
				'tossed_impact',
				CASE
					WHEN SUM(CS.TOSSED_TOTAL) > 0 THEN SUM(CS.TOSSED_IMPACT * CS.TOSSED_TOTAL) / SUM(CS.TOSSED_TOTAL)
					ELSE 0
				END,
				'kept_percent',
				CASE
					WHEN (SUM(CS.KEPT_TOTAL) + SUM(CS.TOSSED_TOTAL)) > 0 THEN SUM(CS.KEPT_TOTAL) / (SUM(CS.KEPT_TOTAL) + SUM(CS.TOSSED_TOTAL))
					ELSE 0
				END
			) AS CARD_STATS
		FROM
			BASE_CARD_STATS CS
		GROUP BY
			1,
            GROUPING SETS((2), (6)),
			3,
			4,
			5,
            7,
			CS.CARD_ID
	),
	GROUPED_CARD_STATS AS (
		SELECT
			RANK,
			DECK_ID,
			PLAYER_HAS_COIN,
			OPPONENT_CLASS,
			FORMAT,
            archetype,
            period,
			JSONB_AGG(CARD_STATS) AS CARD_STATS
		FROM
			PREPARED_CARD_STATS CS
		GROUP BY
			1,
			2,
			3,
			4,
			5,
            6,
            7
	)
-- SELECT
-- 	DS.*,
-- 	CS.CARD_STATS
-- FROM
-- 	PREPARED_DECK_STATS DS
-- 	LEFT JOIN GROUPED_CARD_STATS CS ON CS.RANK = DS.RANK
-- 	AND CS.FORMAT = DS.FORMAT
-- 	AND COALESCE(CS.OPPONENT_CLASS, 'any') = COALESCE(DS.OPPONENT_CLASS, 'any')
-- 	AND COALESCE(CS.ARCHETYPE, 'any') = COALESCE(DS.ARCHETYPE, 'any')
-- 	AND COALESCE(CS.DECK_ID, -1) = COALESCE(DS.DECK_ID, -1)
SELECT 
    ds.*, 
    cs.card_stats
-- INTO public."dt_temp_new_agg_stats"
FROM
    prepared_deck_stats ds
    LEFT JOIN grouped_card_stats cs ON cs.rank = ds.rank
        AND cs.format = ds.format
		AND cs.period = ds.period
        AND cs.archetype IS NOT DISTINCT FROM ds.archetype
        AND cs.deck_id IS NOT DISTINCT FROM ds.deck_id
        AND cs.opponent_class IS NOT DISTINCT FROM ds.opponent_class
        AND cs.player_has_coin IS NOT DISTINCT FROM ds.player_has_coin;

ALTER INDEX IF EXISTS new_agg_stats_uniq_index RENAME TO old_new_agg_stats_uniq_index;
CREATE UNIQUE INDEX new_agg_stats_uniq_index ON dt_temp_new_agg_stats(total, COALESCE(deck_id, -1),  COALESCE(archetype, 'any'), COALESCE(opponent_class, 'any'), rank, period, format, player_has_coin);
ALTER TABLE IF EXISTS dt_new_agg_stats RENAME to old_dt_new_agg_stats;
ALTER TABLE IF EXISTS dt_temp_new_agg_stats RENAME to dt_new_agg_stats;
DROP TABLE IF EXISTS old_dt_new_agg_stats;
-- UPDATE AGG LOG
-- DO NOT COMMIT THE BELOW COMMENTED OUT
-- INSERT INTO logs_dt_intermediate_agg (hour_start, formats, ranks, regions, inserted_at, day) SELECT null, array_agg(DISTINCT(format)), array_agg(DISTINCT(rank)), (SELECT array_agg(code) FROM public.dt_regions WHERE auto_aggregate), now(), day_arg FROM public.dt_intermediate_agg_stats WHERE day = day;
-- INSERT INTO logs_dt_new_agg(formats, ranks, periods, regions, inserted_at) SELECT array_agg(DISTINCT(format)), array_agg(DISTINCT(rank)), array_agg(DISTINCT(period)), (SELECT array_agg(code) FROM public.dt_regions WHERE auto_aggregate), now() FROM public.dt_new_agg_stats;
CREATE TABLE public.dt_new_agg_meta_new AS
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
ALTER TABLE IF EXISTS dt_new_agg_meta RENAME TO dt_new_agg_meta_old;
ALTER TABLE IF EXISTS dt_new_agg_meta_new RENAME TO dt_new_agg_meta;
DROP TABLE IF EXISTS dt_new_agg_meta_old;
END;
$$;


