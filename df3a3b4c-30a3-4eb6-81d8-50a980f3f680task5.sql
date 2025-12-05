-- Task 5 : найдовший безперервний щоденний показ adset_name

WITH fb AS (
  SELECT fab.ad_date::date AS ad_date, fa.adset_name
  FROM public.facebook_ads_basic_daily fab
  JOIN public.facebook_adset fa ON fa.adset_id = fab.adset_id
),
gg AS (
  SELECT gad.ad_date::date AS ad_date, gad.adset_name
  FROM public.google_ads_basic_daily gad
),

-- 1) Об'єднуємо й беремо унікальні дні
all_days AS (
  SELECT adset_name, ad_date FROM fb
  UNION
  SELECT adset_name, ad_date FROM gg
),

-- 2) Нумерація днів всередині adset
numbered AS (
  SELECT
    adset_name,
    ad_date,
    ROW_NUMBER() OVER (PARTITION BY adset_name ORDER BY ad_date) AS rn
  FROM (
    SELECT DISTINCT adset_name, ad_date FROM all_days
  ) d
),

-- 3) Ключ серії: дата мінус row_number
grouped AS (
  SELECT
    adset_name,
    ad_date,
    ad_date - rn * INTERVAL '1 day' AS grp
  FROM numbered
),

-- 4) Довжина кожної серії
streaks AS (
  SELECT
    adset_name,
    MIN(ad_date) AS start_date,
    MAX(ad_date) AS end_date,
    COUNT(*) AS streak_length
  FROM grouped
  GROUP BY adset_name, grp
)

-- 5) Найдовша серія
SELECT adset_name, start_date, end_date, streak_length
FROM streaks
ORDER BY streak_length DESC
LIMIT 1;
