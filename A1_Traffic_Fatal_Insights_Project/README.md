# Taiwan Fatal Traffic Accidents — A1 Category Injury & Fatality Analysis

> **專案傳送門 (Project Navigation)**
>
> | | |
> |---|---|
> | **產品展示 (Product)** | [互動式儀表板 (Tableau Public)](#) |
> | **分析報告 (Report)** | [完整報告](#) |
> | **原始代碼 (Code)** | [GitHub Repository](#) |

---

## 1. 專案摘要 (Executive Summary)

| | |
|---|---|
| **背景 (Background)** | Taiwan's A1-category traffic accidents — those resulting in death on-scene or within 24 hours — remain a critical public safety issue. Raw government data exists but lacks actionable insights for policymakers and safety advocates. |
| **方法 (Method)** | Government open data was ingested and cleaned using SQL, then explored and modeled in Python (EDA, geospatial heatmaps, statistical testing, risk factor analysis). Key findings were visualized in an interactive Tableau dashboard. |
| **成果 (Results)** | Analyzed 416 fatal accidents (1,077 parties) from 2026 Q1. Identified 18:00 as the single most dangerous hour, distracted driving as the top cause, and no-signal zones accounting for 68.3% of fatalities. Statistical testing confirmed a significant age gap between male and female parties (p = 0.003). |

---

## 2. 數據來源 (Data Source)

| | |
|---|---|
| **資料集** | 道路交通事故資料 — A1類（造成人員當場或24小時內死亡） |
| **平台** | 政府資料開放平台 (data.gov.tw) / 交通部 MOTC |
| **內容** | 事故時間、地點、天候、路況、車種、當事者資訊、肇因研判、經緯度等 50+ 欄位 |
| **資料粒度** | 每列代表一位當事者（同一事故可能有多筆） |
| **涵蓋期間** | 2026 年 1–4 月（416 起事故、1,077 筆當事者記錄） |

---

## 3. 核心發現 (Key Findings)

### 時間維度

| 發現 | 數據依據 |
|---|---|
| 18:00 是全天最危險單一小時 | 32 起，佔全日最高 |
| 晚尖峰（16-19）致死率最高 | 每小時平均 24.5 起，且 16:00 死亡率 1.07 人/起 |
| 深夜凌晨（00-05）佔 15.1% | 車少速快，疲勞駕駛風險高 |
| 1 月為全年最高峰 | 155 起，年節飲酒駕車與長途移動影響 |
| 週一、週三、週五最高 | 平日上班日風險高於假日 |

### 肇因與環境

| 發現 | 數據依據 |
|---|---|
| 駕駛者行為是壓倒性主因 | 佔 72.1% |
| 恍神/分心駕駛排第一 | 65 起（主要肇因子類） |
| 68.3% 死亡事故發生於無號誌路段 | 284 起 |
| 79.3% 事故發生於晴天 | 好天氣不等於安全，駕駛易鬆懈 |
| 肇逃率 1.9% | 8 起，每一起皆為刑事案件 |

### 當事者輪廓

| 發現 | 數據依據 |
|---|---|
| 機車族是最高風險車種 | 佔所有當事者 30.5%，普通重型單項 28.8% |
| 男性佔 63.3%，高度集中在機車 | 男性機車 254 人，女性機車 75 人 |
| 中年（40-59）與老年（60+）合計逾 54% | 並非年輕人主導 |
| 女性比男性平均年長約 5 歲 | Mann-Whitney U，p = 0.003（統計顯著） |
| 老年行人是高危群 | 47 位老年行人涉及事故 |

### 隨機森林 Top 3 風險因子

| 排名 | 因子 | 重要性 |
|---|---|---|
| 1 | 事故時段（accident_hour） | 0.2951 |
| 2 | 速限（speed_limit） | 0.1504 |
| 3 | 道路型態（road_form_major） | 0.1305 |

---

## 4. 統計檢定結果 (Statistical Testing)

| 檢定方法 | 問題 | 結論 |
|---|---|---|
| Fisher's Exact | 路面狀態 vs 多人死亡 | 不顯著（p = 0.248） |
| Chi-square | 號誌種類 vs 多人死亡 | 不顯著（p = 0.745） |
| Kruskal-Wallis | 各車種年齡分布差異 | 不顯著（p = 0.145） |
| Mann-Whitney U | 機車族 vs 行人年齡 | 不顯著（p = 0.070） |
| **Mann-Whitney U** | **男性 vs 女性年齡** | **顯著（p = 0.003）** |
| Spearman | 速限 vs 死亡人數 | 不顯著（p = 0.182） |
| Spearman | 事故小時 vs 死亡人數 | 不顯著（p = 0.362） |

> **限制說明**：資料僅涵蓋 2026 年 Q1（416 起），樣本數不足導致大多數環境因素檢定未達顯著水準。納入歷年資料（2019–2024）可大幅提升檢定力。

---

## 5. 互動式儀表板 (Interactive Dashboard)

**[點擊進入互動式儀表板 (Tableau Public)](#)**

| 視圖 | 說明 |
|---|---|
| **Overview KPIs** | 總死亡事故數、死亡人數、最危險時段、肇逃件數 |
| **Time Heatmap** | 24小時 × 星期幾的事故熱力圖 |
| **Geospatial Map** | 以經緯度呈現全台死亡事故密度熱點 |
| **Cause Analysis** | 主要肇因 Treemap 與環境交叉分析 |
| **Party Profile** | 年齡層、性別、車種的交叉死亡分析 |

---

## 6. 技術實作與代碼 (Implementation)

### 資料夾結構 (Project Structure)

```
A1_Traffic_Fatal_Insights_Project/
├── Data/               ← 原始與處理後的資料
├── Scripts/            ← SQL 清洗與分析查詢
│   ├── stg_clean.sql
│   ├── analysis_time.sql
│   ├── analysis_cause.sql
│   └── analysis_party.sql
├── Notebooks/          ← Python 分析
│   ├── 01_eda.ipynb
│   ├── 02_geospatial.ipynb
│   ├── 03_statistical_testing.ipynb
│   └── 04_risk_factor.ipynb
├── Tableau/            ← .twbx 儀表板檔案
├── Reports/            ← 完整分析報告
├── Images/             ← 圖表輸出
└── Documentation/      ← 資料欄位說明
```

### 流程架構 (Workflow)

| 步驟 | 工具 | 說明 |
|---|---|---|
| **1. Data Ingestion** | pgAdmin | 將政府開放 CSV 匯入 PostgreSQL |
| **2. Data Cleaning** | SQL | 型態轉換、空值處理、欄位正規化、死亡人數拆解 |
| **3. EDA & Feature Engineering** | Python / pandas | 時間特徵萃取、年齡分層、致死率計算 |
| **4. Geospatial Analysis** | Python / folium | 全台事故熱點密度圖、時段分色地圖 |
| **5. Statistical Testing** | Python / scipy | 7 項假設檢定，涵蓋 Chi-square、Mann-Whitney U、Spearman |
| **6. Risk Factor Analysis** | Python / scikit-learn | 隨機森林特徵重要性，識別 Top 3 風險因子 |
| **7. Visualization** | Tableau | 互動式儀表板，支援指標切換與維度篩選 |

### 技術棧 (Tech Stack)

| 技術 | 用途 |
|---|---|
| **PostgreSQL / SQL** | 資料清洗、聚合查詢、Window Functions |
| **Python / pandas** | EDA、資料處理、特徵工程 |
| **matplotlib / seaborn** | 統計圖表視覺化 |
| **folium** | 地理熱點地圖 |
| **scipy** | 統計假設檢定 |
| **scikit-learn** | 隨機森林風險因子分析 |
| **Tableau** | 互動式儀表板 |

---

## 7. 商業建議與下一步 (Recommendations & Next Steps)

| | |
|---|---|
| **行動建議 A** | 加強 16:00–19:00 晚尖峰時段執法，優先部署於無號誌高死亡率路段 |
| **行動建議 B** | 針對無號誌路段（佔 68.3%）優先評估裝設號誌或停讓標誌的可行性 |
| **行動建議 C** | 加強機車族分心駕駛宣導，特別針對 18–39 歲青壯年族群 |
| **行動建議 D** | 針對老年行人（60+）在高速路段周邊設置更多庇護島與行人設施 |
| **預期效益** | 針對前 3 大肇因（分心、不當超車、違規轉彎）實施精準介入，估計可有效降低晚尖峰死亡事故集中風險 |

### 未來延伸方向 (Next Steps)

- 納入歷年資料（2019–2024）擴大樣本，提升統計檢定力
- 與人口密度資料結合，計算每萬人死亡率
- 建立縣市層級的安全評分排名模型
