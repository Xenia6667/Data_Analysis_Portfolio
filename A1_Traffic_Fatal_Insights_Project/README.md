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
| **方法 (Method)** | Government open data was ingested and cleaned using SQL, then explored and modeled in Python (EDA, geospatial heatmaps, risk factor analysis). Key findings were visualized in an interactive Tableau dashboard. |
| **成果 (Results)** | Identified high-risk time slots, road types, age groups, vehicle types, and primary causes of fatal accidents — providing data-driven evidence for targeted road safety interventions. |

---

## 2. 數據來源 (Data Source)

| | |
|---|---|
| **資料集** | 道路交通事故資料 — A1類（造成人員當場或24小時內死亡） |
| **平台** | 政府資料開放平台 (data.gov.tw) / 交通部 MOTC |
| **內容** | 事故時間、地點、天候、路況、車種、當事者資訊、肇因研判、經緯度等 50+ 欄位 |
| **資料粒度** | 每列代表一位當事者（同一事故可能有多筆） |

---

## 3. 商業問題與目標 (Problem & Objectives)

### 痛點 (Pain Points)

- 難以從原始資料中快速識別高風險時段、路段與族群
- 缺乏跨維度（時間 × 地理 × 車種 × 肇因）的整合分析視角
- 政策制定缺乏具體數據依據

### 核心分析問題 (Key Questions)

| # | 問題 | 分析類型 |
|---|---|---|
| 1 | 哪些時段與月份的死亡事故最集中？ | 時間分析 |
| 2 | 哪些縣市、道路類型是高危熱點？ | 地理分析 |
| 3 | 機車族死亡事故佔比為何？哪個年齡層風險最高？ | 當事者輪廓 |
| 4 | 主要肇因為何？天候與路面狀況是否顯著影響死亡率？ | 肇因分析 |
| 5 | 肇事逃逸的分布特徵為何？ | 逃逸行為分析 |
| 6 | 保護裝備使用率與死亡風險的關聯？ | 安全設備分析 |

---

## 4. 互動式儀表板 (Interactive Dashboard)

**[點擊進入互動式儀表板 (Tableau Public)](#)**

| 視圖 | 說明 |
|---|---|
| **Overview KPIs** | 總死亡事故數、死亡人數、高峰月份、高危縣市 |
| **Time Heatmap** | 24小時 × 星期幾的事故熱力圖 |
| **Geospatial Map** | 以經緯度呈現全台死亡事故密度熱點 |
| **Cause Analysis** | 主要肇因 Treemap 與子類別橫條圖 |
| **Party Profile** | 年齡層、性別、車種的交叉死亡分析 |
| **Road & Weather** | 道路型態、天候、路面狀況與死亡率關聯 |

---

## 5. 統計分析與洞察 (Statistical Analysis & Insights)

> **核心發現 (Key Findings)**  *(待完成分析後更新)*
>
> 1. TBD — 高風險時段集中於何時
> 2. TBD — 機車族死亡佔比
> 3. TBD — 主要肇因 TOP 3
> 4. TBD — 天候/路況影響顯著性

[閱讀完整報告](#)

---

## 6. 技術實作與代碼 (Implementation)

### 資料夾結構 (Project Structure)

```
A1_Traffic_Fatal_Insights_Project/
├── Data/               ← 原始與處理後的資料 (raw / processed)
├── Scripts/            ← SQL 清洗與分析查詢
├── Notebooks/          ← Python EDA、地圖視覺化、模型
├── Tableau/            ← .twbx 儀表板檔案
├── Reports/            ← 完整分析報告
├── Images/             ← 圖表輸出
└── Documentation/      ← 資料欄位說明、資料字典
```

### 流程架構 (Workflow)

| 步驟 | 工具 | 說明 |
|---|---|---|
| **1. Data Ingestion** | SQL | 將政府開放 CSV 匯入資料庫，建立 raw table，所有欄位以 text 型態儲存 |
| **2. Data Cleaning** | SQL | 型態轉換（時間、數值）、空值處理、欄位標準化、重複事故去識別 |
| **3. EDA & Feature Engineering** | Python / pandas | 時間特徵萃取、年齡分層、車種分組、死亡率計算 |
| **4. Geospatial Analysis** | Python / folium | 以經緯度繪製全台事故熱點密度圖 |
| **5. Statistical Testing** | Python / scipy | 天候、路面狀況對死亡率影響的 Chi-square 顯著性檢定 |
| **6. Risk Factor Analysis** | Python / scikit-learn | 以隨機森林或 Logistic Regression 識別關鍵死亡風險因子 |
| **7. Visualization** | Tableau | 多維度互動儀表板，支援縣市、時間、車種動態篩選 |

### 技術棧 (Tech Stack)

| 技術 | 用途 |
|---|---|
| **PostgreSQL / SQL** | 資料清洗、聚合查詢、Window Functions |
| **Python** | EDA、地圖視覺化、統計檢定、預測模型 |
| **pandas / matplotlib / seaborn** | 資料處理與圖表 |
| **folium / plotly** | 地理熱點地圖 |
| **scikit-learn / scipy** | 機器學習模型、統計檢定 |
| **Tableau** | 互動式儀表板 |

[前往 GitHub 查看完整 Source Code](#)

---

## 7. 商業建議與下一步 (Recommendations & Next Steps)

| | |
|---|---|
| **行動建議 A** | 針對高峰時段（待填入）加強執法與交通管理，優先部署於高死亡率路段 |
| **行動建議 B** | 針對高風險年齡層（機車族）強化安全帽及保護裝備使用宣導 |
| **行動建議 C** | 對肇事逃逸高發地點加裝監視設備，提高嚇阻效果 |
| **預期效益 (Expected Impact)** | 若能針對前 3 大肇因實施精準介入，估計可有效降低死亡事故集中風險區域的傷亡率 |

### 未來延伸方向 (Next Steps)

- 納入歷年資料進行趨勢分析（2019–2024）
- 與人口密度資料結合，計算每萬人死亡率
- 建立縣市層級的安全評分排名模型
