set search_path to "Brazilian_ECommerce";

DROP TABLE IF EXISTS salesKPI;
CREATE TABLE salesKPI AS
WITH customerorder AS (
    SELECT 
        c.customer_id, 
        c.customer_unique_id,
        o.order_id, 
        o.order_status,
        CAST(o.order_purchase_timestamp AS TIMESTAMP) AS real_time, 
        DATE(CAST(o.order_purchase_timestamp AS TIMESTAMP)) as sale_day,
        -- ✅ PostgreSQL 語法
        EXTRACT(DOW FROM CAST(o.order_purchase_timestamp AS TIMESTAMP)) as weekday,  -- 0=Sun
        EXTRACT(HOUR FROM CAST(o.order_purchase_timestamp AS TIMESTAMP)) as hour     -- 0-23 
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered' 
),
order_payment AS (
    SELECT
        order_id,
        SUM(CAST(payment_value AS DECIMAL(10,2))) AS total_payment
    FROM olist_order_payments_dataset
    GROUP BY order_id
)
SELECT 
    co.sale_day,   
    COUNT(DISTINCT co.order_id) AS total_orders,
    COUNT(DISTINCT co.customer_unique_id) as unique_customers,
    SUM(op.total_payment) AS daily_revenue,    
    AVG(op.total_payment) AS avg_order_value
FROM customerorder co
JOIN order_payment op ON co.order_id = op.order_id  
GROUP BY co.sale_day
ORDER BY co.sale_day DESC;

SELECT * FROM salesKPI LIMIT 5;