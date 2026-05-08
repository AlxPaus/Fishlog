CREATE MATERIALIZED VIEW mv_daily_catch_stats AS
SELECT 
    DATE_TRUNC('day', c.caught_at) as catch_day,
    fs.water_body_id,
    COUNT(*) as daily_catches,
    SUM(c.weight_grams) as daily_weight,
    MAX(c.weight_grams) as max_daily_weight
FROM catches c
JOIN fishing_sessions fs ON c.session_id = fs.id
GROUP BY DATE_TRUNC('day', c.caught_at), fs.water_body_id;

CREATE UNIQUE INDEX idx_mv_daily_stats_lookup 
ON mv_daily_catch_stats (catch_day, water_body_id);