-- Task 1: Зведена статистика по дням та платформам (Facebook + Google)
-- Вивести середнє, максимум і мінімум для spend, impressions, clicks, value
-- Результат: ad_date, platform, avg/max/min по кожному показнику

WITH unified AS (
    -- Приводимо Facebook-дані до єдиного формату
    SELECT
        ad_date::date AS ad_date,
        'Facebook'::text AS platform,
        spend::numeric       AS spend,
        impressions::bigint  AS impressions,
        clicks::bigint       AS clicks,
        value::numeric       AS value
    FROM public.facebook_ads_basic_daily
    UNION ALL
    -- Приводимо Google-дані до єдиного формату
    SELECT
        ad_date::date AS ad_date,
        'Google'::text AS platform,
        spend::numeric       AS spend,
        impressions::bigint  AS impressions,
        clicks::bigint       AS clicks,
        value::numeric       AS value
    FROM public.google_ads_basic_daily
)
SELECT
    ad_date,
    platform,
    ROUND(AVG(spend)::numeric, 4)       AS avg_spend,
    MAX(spend)                          AS max_spend,
    MIN(spend)                          AS min_spend,
    ROUND(AVG(impressions)::numeric, 4) AS avg_impressions,
    MAX(impressions)                    AS max_impressions,
    MIN(impressions)                    AS min_impressions,
    ROUND(AVG(clicks)::numeric, 4)      AS avg_clicks,
    MAX(clicks)                         AS max_clicks,
    MIN(clicks)                         AS min_clicks,
    ROUND(AVG(value)::numeric, 4)       AS avg_value,
    MAX(value)                          AS max_value,
    MIN(value)                          AS min_value
FROM unified
GROUP BY ad_date, platform
ORDER BY ad_date, platform;
