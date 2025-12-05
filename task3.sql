-- Task 3: кампанія з найбільшим тижневим value
-- Визначаємо кампанію, яка принесла найбільшу суму value за один тиждень

WITH facebook_data AS (
    SELECT 
        fab.ad_date,
        fc.campaign_name,
        COALESCE(fab.value, 0) AS value
    FROM public.facebook_ads_basic_daily AS fab
    LEFT JOIN public.facebook_campaign AS fc 
        ON fab.campaign_id = fc.campaign_id
),
google_data AS (
    SELECT 
        gad.ad_date,
        gad.campaign_name,
        COALESCE(gad.value, 0) AS value
    FROM public.google_ads_basic_daily AS gad
),
union_stock AS (
    SELECT * FROM facebook_data
    UNION ALL
    SELECT * FROM google_data
),
weekly AS (
    -- Агрегація даних по тижнях
    SELECT
        DATE_TRUNC('week', ad_date)::date AS week_start,
        campaign_name,
        SUM(value) AS weekly_value
    FROM union_stock
    GROUP BY week_start, campaign_name
)
-- Беремо тільки кампанію з найбільшим weekly_value
SELECT 
    week_start,
    campaign_name,
    weekly_value
FROM weekly
ORDER BY weekly_value DESC
LIMIT 1;
