-- ============================================================
-- analysis_cause.sql
-- Source : stg_accidents
-- Topic  : 肇因與環境分析
-- Note   : 肇因主要 以事故為單位 (party_order = 1)
--          肇因個別 以當事者為單位 (全部筆數)
-- ============================================================
SET search_path TO "A1_Traffic_Fatal";

-- [1] 主要肇因大類排行
SELECT
    cause_major,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count,
    SUM(death_count)                                                       AS total_deaths,
    ROUND(
        COUNT(DISTINCT accident_date::text || accident_time::text || location)::numeric
        / SUM(COUNT(DISTINCT accident_date::text || accident_time::text || location)) OVER () * 100,
        1
    )                                                                      AS accident_pct
FROM stg_accidents
WHERE party_order = 1
GROUP BY cause_major
ORDER BY accident_count DESC;

-- [2] 主要肇因子類 TOP 10
SELECT
    cause_major,
    cause_minor,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count,
    SUM(death_count)                                                       AS total_deaths
FROM stg_accidents
WHERE party_order = 1
GROUP BY cause_major, cause_minor
ORDER BY accident_count DESC
LIMIT 10;

-- [3] 個別當事者肇因子類 TOP 10 (以人為單位)
SELECT
    cause_individual_major,
    cause_individual_minor,
    COUNT(*)                                                               AS party_count,
    ROUND(
        COUNT(*)::numeric
        / SUM(COUNT(*)) OVER () * 100,
        1
    )                                                                      AS party_pct
FROM stg_accidents
WHERE cause_individual_minor IS NOT NULL
GROUP BY cause_individual_major, cause_individual_minor
ORDER BY party_count DESC
LIMIT 10;

-- [4] 天候 x 事故數
SELECT
    weather,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count,
    SUM(death_count)                                                       AS total_deaths,
    ROUND(
        COUNT(DISTINCT accident_date::text || accident_time::text || location)::numeric
        / SUM(COUNT(DISTINCT accident_date::text || accident_time::text || location)) OVER () * 100,
        1
    )                                                                      AS accident_pct
FROM stg_accidents
WHERE party_order = 1
GROUP BY weather
ORDER BY accident_count DESC;

-- [5] 路面狀態 x 事故數
SELECT
    road_condition,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count,
    SUM(death_count)                                                       AS total_deaths
FROM stg_accidents
WHERE party_order = 1
GROUP BY road_condition
ORDER BY accident_count DESC;

-- [6] 天候 x 路面狀態 交叉分析
SELECT
    weather,
    road_condition,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count
FROM stg_accidents
WHERE party_order = 1
GROUP BY weather, road_condition
ORDER BY accident_count DESC;

-- [7] 號誌狀態 x 事故數
SELECT
    signal_type,
    signal_action,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count,
    SUM(death_count)                                                       AS total_deaths
FROM stg_accidents
WHERE party_order = 1
GROUP BY signal_type, signal_action
ORDER BY accident_count DESC;

-- [8] 肇逃分布 (以事故為單位)
SELECT
    hit_and_run,
    COUNT(DISTINCT accident_date::text || accident_time::text || location) AS accident_count,
    ROUND(
        COUNT(DISTINCT accident_date::text || accident_time::text || location)::numeric
        / SUM(COUNT(DISTINCT accident_date::text || accident_time::text || location)) OVER () * 100,
        1
    )                                                                      AS accident_pct
FROM stg_accidents
WHERE party_order = 1
GROUP BY hit_and_run
ORDER BY accident_count DESC;
