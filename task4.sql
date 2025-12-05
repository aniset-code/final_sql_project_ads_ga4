-- Task 4: кампанія з найбільшим місячним приростом охоплення (reach)
-- Рахуємо різницю reach поточного місяця до попереднього для кожної кампанії

WITH facebook_data AS (
    SELECT 
        fab.ad_date,
        fc.campaign_name,
        COALESCE(fab.reach, 0) AS reach
    FROM public.facebook_ads_basic_daily AS fab
    LEFT JOIN public.facebook_campaign AS fc 
        ON fab.campaign_id = fc.campaign_id
),
google_data AS (
    SELECT 
        gad.ad_date,
        gad.campaign_name,
        COALESCE(gad.reach, 0) AS reach
    FROM public.google_ads_basic_daily AS gad
),
union_stock AS (
    SELECT * FROM facebook_data
    UNION ALL
    SELECT * FROM google_data
),
monthly AS (
    -- Сумарне охоплення по кожній кампанії за місяць
    SELECT
        DATE_TRUNC('month', ad_date)::date AS month_start,
        campaign_name,
        SUM(reach) AS monthly_reach
    FROM union_stock
    GROUP BY month_start, campaign_name
),
with_lag AS (
    -- Додаємо значення попереднього місяця для кожної кампанії
    SELECT
        campaign_name,
        month_start,
        monthly_reach,
        LAG(monthly_reach) OVER (PARTITION BY campaign_name ORDER BY month_start) AS prev_month_reach
    FROM monthly
)
-- Рахуємо приріст = поточний - попередній
SELECT
    campaign_name,
    month_start,
    monthly_reach - prev_month_reach AS reach_growth
FROM with_lag
WHERE prev_month_reach IS NOT NULL
ORDER BY reach_growth DESC
LIMIT 1;
