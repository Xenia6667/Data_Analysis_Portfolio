-- ============================================================
-- analysis_party.sql
-- Source : stg_accidents
-- Topic  : 當事者輪廓分析 (以人為單位)
-- ============================================================
SET search_path TO "A1_Traffic_Fatal";

-- [1] 車種大類分布
SELECT
    party_type_major,
    COUNT(*)                                                               AS party_count,
    ROUND(
        COUNT(*)::numeric
        / SUM(COUNT(*)) OVER () * 100,
        1
    )                                                                      AS party_pct
FROM stg_accidents
GROUP BY party_type_major
ORDER BY party_count DESC;

-- [2] 車種子類分布
SELECT
    party_type_major,
    party_type_minor,
    COUNT(*)                                                               AS party_count,
    ROUND(
        COUNT(*)::numeric
        / SUM(COUNT(*)) OVER () * 100,
        1
    )                                                                      AS party_pct
FROM stg_accidents
GROUP BY party_type_major, party_type_minor
ORDER BY party_count DESC;

-- [3] 性別分布
SELECT
    gender,
    COUNT(*)                                                               AS party_count,
    ROUND(
        COUNT(*)::numeric
        / SUM(COUNT(*)) OVER () * 100,
        1
    )                                                                      AS party_pct
FROM stg_accidents
GROUP BY gender
ORDER BY party_count DESC;

-- [4] 年齡層分布
SELECT
    age_group,
    COUNT(*)                                                               AS party_count,
    ROUND(
        COUNT(*)::numeric
        / SUM(COUNT(*)) OVER () * 100,
        1
    )                                                                      AS party_pct
FROM stg_accidents
WHERE age_group IS NOT NULL
GROUP BY age_group
ORDER BY party_count DESC;

-- [5] 年齡層 x 車種大類 交叉分析
SELECT
    age_group,
    party_type_major,
    COUNT(*)                                                               AS party_count
FROM stg_accidents
WHERE age_group IS NOT NULL
GROUP BY age_group, party_type_major
ORDER BY age_group, party_count DESC;

-- [6] 性別 x 車種 交叉分析
SELECT
    gender,
    party_type_major,
    COUNT(*)                                                               AS party_count
FROM stg_accidents
WHERE gender IS NOT NULL
GROUP BY gender, party_type_major
ORDER BY gender, party_count DESC;

-- [7] 保護裝備使用狀況 (機車族)
SELECT
    protective_equipment,
    COUNT(*)                                                               AS party_count,
    ROUND(
        COUNT(*)::numeric
        / SUM(COUNT(*)) OVER () * 100,
        1
    )                                                                      AS party_pct
FROM stg_accidents
WHERE party_type_major = '機車'
GROUP BY protective_equipment
ORDER BY party_count DESC;

-- [8] 行動電話使用狀況
SELECT
    mobile_device_use,
    COUNT(*)                                                               AS party_count,
    ROUND(
        COUNT(*)::numeric
        / SUM(COUNT(*)) OVER () * 100,
        1
    )                                                                      AS party_pct
FROM stg_accidents
WHERE mobile_device_use IS NOT NULL
GROUP BY mobile_device_use
ORDER BY party_count DESC;

-- [9] 高風險族群 : 年齡層 x 車種 x 死亡人數
SELECT
    age_group,
    party_type_major,
    party_type_minor,
    COUNT(*)                                                               AS party_count,
    SUM(death_count)                                                       AS total_deaths
FROM stg_accidents
WHERE age_group IS NOT NULL
GROUP BY age_group, party_type_major, party_type_minor
ORDER BY total_deaths DESC
LIMIT 15;
