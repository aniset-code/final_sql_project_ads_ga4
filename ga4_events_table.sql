-- Task 2: Підготовка даних для побудови звітів у BI-системах
-- Датасет: bigquery-public-data.ga4_obfuscated_sample_ecommerce

-- Створюємо базову CTE-таблицю з подіями за 2021 рік
WITH base AS (
  SELECT
    -- Перетворення event_timestamp з мікросекунд у формат TIMESTAMP
    TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,

    -- Анонімний ідентифікатор користувача
    user_pseudo_id,

    -- session_id отримуємо з параметрів події (event_params)
    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
    ) AS session_id,

    -- Назва події (session_start, view_item, add_to_cart тощо)
    event_name,

    -- Країна користувача
    geo.country AS country,

    -- Тип пристрою (desktop, mobile, tablet)
    device.category AS device_category,

    -- Джерело трафіку (google, direct, bing...)
    traffic_source.source AS source,

    -- Medium трафіку (organic, cpc, referral...)
    traffic_source.medium AS medium,

    -- Назва кампанії
    traffic_source.name AS campaign

  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

  -- Відфільтровуємо події лише за 2021 рік
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'

    -- Вибираємо тільки події, що входять до воронки
    AND event_name IN (
      'session_start',       -- початок сесії
      'view_item',           -- перегляд товару
      'add_to_cart',         -- додавання в кошик
      'begin_checkout',      -- початок оформлення замовлення
      'add_shipping_info',   -- додавання інформації про доставку
      'add_payment_info',    -- введення платіжних даних
      'purchase'             -- покупка
    )
)

-- Виводимо фінальний набір полів для BI / подальшої аналітики
SELECT
    event_timestamp,    -- дата та час події
    user_pseudo_id,     -- користувач
    session_id,         -- ідентифікатор сесії
    event_name,         -- тип події
    country,            -- країна
    device_category,    -- тип пристрою
    source,             -- джерело трафіку
    medium,             -- medium трафіку
    campaign            -- назва кампанії
FROM base
ORDER BY event_timestamp
LIMIT 1000;             -- обмеження результуючої вибірки для наочності
