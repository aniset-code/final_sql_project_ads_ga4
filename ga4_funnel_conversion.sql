-- Task 3: Розрахунок конверсій у воронці від session_start до purchase
-- Датасет: bigquery-public-data.ga4_obfuscated_sample_ecommerce

-- Крок 1. Готуємо базову таблицю подій з унікальним ключем сесії
WITH base_events AS (
  SELECT
    -- Дата старту події (на рівні дня)
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,

    -- Анонімний ідентифікатор користувача
    user_pseudo_id,

    -- Унікальний ключ сесії (комбінація користувача та session_id)
    CONCAT(
      user_pseudo_id, '-',
      CAST((
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key = 'ga_session_id'
      ) AS STRING)
    ) AS session_key,

    -- Назва події (session_start, add_to_cart, begin_checkout, purchase)
    event_name,

    -- Джерело/канал трафіку
    traffic_source.source AS source,
    traffic_source.medium AS medium,
    traffic_source.name   AS campaign

  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

  -- (опційно) обмежуємося лише 2021 роком, як у Task 2
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'

    -- Вибираємо тільки події, що нас цікавлять у воронці
    AND event_name IN (
      'session_start',
      'add_to_cart',
      'begin_checkout',
      'purchase'
    )
),

-- Крок 2. Агрегуємо сесії та рахуємо кількість сесій з кожним типом події
sessions_agg AS (
  SELECT
    event_date,
    source,
    medium,
    campaign,

    -- Кількість унікальних сесій з подією session_start
    COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN session_key END) AS session_starts,

    -- Кількість унікальних сесій, де був add_to_cart
    COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN session_key END) AS add_to_cart_sessions,

    -- Кількість унікальних сесій, де був begin_checkout
    COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN session_key END) AS checkout_sessions,

    -- Кількість унікальних сесій, де була покупка
    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_key END) AS purchase_sessions

  FROM base_events
  GROUP BY event_date, source, medium, campaign
)

-- Крок 3. Розраховуємо конверсії у воронці
SELECT
  event_date,
  source,
  medium,
  campaign,

  -- Кількість унікальних сесій (user_sessions_count)
  session_starts AS user_sessions_count,

  -- Конверсія від візиту до додавання в кошик
  SAFE_DIVIDE(add_to_cart_sessions, session_starts) AS visit_to_cart,

  -- Конверсія від візиту до початку оформлення замовлення
  SAFE_DIVIDE(checkout_sessions, session_starts) AS visit_to_checkout,

  -- Конверсія від візиту до покупки
  SAFE_DIVIDE(purchase_sessions, session_starts) AS visit_to_purchase

FROM sessions_agg
ORDER BY event_date;
