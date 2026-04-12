set search_path to fast_food_sales_data;
select count(distinct col1) from food_raw_df;	

/*
 1.oder_id : int
 2.date : mm/dd/yy, 怪符號
 3.item_name : char 第一個字母大寫，去除空格
 4.item_type : char 第一個字母大寫，去除空格
 5.item_price : int
 6.quantity : int
 7.transaction_amount : int
 8.transaction_type : char 第一個字母大寫，去除空格。有null
 9.received_by : char 第一個字母大寫，去除空格
 10.time_of_sale : char 第一個字母大寫，去除空格
 
 Q1.賺多少？哪些月份賺最多？支付時段？假日和平日？
 Q2.（服務人員）在不同時段的處理金額
 Q3.「熱門餐點留存率」，分析某個餐點（item_name）在不同月份是否持續被點購
 Q4.Fastfood 與 Beverages 的配比分析。計算 item_type 的銷售佔比與獲利能力。
 分析點：分析「買漢堡（Fastfood）的人是否一定會配飲料（Beverages）」？這就是餐飲業的 附帶率 (Attachment Rate)。
 Q5.利用 order_id 做 Self-Join，找出同一張訂單中最常出現的組合。
 Q6.
 */

drop table if exists stain_food_df;


CREATE TABLE stain_food_df AS
WITH raw_clening AS (
    SELECT 
        col1::INT AS order_id,
        -- 修正日期格式與引號：處理怪符號並轉為 DATE
        TO_DATE(TRIM(REGEXP_REPLACE(col2, '[^0-9/]', '/', 'g')), 'MM/DD/YYYY') AS sale_date,
        -- 清理字串：首字母大寫並縮減空格
        INITCAP(TRIM(REGEXP_REPLACE(col3, '\s+', ' ', 'g'))) AS item_name,
        INITCAP(TRIM(REGEXP_REPLACE(col4, '\s+', ' ', 'g'))) AS item_type,
        col5::INT AS item_price, 
        col6::INT AS quantity,
        col7::INT AS transaction_amount,
        -- 處理 transaction_type 的空值
        COALESCE(NULLIF(INITCAP(TRIM(REGEXP_REPLACE(col8, '\s+', ' ', 'g'))), ''), 'Other') AS transaction_type,    
        INITCAP(TRIM(REGEXP_REPLACE(col9, '\s+', ' ', 'g'))) AS received_by,
        INITCAP(TRIM(REGEXP_REPLACE(col10, '\s+', ' ', 'g'))) AS time_of_sale
    FROM food_raw_df
    WHERE col1 IS NOT NULL AND col1 != ''
),
feature_engineering AS (
    SELECT *,
        -- 營收分析指標
        CASE 
            WHEN EXTRACT(DOW FROM sale_date) IN (0, 6) THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type,
        TO_CHAR(sale_date, 'YYYY/MM') AS sale_month,      
        -- 商品存續指標 (計算每個商品第一次出現的時間)
        MIN(sale_date) OVER(PARTITION BY item_name) AS item_birthday,  
        -- 異常偵測預備 (計算該商品在全資料的平均單價)
        AVG(item_price) OVER(PARTITION BY item_name) AS avg_item_price,
        -- 去重與稽核 (雖然 ID 唯一，但這行能確保數據純淨)
        ROW_NUMBER() OVER(
            PARTITION BY order_id 
            ORDER BY sale_date DESC
        ) AS row_num
    FROM raw_clening
    WHERE transaction_amount > 0 AND quantity != 0
)
-- 最終擺盤
SELECT 
    *,
    -- 異常價格標籤 (如果單價偏離平均值 20%，標記為異常)
    CASE 
        WHEN item_price > avg_item_price * 1.2 THEN 'High Price Alert'
        WHEN item_price < avg_item_price * 0.8 THEN 'Discount/Low Price'
        ELSE 'Normal'
    END AS price_status
FROM feature_engineering
WHERE row_num = 1;

select * from stain_food_df;

	
	
	