set search_path to "Brazilian_ECommerce";
/*
    * product_id / product_category
    * total_revenue
    * total_qty
    * avg_price
    * avg_review_score
    * avg_freight_ratio（freight_value / price）
*/

DROP TABLE IF EXISTS mart_product_performance;

CREATE TABLE mart_product_performance AS
WITH order_detail AS (
    -- 先在「訂單 × 商品」粒度上，把 items + payments + reviews 聚合，
    -- 避免 fan-out 讓金額被重複放大
    SELECT 
        oi.order_id,
        oi.product_id,
        SUM(oi.price)          AS price,
        SUM(oi.freight_value)  AS freight_value,
        SUM(op.payment_value)  AS payment_value,
        SUM(oi.order_item_id)  AS total_qty,        -- 每筆訂單中這個 product 的數量
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
    -- 每個 product_id 對應到一個英文分類
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
),
product_agg AS (
    -- 產品粒度聚合：一列 = 一個 product
    SELECT
        p.product_id,
        p.product_category_name_english AS product_category,
        SUM(od.price)                  AS total_product_revenue,   -- 不含運費
        SUM(od.freight_value)          AS total_freight,
        SUM(od.payment_value)          AS total_revenue,           -- 含運費
        SUM(od.total_qty)              AS total_qty,
        AVG(od.price)                  AS avg_price,               -- 每筆訂單內該 product 的平均 price
        AVG(od.review_score)           AS avg_review_score,
        AVG(od.freight_value / NULLIF(od.price, 0)) AS avg_freight_ratio
    FROM order_detail od
    JOIN product p
        ON od.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_category_name_english
)
SELECT *
FROM product_agg;

-- 檢查結果
SELECT * 
FROM mart_product_performance
ORDER BY total_revenue DESC
LIMIT 50;