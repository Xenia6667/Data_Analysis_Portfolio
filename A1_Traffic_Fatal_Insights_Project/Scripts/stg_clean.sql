-- ============================================================
-- stg_clean.sql
-- Source : npa_tma1 (raw import)
-- Output : stg_accidents (cleaned staging table)
-- ============================================================

DROP TABLE IF EXISTS stg_accidents;

CREATE TABLE stg_accidents AS
SELECT

    -- [1] 時間維度
    "發生年度"::integer                                                             AS accident_year,
    "發生月份"::integer                                                             AS accident_month,
    TO_DATE("發生日期"::text, 'YYYYMMDD')                                           AS accident_date,
    TO_TIMESTAMP(LPAD("發生時間"::text, 6, '0'), 'HH24MISS')::time                  AS accident_time,
    EXTRACT(HOUR FROM
        TO_TIMESTAMP(LPAD("發生時間"::text, 6, '0'), 'HH24MISS')::time
    )::integer                                                                      AS accident_hour,

    -- [2] 事故基本資訊
    NULLIF(TRIM("事故類別名稱"), '')                                                 AS accident_category,
    NULLIF(TRIM("處理單位名稱警局層"), '')                                            AS police_unit,
    NULLIF(TRIM("發生地點"), '')                                                     AS location,

    -- [3] 環境條件
    NULLIF(TRIM("天候名稱"), '')                                                     AS weather,
    NULLIF(TRIM("光線名稱"), '')                                                     AS lighting,
    NULLIF(TRIM("道路類別-第1當事者-名稱"), '')                                       AS road_type_party1,
    NULLIF("速限-第1當事者"::text, '')::integer                                      AS speed_limit,
    NULLIF(TRIM("道路型態大類別名稱"), '')                                            AS road_form_major,
    NULLIF(TRIM("道路型態子類別名稱"), '')                                            AS road_form_minor,
    NULLIF(TRIM("事故位置大類別名稱"), '')                                            AS accident_location_major,
    NULLIF(TRIM("事故位置子類別名稱"), '')                                            AS accident_location_minor,

    -- [4] 路面狀況
    NULLIF(TRIM("路面狀況-路面鋪裝名稱"), '')                                         AS road_pavement,
    NULLIF(TRIM("路面狀況-路面狀態名稱"), '')                                         AS road_condition,
    NULLIF(TRIM("路面狀況-路面缺陷名稱"), '')                                         AS road_defect,

    -- [5] 道路障礙
    NULLIF(TRIM("道路障礙-障礙物名稱"), '')                                           AS road_obstacle,
    NULLIF(TRIM("道路障礙-視距品質名稱"), '')                                         AS visibility_quality,
    NULLIF(TRIM("道路障礙-視距名稱"), '')                                             AS visibility,

    -- [6] 號誌
    NULLIF(TRIM("號誌-號誌種類名稱"), '')                                             AS signal_type,
    NULLIF(TRIM("號誌-號誌動作名稱"), '')                                             AS signal_action,

    -- [7] 車道劃分設施
    NULLIF(TRIM("車道劃分設施-分向設施大類別名稱"), '')                                AS lane_divider_major,
    NULLIF(TRIM("車道劃分設施-分向設施子類別名稱"), '')                                AS lane_divider_minor,
    NULLIF(TRIM("車道劃分設施-分道設施-快車道或一般車道間名"), '')                      AS lane_marking_fast,
    NULLIF(TRIM("車道劃分設施-分道設施-快慢車道間名稱"), '')                           AS lane_marking_fast_slow,
    NULLIF(TRIM("車道劃分設施-分道設施-路面邊線名稱"), '')                             AS lane_marking_edge,

    -- [8] 事故類型
    NULLIF(TRIM("事故類型及型態大類別名稱"), '')                                      AS accident_type_major,
    NULLIF(TRIM("事故類型及型態子類別名稱"), '')                                      AS accident_type_minor,

    -- [9] 肇因 (主要)
    NULLIF(TRIM("肇因研判大類別名稱-主要"), '')                                       AS cause_major,
    NULLIF(TRIM("肇因研判子類別名稱-主要"), '')                                       AS cause_minor,

    -- [10] 死亡受傷人數拆解 (原格式: 死亡1 受傷0)
    REGEXP_REPLACE(SPLIT_PART("死亡受傷人數", ';', 1), '[^0-9]', '', 'g')::integer   AS death_count,
    REGEXP_REPLACE(SPLIT_PART("死亡受傷人數", ';', 2), '[^0-9]', '', 'g')::integer   AS injury_count,

    -- [11] 當事者資訊
    "當事者順位"::integer                                                            AS party_order,
    NULLIF(TRIM("當事者區分-類別-大類別名稱-車種"), '')                                AS party_type_major,
    NULLIF(TRIM("當事者區分-類別-子類別名稱-車種"), '')                                AS party_type_minor,
    NULLIF(TRIM("當事者屬-性-別名稱"), '')                                            AS gender,
    NULLIF("當事者事故發生時年齡"::text, '')::integer                                 AS age,
    CASE
        WHEN NULLIF("當事者事故發生時年齡"::text, '')::integer IS NULL THEN NULL
        WHEN "當事者事故發生時年齡"::integer < 18  THEN '未成年(<18)'
        WHEN "當事者事故發生時年齡"::integer < 25  THEN '青年(18-24)'
        WHEN "當事者事故發生時年齡"::integer < 40  THEN '壯年(25-39)'
        WHEN "當事者事故發生時年齡"::integer < 60  THEN '中年(40-59)'
        ELSE '老年(60+)'
    END                                                                             AS age_group,
    NULLIF(TRIM("保護裝備名稱"), '')                                                  AS protective_equipment,
    NULLIF(TRIM("行動電話或電腦或其他相類功能裝置名稱"), '')                            AS mobile_device_use,
    NULLIF(TRIM("當事者行動狀態大類別名稱"), '')                                       AS party_action_major,
    NULLIF(TRIM("當事者行動狀態子類別名稱"), '')                                       AS party_action_minor,

    -- [12] 撞擊部位
    NULLIF(TRIM("車輛撞擊部位大類別名稱-最初"), '')                                    AS impact_major_first,
    NULLIF(TRIM("車輛撞擊部位子類別名稱-最初"), '')                                    AS impact_minor_first,
    NULLIF(TRIM("車輛撞擊部位大類別名稱-其他"), '')                                    AS impact_major_other,
    NULLIF(TRIM("車輛撞擊部位子類別名稱-其他"), '')                                    AS impact_minor_other,

    -- [13] 肇因 (個別)
    NULLIF(TRIM("肇因研判大類別名稱-個別"), '')                                        AS cause_individual_major,
    NULLIF(TRIM("肇因研判子類別名稱-個別"), '')                                        AS cause_individual_minor,

    -- [14] 肇逃
    NULLIF(TRIM("肇事逃逸類別名稱-是否肇逃"), '')                                      AS hit_and_run,
    CASE WHEN TRIM("肇事逃逸類別名稱-是否肇逃") = '是' THEN TRUE ELSE FALSE END        AS is_hit_and_run,

    -- [15] 地理座標
    NULLIF("經度"::text, '')::numeric                                                AS longitude,
    NULLIF("緯度"::text, '')::numeric                                                AS latitude,

    -- [16] 縣市名稱
    SUBSTRING(NULLIF(TRIM("發生地點"), ''), 1, 3)                                     AS city_zh,
    CASE SUBSTRING(NULLIF(TRIM("發生地點"), ''), 1, 3)
        WHEN '台北市' THEN 'Taipei'
        WHEN '臺北市' THEN 'Taipei'
        WHEN '新北市' THEN 'New Taipei'
        WHEN '桃園市' THEN 'Taoyuan'
        WHEN '台中市' THEN 'Taichung'
        WHEN '臺中市' THEN 'Taichung'
        WHEN '台南市' THEN 'Tainan'
        WHEN '臺南市' THEN 'Tainan'
        WHEN '高雄市' THEN 'Kaohsiung'
        WHEN '基隆市' THEN 'Keelung'
        WHEN '新竹市' THEN 'Hsinchu'
        WHEN '新竹縣' THEN 'Hsinchu'
        WHEN '苗栗縣' THEN 'Miaoli'
        WHEN '彰化縣' THEN 'Changhua'
        WHEN '南投縣' THEN 'Nantou'
        WHEN '雲林縣' THEN 'Yunlin'
        WHEN '嘉義市' THEN 'Chiayi'
        WHEN '嘉義縣' THEN 'Chiayi'
        WHEN '屏東縣' THEN 'Pingtung'
        WHEN '宜蘭縣' THEN 'Yilan'
        WHEN '花蓮縣' THEN 'Hualien'
        WHEN '台東縣' THEN 'Taitung'
        WHEN '臺東縣' THEN 'Taitung'
        WHEN '澎湖縣' THEN 'Penghu'
        WHEN '金門縣' THEN 'Kinmen'
        WHEN '連江縣' THEN 'Lienchiang'
        ELSE NULL
    END                                                                              AS city_en

FROM npa_tma1;

-- 驗證
SELECT COUNT(*)           AS total_rows      FROM stg_accidents;
SELECT COUNT(DISTINCT
    accident_date::text || accident_time::text || location
)                         AS unique_accidents FROM stg_accidents;
SELECT COUNT(*)           AS null_age_rows    FROM stg_accidents WHERE age IS NULL;
SELECT COUNT(*)           AS hit_and_run_cnt  FROM stg_accidents WHERE is_hit_and_run = TRUE;
