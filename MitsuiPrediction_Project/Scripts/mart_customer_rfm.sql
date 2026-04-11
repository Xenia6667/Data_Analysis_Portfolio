set search_path to "Brazilian_ECommerce";
--1
SELECT * FROM olist_customers_dataset LIMIT 10;
SELECT count(*) FROM olist_customers_dataset;
--2
SELECT * FROM olist_geolocation_dataset LIMIT 10;
SELECT count(*) FROM olist_geolocation_dataset;
--3
SELECT * FROM olist_order_items_dataset LIMIT 10;
SELECT count(*) FROM olist_order_items_dataset;
--4
SELECT * FROM olist_order_payments_dataset LIMIT 10;
SELECT count(*) FROM olist_order_payments_dataset;
--5
SELECT * FROM olist_order_reviews_dataset LIMIT 10;
SELECT count(*) FROM olist_order_reviews_dataset;
--6
SELECT * FROM olist_orders_dataset LIMIT 10;
SELECT count(*) FROM olist_orders_dataset;
--7
SELECT * FROM olist_products_dataset LIMIT 10;
SELECT count(*) FROM olist_products_dataset;
--8
SELECT * FROM olist_sellers_dataset LIMIT 10;
SELECT count(*) FROM olist_sellers_dataset;
--9
SELECT * FROM product_category_name_translation LIMIT 10;
SELECT count(*) FROM product_category_name_translation;

/*
    * customer_unique_id
    * first_purchase_date
    * last_purchase_date
    * order_count
    * total_revenue
    * avg_order_value
    * city, state
    * R / F / M 分數（由 SQL 或 Python 算好）
*/

DROP TABLE IF EXISTS mart_customer_rfm;

CREATE TABLE mart_customer_rfm AS
WITH customerorder AS (
    SELECT 
        c.customer_id, 
        c.customer_unique_id, 
        c.customer_zip_code_prefix, 
        c.customer_city,
        c.customer_state, 
        o.order_id, 
        o.order_status,
        o.order_purchase_timestamp AS real_time, 
        o.order_purchase_timestamp::date AS order_date,
        -- 保留送達日期為空字串的訂單，但轉成 NULL
        CASE 
            WHEN o.order_delivered_customer_date = '' THEN NULL
            ELSE o.order_delivered_customer_date::timestamp::date
        END AS delivered_date,
        CASE 
            WHEN o.order_delivered_customer_date = '' THEN NULL
            ELSE (o.order_delivered_customer_date::timestamp::date 
                  - o.order_purchase_timestamp::date)
        END AS delivery_days,
        gc.geolocation_lat AS customer_lat,
        gc.geolocation_lng AS customer_lng
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o 
        ON c.customer_id = o.customer_id
    LEFT JOIN geo_clean gc
        ON c.customer_zip_code_prefix = gc.geolocation_zip_code_prefix
    WHERE 
        o.order_status = 'delivered'
),
order_detail AS (
    -- 先在「訂單 × 商品」粒度聚合 items + payments + reviews，避免 fan-out
    SELECT 
        oi.order_id,
        oi.product_id,
        SUM(oi.price)          AS price,
        SUM(oi.freight_value)  AS freight_value,
        SUM(op.payment_value)  AS payment_value,
        AVG(oreview.review_score) AS review_score
    FROM olist_order_items_dataset oi
    JOIN olist_order_payments_dataset op
        ON oi.order_id = op.order_id
    JOIN olist_order_reviews_dataset oreview
        ON oi.order_id = oreview.order_id
    GROUP BY 
        oi.order_id,
        oi.product_id
),
customer_agg AS (
    -- 顧客粒度聚合出 R、F、M 所需原始指標
    SELECT
        co.customer_unique_id,
        MIN(co.order_date)                       AS first_purchase_date,
        MAX(co.order_date)                       AS last_purchase_date,
        COUNT(DISTINCT co.order_id)              AS frequency,       -- F: 訂單數
        SUM(od.payment_value)                    AS monetary,        -- M: 總消費金額
        SUM(od.payment_value)
          / NULLIF(COUNT(DISTINCT co.order_id), 0) AS avg_order_value,
        co.customer_state,
        co.customer_city
    FROM customerorder co
    JOIN order_detail od 
        ON co.order_id = od.order_id
    GROUP BY
        co.customer_unique_id,
        co.customer_state,
        co.customer_city
),
rfm_with_recency AS (
    -- 用資料中最新的 order_date + 1 當基準日，算 recency_days
    SELECT
        customer_unique_id,
        first_purchase_date,
        last_purchase_date,
        (
          (SELECT MAX(order_date) + 1 FROM customerorder)
          - last_purchase_date
        ) AS recency_days,                       -- R 原始值（天數，越小越好）
        frequency,
        monetary,
        avg_order_value,
        customer_state,
        customer_city
    FROM customer_agg
)
SELECT
    customer_unique_id,
    first_purchase_date,
    last_purchase_date,
    recency_days,
    frequency,
    monetary,
    avg_order_value,
    customer_state,
    customer_city
FROM rfm_with_recency;
-- 檢查結果
SELECT * FROM mart_customer_rfm
LIMIT 50;