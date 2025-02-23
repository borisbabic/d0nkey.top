CREATE OR REPLACE FUNCTION update_dt_daily_aggregated_stats(day_arg date)
    RETURNS VOID
    LANGUAGE plpgsql
    AS $$
DECLARE 
_num_hours int;
BEGIN
SELECT count(*) FROM (SELECT DISTINCT(hour_start) as hour_start FROM dt_intermediate_agg_stats) a WHERE a.hour_start IS NOT NULL and a.hour_start::date = day_arg into _num_hours;
IF _num_hours < 24 THEN
    RAISE 'Not enough hours. Got %s hours for day %s', _num_hours, day_arg;
END IF;
WITH
	DAILY_CARD_STATS AS (
		SELECT
			RANK,
			DECK_ID,
			PLAYER_HAS_COIN,
			OPPONENT_CLASS,
			FORMAT,
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
			(CARD_STATS -> 'card_id')::INT AS CARD_ID,
			(CARD_STATS -> 'kept_total')::INT AS KEPT_TOTAL,
			(CARD_STATS -> 'mull_total')::INT AS MULL_TOTAL,
			(CARD_STATS -> 'drawn_total')::INT AS DRAWN_TOTAL,
			(CARD_STATS -> 'kept_impact')::FLOAT AS KEPT_IMPACT,
			(CARD_STATS -> 'mull_impact')::FLOAT AS MULL_IMPACT,
			(CARD_STATS -> 'drawn_impact')::FLOAT AS DRAWN_IMPACT,
			(CARD_STATS -> 'kept_percent')::FLOAT AS KEPT_PERCENT,
			(CARD_STATS -> 'tossed_total')::INT AS TOSSED_TOTAL,
			(CARD_STATS -> 'tossed_impact')::FLOAT AS TOSSED_IMPACT
		FROM
			(
				SELECT
					RANK,
					DECK_ID,
					PLAYER_HAS_COIN,
					OPPONENT_CLASS,
					HS.FORMAT,
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
				WHERE
					CAST(HOUR_START as date) = day_arg
			) ds
	),
	PREPARED_DECK_STATS AS (
		SELECT
			RANK,
			DECK_ID,
			OPPONENT_CLASS,
			PLAYER_HAS_COIN,
			FORMAT,
			SUM(TOTAL) AS TOTAL,
			SUM(WINS) AS WINS,
			SUM(LOSSES) AS LOSSES,
			CASE WHEN SUM(total) > 0 THEN SUM(WINS) / SUM(TOTAL) ELSE 0 END AS WINRATE,
			CASE
				WHEN SUM(TURNS_GAME_COUNT) > 0 THEN SUM(TOTAL_TURNS) / SUM(TURNS_GAME_COUNT)
				ELSE 0
			END AS TURNS,
			SUM(TOTAL_TURNS) AS TOTAL_TURNS,
			SUM(TURNS_GAME_COUNT) AS TURNS_GAME_COUNT,
			CASE
				WHEN SUM(DURATION_GAME_COUNT) > 0 THEN SUM(TOTAL_DURATION) / SUM(DURATION_GAME_COUNT)
				ELSE 0
			END AS DURATION,
			SUM(TOTAL_DURATION) AS TOTAL_DURATION,
			SUM(DURATION_GAME_COUNT) AS DURATION_GAME_COUNT,
			CASE WHEN SUM(TOTAL) > 0 AND SUM(DURATION) > 0 THEN
				( SUM(DURATION_GAME_COUNT) * 3600::float / SUM(DURATION)) * (2 * (SUM(WINRATE * TOTAL) / SUM(TOTAL))  - 1)
			ELSE
				0
			END as climbing_speed
		FROM
			PUBLIC.dt_intermediate_agg_stats HS
		WHERE
			CAST(HOUR_START as date) = day_arg
		GROUP BY
			1,
			2,
			3,
			4,
			5
	),
	PREPARED_DAILY_CARD_STATS AS (
		SELECT
			RANK,
			DECK_ID,
			OPPONENT_CLASS,
			PLAYER_HAS_COIN,
			FORMAT,
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
			DAILY_CARD_STATS CS
		GROUP BY
			1,
			2,
			3,
			4,
			5,
			CS.CARD_ID
	),
	GROUPED_CARD_STATS AS (
		SELECT
			RANK,
			DECK_ID,
			PLAYER_HAS_COIN,
			OPPONENT_CLASS,
			FORMAT,
			JSONB_AGG(CARD_STATS) AS CARD_STATS
		FROM
			PREPARED_DAILY_CARD_STATS CS
		GROUP BY
			1,
			2,
			3,
			4,
			5
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
INSERT INTO dt_intermediate_agg_stats (
    day,
    rank,
    deck_id,
    opponent_class,
    player_has_coin,
    format,
    total,
    wins,
    losses,
    winrate,
    turns,
    total_turns,
    turns_game_count,
    duration,
    total_duration,
    duration_game_count,
    climbing_speed,
    card_stats  
    ) 
SELECT 
    day_arg, 
    ds.*, 
    cs.card_stats
FROM
    prepared_deck_stats ds
    LEFT JOIN grouped_card_stats cs ON cs.rank = ds.rank
        AND cs.format = ds.format
        AND cs.deck_id = ds.deck_id
        AND cs.opponent_class IS NOT DISTINCT FROM ds.opponent_class
        AND cs.player_has_coin IS NOT DISTINCT FROM ds.player_has_coin;

-- UPDATE AGG LOG
-- DO NOT COMMIT THE BELOW COMMENTED OUT
INSERT INTO logs_dt_intermediate_agg (hour_start, formats, ranks, regions, inserted_at, day) SELECT null, array_agg(DISTINCT(format)), array_agg(DISTINCT(rank)), (SELECT array_agg(code) FROM public.dt_regions WHERE auto_aggregate), now(), day_arg FROM public.dt_intermediate_agg_stats WHERE day = day;
END;
$$;

