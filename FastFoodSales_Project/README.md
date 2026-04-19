# F&B Sales Analytics — Fast Food Revenue Performance (2022–2023)

> **專案傳送門 (Project Navigation)**
>
> | | |
> |---|---|
> | **產品展示 (Product)** | [互動式儀表板 (Tableau Public)](https://public.tableau.com/views/fast_food_test/2?:language=zh-TW&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link) |
> | **原始代碼 (Code)** | [GitHub Repository](https://github.com/Xenia6667/Data_Analysis_Portfolio/tree/main/FastFoodSales_Project) |

---

## 1. 專案摘要 (Executive Summary)

| | |
|---|---|
| **背景 (Background)** | A fast-food restaurant chain lacks visibility into revenue patterns, peak hours, and order behavior across different time periods. |
| **方法 (Method)** | Raw transaction data was cleaned and transformed using PostgreSQL, then visualized in an interactive Tableau dashboard with dynamic period filtering. |
| **成果 (Results)** | Delivered 5 interactive views covering revenue trends, peak hour heatmaps, MoM growth, and avg. ticket size — enabling flexible time-range exploration across year, quarter, month, week, and day. |

---

## 2. 數據來源 (Data Source)

| | |
|---|---|
| **資料集** | [Fast Food Sales Report](https://www.kaggle.com/datasets/rajatsurana979/fast-food-sales-report) |
| **平台** | Kaggle |
| **內容** | Transaction-level fast food sales data including item, quantity, price, date, and time of sale |
| **資料粒度** | 每列代表一筆交易紀錄 |
| **涵蓋期間** | 2022–2023 |

---

## 3. 商業問題與目標 (Business Context & Problem)

### 痛點 (Pain Points)

- Unable to identify which time slots and day types drive the most revenue
- No visibility into month-over-month growth trends or seasonal fluctuations

### 目標 (Objectives)

- Quantify monthly revenue, order volume, and average ticket size with period-over-period comparison
- Identify peak hours and weekday vs. weekend performance to support staffing and promotional decisions

---

## 4. 核心發現 (Key Findings)

| 發現 | 數據依據 |
|---|---|
| 特定時段貢獻不成比例的高營收 | 尖峰與離峰時段的營收差距顯著 |
| MoM 成長呈現週期性波動 | 12 個月中可識別出高成長月與衰退月 |
| 週末與平日的平均客單價存在差異 | Avg. Ticket Size by Day Type 圖表 |
| 特定時段的營收佔比集中 | Revenue Share by Period 顯示高度集中分布 |

---

## 5. 互動式儀表板 (Interactive Dashboard)

**[點擊進入互動式儀表板 (Tableau Public)](https://public.tableau.com/views/fast_food_test/2?:language=zh-TW&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

| 視圖 | 說明 |
|---|---|
| **Revenue Trend** | Dynamic bar chart with trend line, adjustable by year / quarter / month / week / day |
| **MoM Growth Rate** | Waterfall chart showing month-over-month revenue change, color-coded by growth vs. decline |
| **Peak Hour Heatmap** | Cross analysis of time of sale and day type, revealing highest-revenue time slots |
| **Avg. Ticket Size by Day Type** | Compares weekday vs. weekend spending behavior by month |
| **Revenue Share by Period** | Donut chart showing % contribution of each time slot to total revenue |

---

## 6. 技術實作與代碼 (Implementation)

### 資料夾結構 (Project Structure)

```
FastFoodSales_Project/
├── Data/               ← 原始與處理後的資料
├── Scripts/            ← SQL 清洗與分析查詢
│   ├── staging_clean.sql
│   └── core_analysis.sql
├── Tableau/            ← .twbx 儀表板檔案
└── Documentation/      ← 資料欄位說明
```

### 流程架構 (Workflow)

| 步驟 | 工具 | 說明 |
|---|---|---|
| **1. Data Extraction** | pgAdmin | Raw CSV manually loaded into PostgreSQL as `food_raw_df` with all columns as text type |
| **2. Data Cleaning** | SQL | Type casting, date parsing, null handling, whitespace normalization, deduplication via `ROW_NUMBER()` |
| **3. Feature Engineering** | SQL | Derived `day_type` (Weekday/Weekend), `sale_month`, `price_status` (anomaly detection), `item_birthday` |
| **4. Aggregation & Analysis** | SQL | Window functions (`LAG`, `SUM OVER`, `AVG OVER`) for MoM growth rate, revenue share, avg. ticket size |
| **5. Visualization** | Tableau | Interactive dashboard with dynamic period filtering via `Time Filter` and `Last N Periods` parameters |

### 技術棧 (Tech Stack)

| 技術 | 用途 |
|---|---|
| **PostgreSQL / SQL** | 資料清洗、聚合查詢、Window Functions |
| **Tableau** | 互動式儀表板、動態參數篩選 |

---

## 7. 商業建議與下一步 (Recommendations & Next Steps)

| | |
|---|---|
| **行動建議 A** | Allocate more staff during identified peak hours and weekend slots to reduce wait time and maximize revenue capture |
| **行動建議 B** | Launch targeted promotions during consistently low-revenue time slots (off-peak hours on weekdays) to improve traffic distribution |
| **預期效益** | Optimized staffing and promotional timing could improve operational efficiency and stabilize MoM revenue fluctuation |

### 未來延伸方向 (Next Steps)

- 納入品項層級分析，識別各時段最暢銷與最低效品項
- 結合外部節慶資料，解釋 MoM 波動的成因
- 建立促銷效果回測模型，量化折扣活動的 ROI
