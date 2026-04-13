-- ============================================================
-- analysis_time.sql
-- Source : stg_accidents
-- Topic  : 時間維度分析 (以事故為單位)
-- ============================================================
SET search_path TO "A1_Traffic_Fatal";

-- [1] 每月事故數與死亡人數
SELECT
    accident_year,
    accident_month,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count,
    SUM(death_count)                                                       AS total_deaths
FROM stg_accidents
WHERE party_order = 1
GROUP BY accident_year, accident_month
ORDER BY accident_year, accident_month;

-- [2] 24小時事故分布 (哪個小時最危險)
SELECT
    accident_hour,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count,
    SUM(death_count)                                                       AS total_deaths
FROM stg_accidents
WHERE party_order = 1
GROUP BY accident_hour
ORDER BY accident_count DESC;

-- [3] 時段分類分布 (早上/下班/深夜等)
SELECT
    CASE
        WHEN accident_hour BETWEEN 6  AND 9  THEN '早尖峰 (06-09)'
        WHEN accident_hour BETWEEN 10 AND 15 THEN '日間 (10-15)'
        WHEN accident_hour BETWEEN 16 AND 19 THEN '晚尖峰 (16-19)'
        WHEN accident_hour BETWEEN 20 AND 23 THEN '夜間 (20-23)'
        ELSE '深夜/凌晨 (00-05)'
    END                                                                    AS time_period,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count,
    SUM(death_count)                                                       AS total_deaths,
    ROUND(
        COUNT(DISTINCT accident_date::text || accident_time::text || location)::numeric
        / SUM(COUNT(DISTINCT accident_date::text || accident_time::text || location)) OVER () * 100,
        1
    )                                                                      AS accident_pct
FROM stg_accidents
WHERE party_order = 1
GROUP BY time_period
ORDER BY accident_count DESC;

-- [4] 星期幾分布
SELECT
    TO_CHAR(accident_date, 'Day')                                          AS day_of_week,
    EXTRACT(DOW FROM accident_date)::integer                               AS dow_num,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count,
    SUM(death_count)                                                       AS total_deaths
FROM stg_accidents
WHERE party_order = 1
GROUP BY day_of_week, dow_num
ORDER BY dow_num;

-- [5] 月份 x 時段 交叉熱力圖 (Tableau 用)
SELECT
    accident_month,
    CASE
        WHEN accident_hour BETWEEN 6  AND 9  THEN '早尖峰 (06-09)'
        WHEN accident_hour BETWEEN 10 AND 15 THEN '日間 (10-15)'
        WHEN accident_hour BETWEEN 16 AND 19 THEN '晚尖峰 (16-19)'
        WHEN accident_hour BETWEEN 20 AND 23 THEN '夜間 (20-23)'
        ELSE '深夜/凌晨 (00-05)'
    END                                                                    AS time_period,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count
FROM stg_accidents
WHERE party_order = 1
GROUP BY accident_month, time_period
ORDER BY accident_month, time_period;
