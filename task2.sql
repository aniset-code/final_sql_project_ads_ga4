-- Task 2: 5 днів з найбільшим ROMI (Google + Facebook разом)
-- ROMI = value / spend

WITH union_stock AS (
    -- Об'єднуємо Facebook і Google у єдиний набір
    SELECT 
        fab.ad_date,
        COALESCE(fab.spend, 0) AS spend,
        COALESCE(fab.value, 0) AS value
    FROM public.facebook_ads_basic_daily fab
    UNION ALL
    SELECT 
        gad.ad_date,
        COALESCE(gad.spend, 0) AS spend,
        COALESCE(gad.value, 0) AS value
    FROM public.google_ads_basic_daily gad
),
daily_romi AS (
    -- Розрахунок ROMI по кожному дню
    SELECT
        ad_date,
        SUM(value)::numeric / NULLIF(SUM(spend), 0) AS romi
    FROM union_stock
    GROUP BY ad_date
)
SELECT 
    ad_date,
    ROUND(romi, 4) AS romi
FROM daily_romi
WHERE romi IS NOT NULL
ORDER BY romi DESC
LIMIT 5;
