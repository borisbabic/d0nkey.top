CREATE OR REPLACE FUNCTION update_dt_hourly_aggregated_stats(hour_start_raw timestamp without time zone)
    RETURNS VOID
    LANGUAGE plpgsql
    AS $$
DECLARE 
_hour_start timestamp without time zone;
_hour_end timestamp without time zone;
BEGIN
SELECT date_trunc('hour', hour_start_raw) INTO _hour_start;
SELECT _hour_start + '1 hour'::interval INTO _hour_end;
IF _hour_end > now() THEN
    RAISE 'Hour isnt over, cant aggregate yet';
END IF;
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
    format,
    game_type
) AS (
    SELECT f.value, f.game_type FROM public.formats f WHERE f.auto_aggregate
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
        r.slug AS RANK,
        dg.player_deck_id AS deck_id,
        dg.opponent_class,
        dg.player_has_coin,
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
            END), 0), 1) AS winrate,
    SUM(case WHEN turns IS NOT NULL then turns else 0 end) as turns,
    SUM(case WHEN turns IS NOT NULL then 1 else 0 end) as turns_game_count,
    SUM(case WHEN duration IS NOT NULL then duration else 0 end) as duration,
    SUM(case WHEN duration IS NOT NULL then 1 else 0 end) as duration_game_count
FROM
    public.dt_games dg
    INNER JOIN public.deck d ON d.id = dg.player_deck_id
    INNER JOIN agg_formats f ON f.format = dg.format
    INNER JOIN agg_ranks r ON (r.min_rank = 0
            OR dg.player_rank >= min_rank)
        AND (r.max_rank IS NULL
            OR dg.player_rank <= r.max_rank)
        AND (r.min_legend_rank = 0
            OR dg.player_legend_rank >= min_legend_rank)
        AND (r.max_legend_rank IS NULL
            OR dg.player_legend_rank <= r.max_legend_rank)
    WHERE
        dg.inserted_at < _hour_end
        AND dg.inserted_at >= _hour_start
        AND dg.game_type = f.game_type
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
            5,
            GROUPING SETS(3, ()),
            GROUPING SETS(4, ())
),
card_stats AS (
    SELECT
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
        INNER JOIN agg_formats f ON f.format = dg.format
        INNER JOIN agg_ranks r ON (r.min_rank = 0
                OR dg.player_rank >= min_rank)
            AND (r.max_rank IS NULL
                OR dg.player_rank <= r.max_rank)
            AND (r.min_legend_rank = 0
                OR dg.player_legend_rank >= min_legend_rank)
            AND (r.max_legend_rank IS NULL
                OR dg.player_legend_rank <= r.max_legend_rank)
    WHERE
        dg.inserted_at < _hour_end
        AND dg.inserted_at >= _hour_start
        AND dg.opponent_class IS NOT NULL
        AND dg.game_type = f.game_type
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
            GROUPING SETS(4, ()),
            GROUPING SETS(6, ())
),
merged_card_stats AS (
    SELECT
        cs.rank,
        cs.deck_id,
        cs.card_id,
        cs.opponent_class,
        cs.player_has_coin,
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
        INNER JOIN deck_stats ds ON cs.rank = ds.rank
            AND ds.deck_id = cs.deck_id
            AND cs.opponent_class IS NOT DISTINCT FROM ds.opponent_class
            AND cs.player_has_coin IS NOT DISTINCT FROM ds.player_has_coin
            AND cs.format = ds.format
),
grouped_deck_stats AS (
    SELECT
        ds.rank,
        ds.deck_id,
        ds.opponent_class,
        player_has_coin,
        ds.format,
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
GROUP BY
    1,
    2,
    3,
    4,
    5
),
prepared_card_stats AS (
    SELECT
        cs.rank,
        cs.deck_id,
        cs.opponent_class,
        player_has_coin,
        cs.format,
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
        3,
        4,
        5,
        cs.card_id
),
grouped_card_stats AS (
    SELECT
        cs.rank,
        cs.deck_id,
        cs.opponent_class,
        cs.player_has_coin,
        cs.format,
        jsonb_agg(cs.card_stats) AS card_stats
    FROM
        prepared_card_stats cs
    GROUP BY
        1,
        2,
        3,
        4,
        5
)
INSERT INTO dt_intermediate_agg_stats (
    hour_start,
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
    archetype,
    card_stats  
    ) 
SELECT 
    _hour_start, 
    ds.*, 
    d.archetype,
    cs.card_stats
FROM
    grouped_deck_stats ds
    INNER JOIN deck d on d.id = ds.deck_id
    LEFT JOIN grouped_card_stats cs ON cs.rank = ds.rank
        AND cs.format = ds.format
        AND cs.deck_id = ds.deck_id
        AND cs.opponent_class IS NOT DISTINCT FROM ds.opponent_class
        AND cs.player_has_coin IS NOT DISTINCT FROM ds.player_has_coin;

-- UPDATE AGG LOG
-- DO NOT COMMIT THE BELOW COMMENTED OUT
INSERT INTO logs_dt_intermediate_agg (hour_start, formats, ranks, regions, inserted_at, day) SELECT _hour_start, array_agg(DISTINCT(format)), array_agg(DISTINCT(rank)), (SELECT array_agg(code) FROM public.dt_regions WHERE auto_aggregate), now(), null FROM public.dt_intermediate_agg_stats WHERE hour_start = _hour_start;
END;
$$;

