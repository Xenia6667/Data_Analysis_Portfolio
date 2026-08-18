set search_path to "Brazilian_ECommerce";
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

