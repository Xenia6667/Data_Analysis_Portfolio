/*
1. olist_orders_dataset (訂單主表)
customer_zip_code_prefix  int
customer_city 小寫
customer_state 都大寫

2. olist_order_items_dataset (訂單明細/商品項目)
geolocation_zip_code_prefix int
geolocation_lat real(有正負的小數點)
geolocation_lng real(有正負的小數點)
geolocation_city 小寫，要統一字母
geolocation_state 大寫，要統一字母

3. olist_order_payments_dataset (支付方式與金額)
order_item_id int
shipping_limit_date  yyyy-mm-dd 00:00:00
price 小數
freight_value 小數

4. olist_customers_dataset (客戶基本資料)
payment_sequential int
payment_type 小寫 保留底線
payment_installments int
payment_value 小數

5. olist_sellers_dataset (賣家基本資料)
review_score int
review_comment_title  文字，很多空直，可以不用抓取
review_comment_message  文字，很多空直，可以不用抓取
review_creation_date yyyy-mm-dd 00:00:00
review_answer_timestamp yyyy-mm-dd 00:00:00

6. olist_products_dataset (產品屬性)
order_status 小寫
order_purchase_timestamp yyyy-mm-dd 00:00:00
order_approved_at yyyy-mm-dd 00:00:00
order_delivered_carrier_date  yyyy-mm-dd 00:00:00 有空直
order_delivered_customer_date yyyy-mm-dd 00:00:00 有空直
order_estimated_delivery_date yyyy-mm-dd 00:00:00 

7. product_category_name_translation (類別名稱中英/葡英對照)
product_category_name 小寫 保留底線
product_name_lenght 整數
product_description_lenght 整數
product_photos_qty 整數
product_weight_g  整數
product_length_cm 整數
product_height_cm 整數
product_width_cm 整數

8. olist_order_reviews_dataset (客戶評價與回饋)
seller_zip_code_prefix 整數
seller_city 小寫
seller_state 大寫

9. olist_geolocation_dataset (地理座標/郵遞區號)
product_category_name 小寫 保留底線
product_category_name_english 小寫 保留底線
 */

set search_path to "Brazilian_ECommerce";

-- clean all data
with clean_customers as (
    -- 步驟一：先把付款表整理好，裝進名叫 clean_payments 的備料碗裡
    SELECT order_id, SUM(payment_value) AS total
    FROM payments
    GROUP BY order_id
)

-- 建立一張「分析專用表」，只抓需要的欄位並同時轉型
CREATE TABLE clean_customers AS
SELECT 
	customer_id, 
	customer_unique_id, 
	customer_zip_code_prefix, 
	customer_city, 
	customer_state
FROM "Brazilian_ECommerce".olist_customers_dataset;
    order_id,
    CAST(order_purchase_timestamp AS TIMESTAMP) as order_date,
    CAST(price AS DECIMAL(10,2)) as price,
    COALESCE(product_category_name, 'unclassified') as category -- 處理缺失值



