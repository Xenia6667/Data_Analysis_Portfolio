# F&B Sales Analytics — Fast Food Revenue Performance (2022–2023)

> **專案傳送門 (Project Navigation)**
>
> | | |
> |---|---|
> | **產品展示 (Product)** | [互動式儀表板 (Tableau Public)](https://public.tableau.com/views/fast_food_test/2?:language=zh-TW&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link) |
> | **分析報告 (Report)** | [完整報告](#) |
> | **原始代碼 (Code)** | [GitHub Repository](#) |

---

## 1. 專案摘要 (Executive Summary)

| | |
|---|---|
| **背景 (Background)** | A fast-food restaurant chain lacks visibility into revenue patterns, peak hours, and order behavior across different time periods. |
| **方法 (Method)** | Raw transaction data was cleaned and transformed using PostgreSQL, then visualized in an interactive Tableau dashboard with dynamic period filtering. |
| **成果 (Results)** | Delivered 7 interactive views covering revenue trends, peak hour heatmaps, MoM growth, and avg. ticket size — enabling flexible time-range exploration across year, quarter, month, week, and day. |

---

## 2. 商業問題與目標 (Business Context & Problem)

### 痛點 (Pain Points)

- Unable to identify which time slots and day types drive the most revenue
- No visibility into month-over-month growth trends or seasonal fluctuations

### 目標 (Objectives)

- Quantify monthly revenue, order volume, and average ticket size with period-over-period comparison
- Identify peak hours and weekday vs. weekend performance to support staffing and promotional decisions

---

## 3. 互動式儀表板 (Interactive Dashboard)

**[點擊進入互動式儀表板 (Tableau Public)](https://public.tableau.com/views/fast_food_test/2?:language=zh-TW&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

**圖表重點解讀：**

| 視圖 | 說明 |
|---|---|
| **Revenue Trend** | Dynamic bar chart with trend line, adjustable by year / quarter / month / week / day |
| **MoM Growth Rate** | Waterfall chart showing month-over-month revenue change, color-coded by growth vs. decline |
| **Peak Hour Heatmap** | Cross analysis of time of sale and day type, revealing highest-revenue time slots |
| **Avg. Ticket Size by Day Type** | Compares weekday vs. weekend spending behavior by month |
| **Revenue Share by Period** | Donut chart showing % contribution of each time slot to total revenue |

---

## 4. 統計分析與洞察 (Statistical Analysis)

> **核心發現 (Key Findings)**
>
> 1. Revenue is concentrated in specific time slots, with clear peak and off-peak patterns across weekdays and weekends
> 2. MoM growth shows volatility across the 12-month period, with identifiable high-growth and declining months

[閱讀完整報告](#)

---

## 5. 技術實作與代碼 (Implementation)

### 流程架構 (Workflow)

| 步驟 | 說明 |
|---|---|
| **1. Data Extraction** | Raw CSV manually loaded into PostgreSQL as `food_raw_df` with all columns as text type |
| **2. Data Cleaning** | Transformed via `staging_clean.sql` — type casting, date parsing, null handling, whitespace normalization, and deduplication via `ROW_NUMBER()` |
| **3. Feature Engineering** | Derived new columns — `day_type` (Weekday/Weekend), `sale_month`, `price_status` (anomaly detection), `item_birthday` |
| **4. Aggregation & Analysis** | Built analytical views in `core_analysis.sql` using window functions (`LAG`, `SUM OVER`, `AVG OVER`) to compute MoM growth rate, revenue share by period, and avg. ticket size |
| **5. Visualization** | Exported to Tableau → built interactive dashboard with dynamic period filtering via `Time Filter` and `Last N Periods` parameters |

[前往 GitHub 查看完整 Source Code](#)

---

## 6. 商業建議與下一步 (Recommendations & Next Steps)

| | |
|---|---|
| **行動建議 A** | Allocate more staff during identified peak hours and weekend slots to reduce wait time and maximize revenue capture |
| **行動建議 B** | Launch targeted promotions during consistently low-revenue time slots (off-peak hours on weekdays) to improve traffic distribution |
| **預期效益 (Expected Impact)** | Optimized staffing and promotional timing could improve operational efficiency and stabilize MoM revenue fluctuation |
