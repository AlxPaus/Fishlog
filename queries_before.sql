-- name: q1_top_pike_lakes
SELECT w.name, COUNT(*) as catch_count, AVG(c.weight_grams) as avg_weight
FROM catches c
JOIN fish_species s ON c.species_id = s.id
JOIN fishing_sessions fs ON c.session_id = fs.id
JOIN water_bodies w ON fs.water_body_id = w.id
WHERE s.common_name = 'Pike' AND c.caught_at >= NOW() - INTERVAL '1 year'
GROUP BY w.name
ORDER BY catch_count DESC
LIMIT 5;

-- name: q2_heaviest_catch_per_region
WITH RankedCatches AS (
    SELECT 
        r.name as region_name, 
        a.nickname as angler_name, 
        c.weight_grams, 
        s.common_name as species,
        ROW_NUMBER() OVER(PARTITION BY r.id ORDER BY c.weight_grams DESC) as rn
    FROM catches c
    JOIN anglers a ON c.angler_id = a.id
    JOIN fish_species s ON c.species_id = s.id
    JOIN fishing_sessions fs ON c.session_id = fs.id
    JOIN water_bodies w ON fs.water_body_id = w.id
    JOIN regions r ON w.region_id = r.id
)
SELECT region_name, angler_name, weight_grams, species
FROM RankedCatches
WHERE rn = 1;

-- name: q3_recent_expert_catches
SELECT a.nickname, w.name as lake_name, s.common_name, c.weight_grams, c.caught_at
FROM catches c
JOIN anglers a ON c.angler_id = a.id
JOIN fish_species s ON c.species_id = s.id
JOIN fishing_sessions fs ON c.session_id = fs.id
JOIN water_bodies w ON fs.water_body_id = w.id
WHERE a.experience_level = 'expert'
ORDER BY c.caught_at DESC
LIMIT 100;

-- name: q4_monthly_catch_stats
SELECT 
    DATE_TRUNC('month', caught_at) as catch_month,
    COUNT(*) as total_catches,
    SUM(weight_grams) as total_weight,
    MAX(weight_grams) as max_weight
FROM catches
GROUP BY DATE_TRUNC('month', caught_at)
ORDER BY catch_month DESC;

-- name: q5_lakes_without_trophies
SELECT w.name
FROM water_bodies w
WHERE NOT EXISTS (
    SELECT 1 
    FROM fishing_sessions fs 
    JOIN catches c ON c.session_id = fs.id
    WHERE fs.water_body_id = w.id AND c.weight_grams > 10000
);

-- name: q6_angler_running_total
SELECT 
    a.nickname, 
    c.caught_at, 
    c.weight_grams,
    SUM(c.weight_grams) OVER (PARTITION BY a.id ORDER BY c.caught_at) as running_total_weight
FROM catches c
JOIN anglers a ON c.angler_id = a.id
ORDER BY a.id, c.caught_at
LIMIT 500;