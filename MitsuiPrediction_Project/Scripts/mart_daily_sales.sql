set search_path to "Brazilian_ECommerce";
-- 1. mart_daily_sales
/*
 *date（來自 order_purchase_timestamp）

customer_state

product_category

orders_count

revenue（sum price）

freight_value

avg_delivery_days（delivered_date - purchase_timestamp）

avg_review_score（如果想合併 reviews）
 */
DROP TABLE IF EXISTS geo_clean;
CREATE TABLE geo_clean AS
SELECT
    geolocation_zip_code_prefix,
    AVG(geolocation_lat) AS geolocation_lat,
    AVG(geolocation_lng) AS geolocation_lng
FROM olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix;


SELECT 
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM olist_orders_dataset
WHERE 
    order_status = 'delivered'
    AND (
        order_purchase_timestamp = ''::text
        OR order_delivered_customer_date = ''::text
    )
LIMIT 50;

-- 1. 經緯度清理表：每個 zip 一組代表性經緯度
DROP TABLE IF EXISTS geo_clean;
CREATE TABLE geo_clean AS
SELECT
    geolocation_zip_code_prefix,
    AVG(geolocation_lat) AS geolocation_lat,
    AVG(geolocation_lng) AS geolocation_lng
FROM olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix;

drop table if exists mart_daily_sales;
-- 2. 日粒度營運表：mart_daily_sales
DROP TABLE IF EXISTS mart_daily_sales;
CREATE TABLE mart_daily_sales AS
WITH customerorder AS (
    SELECT 
        c.customer_id, 
        c.customer_unique_id, 
        c.customer_zip_code_prefix, 
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
        -- 如果只想看已送達的訂單，可以用這句
        o.order_status = 'delivered'
        -- 不再用 delivered_date <> '' 把訂單排掉，只在上面用 CASE 處理
),
order_detail AS (
    -- 先把 items + payments + reviews 聚合到「訂單 × 商品」粒度，避免 fan-out
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
product AS (
    -- 每個 product 對應到一個英文分類
    SELECT
        p.product_id,
        p.product_category_name,
        pn.product_category_name_english
    FROM olist_products_dataset p
    LEFT JOIN product_category_name_translation pn
        ON p.product_category_name = pn.product_category_name
    GROUP BY 
        p.product_id,
        p.product_category_name,
        pn.product_category_name_english
)
SELECT 
    co.order_date,
    co.customer_state,
    p.product_category_name_english AS product_category,
    co.customer_lat,
    co.customer_lng,
    COUNT(DISTINCT co.order_id) AS orders_count,
    SUM(od.price)          AS revenue_product,  -- 產品營收（不含運費）
    SUM(od.freight_value)  AS revenue_freight,  -- 運費總額
    SUM(od.payment_value)  AS revenue_total,    -- 顧客支付總額
    AVG(co.delivery_days)  AS avg_delivery_days, -- 只對有值的訂單取平均
    AVG(od.review_score)   AS avg_review_score
FROM customerorder co
JOIN order_detail od 
    ON co.order_id = od.order_id
JOIN product p 
    ON od.product_id = p.product_id
GROUP BY 
    co.order_date,
    co.customer_state,
    p.product_category_name_english,
    co.customer_lat,
    co.customer_lng;

-- 檢查結果
SELECT * FROM mart_daily_sales
ORDER BY order_date desc
LIMIT 50;

SELECT * FROM olist_orders_dataset 
ORDER BY order_purchase_timestamp desc
LIMIT 50;