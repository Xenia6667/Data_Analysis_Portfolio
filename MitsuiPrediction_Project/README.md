# E-Commerce Performance Analytics
### Olist Brazilian E-Commerce — Customer Segmentation · Delivery Quality · Product Strategy

> **專案傳送門 (Project Navigation)**
>
> | | |
> |---|---|
> | **產品展示 (Product)** | [互動式儀表板 (Tableau Public)](https://public.tableau.com/views/BrazilianOlistEcommerceDataInsightsSalesPerformanceCustomerValueandProductPerformanceAnalysisOlist_17755805289840/1_1?:language=zh-TW&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link) |
> | **原始代碼 (Code)** | [GitHub Repository](https://github.com/Xenia6667/Data_Analysis_Portfolio/tree/main/MitsuiPrediction_Project) |

---

## 1. 專案摘要 (Executive Summary)

| | |
|---|---|
| **背景 (Background)** | Olist 巴西電商平台缺乏對客群價值分布、配送品質影響與品類策略的系統性洞察，難以針對性地優化運營資源。 |
| **方法 (Method)** | 合併 9 張關聯資料表進行端到端 EDA，涵蓋 RFM 客群分析、Pareto 品類策略、配送品質統計檢定，以及 KMeans 非監督式分群。 |
| **成果 (Results)** | 識別出高價值客群僅佔人數 5–10% 但貢獻 30–40% 營收；少數核心品類驅動 80% 營收；配送延遲與低評分呈強烈關聯；KMeans 成功識別出行為差異顯著的 3 個客群。 |

---

## 2. 數據來源 (Data Source)

| | |
|---|---|
| **資料集** | [Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) |
| **平台** | Kaggle |
| **內容** | 訂單、客戶、商品、付款、評價、賣家、地理位置等 9 張關聯資料表 |
| **資料粒度** | 每列代表一筆訂單或訂單明細 |
| **涵蓋期間** | 2016–2018（~100,000 筆已完成訂單） |

---

## 3. 研究問題 (Research Questions)

| # | 問題 |
|---|---|
| Q1 | 哪些客群貢獻最高營收？如何識別高價值與流失風險客戶？ |
| Q2 | 配送延遲如何影響顧客滿意度？延遲訂單有哪些可辨識特徵？ |
| Q3 | 哪些品類驅動主要營收（80/20）？價格與滿意度的關係為何？ |
| Q4 | 能否透過 KMeans 找出具有明確行為差異的客群側寫？ |

---

## 4. 核心發現 (Key Findings)

### 客群價值 (RFM Analysis)

| 發現 | 數據依據 |
|---|---|
| Champions 僅佔人數 5–10%，卻貢獻 30–40% 營收 | RFM 雙圓餅圖對比 |
| 平台以一次性消費為主，Frequency 普遍偏低 | 大多數客戶落在 New Customers 或 Lost 標籤 |
| At Risk 群體是再行銷活動最具投資回報的目標 | 處於中間地帶，有召回可能性 |

### 配送品質 (Delivery Quality)

| 發現 | 數據依據 |
|---|---|
| 評分 5 分訂單的配送天數中位數顯著短於 1–2 分 | 箱型圖「斷崖」效果 |
| 遲到率與低評分呈強烈關聯 | 1 分訂單遲到率遠高於 5 分訂單 |
| 極端延遲（10 天以上）對評分的傷害尤為顯著 | 準時 vs 遲到密度分佈對比 |

### 品類策略 (Product Strategy)

| 發現 | 數據依據 |
|---|---|
| 少數核心品類（bed_bath_table, health_beauty 等）驅動 80% 營收 | Pareto 分析 |
| 高訂單量低評分的品類是服務改善的優先目標 | 價格 × 滿意度泡泡圖左下大泡泡 |

---

## 5. 統計檢定結果 (Statistical Testing)

| 檢定方法 | 問題 | 結論 |
|---|---|---|
| Shapiro-Wilk | AOV 是否常態分佈？ | 非常態（p < 0.05），符合右偏預期 |
| Mann-Whitney U | 準時 vs 遲到訂單的 AOV 差異？ | 配送延遲問題屬系統性，不分消費層級 |
| Kruskal-Wallis | 各州顧客評分是否不同？ | 顯著，特定地區物流痛點可進一步挖掘 |
| Chi-square | 遲到與評分的關聯性？ | 顯著，補充視覺化的統計嚴謹度 |
| Spearman | 各指標間的相關強度 | `delivery_days` 與 `review_score` 呈顯著負相關 |

---

## 6. 機器學習分群 (KMeans Clustering)

| 步驟 | 說明 |
|---|---|
| **特徵前處理** | Log 轉換 Monetary + StandardScaler 標準化 RFM |
| **最佳 k 選擇** | Elbow Curve + Silhouette Score（sample_size=5000 加速） |
| **結果視覺化** | PCA 二維投影 + 雷達圖各群 RFM 側寫 |
| **驗證** | Cluster × RFM Segment 交叉熱力圖確認一致性 |

---

## 7. 技術實作與代碼 (Implementation)

### 資料夾結構 (Project Structure)

```
MitsuiPrediction_Project/
├── Data/
│   ├── raw_data/olist/         ← 原始 CSV（9 張）
│   └── Processed_Data/         ← 清理後資料
├── Notebooks/
│   └── E-Commerce Performance Analytics.ipynb
├── Reports/
├── Scripts/
├── Tableau/
└── README.md
```

### 流程架構 (Workflow)

| 步驟 | 工具 | 說明 |
|---|---|---|
| **1. 資料載入** | Python / pandas | 讀取 9 張 CSV，建立 datasets 字典，概覽 Shape、Dtype、缺失值 |
| **2. 資料清理** | pandas | 合併 8 張表（orders 為主表）、過濾 delivered 訂單、缺失值處理 |
| **3. 特徵工程** | pandas | 衍生 `delivery_days`、`delay_days`、`is_late` |
| **4. EDA** | matplotlib / seaborn | 月營收趨勢、週 × 時段熱力圖、AOV 分佈 |
| **5. RFM 分析** | pandas | 計算 Recency / Frequency / Monetary，規則式貼標六大客群 |
| **6. 品類策略** | matplotlib | Pareto 分析、ABC 分類、價格 × 滿意度泡泡圖 |
| **7. 統計檢定** | scipy | Shapiro-Wilk、Mann-Whitney U、Kruskal-Wallis、Chi²、Spearman |
| **8. KMeans 分群** | scikit-learn | Log 轉換 + 標準化 → Elbow + Silhouette → PCA 投影 + 雷達圖 |

### 技術棧 (Tech Stack)

| 技術 | 用途 |
|---|---|
| **Python / pandas** | 資料清理、合併、聚合、特徵工程 |
| **matplotlib / seaborn** | 統計圖表視覺化 |
| **scipy** | 統計假設檢定 |
| **scikit-learn** | StandardScaler、KMeans、PCA、silhouette_score |

---

## 8. 商業建議與下一步 (Recommendations & Next Steps)

| | |
|---|---|
| **行動建議 A** | 針對 Champions 客群推出專屬忠誠計畫，保護平台 30–40% 的核心營收來源 |
| **行動建議 B** | 優先改善高訂單量低評分品類的配送 SLA，直接影響平台整體口碑 |
| **行動建議 C** | 針對 At Risk 客群設計自動化召回流程，以最低成本挽回流失邊緣的高價值用戶 |
| **預期效益** | 聚焦前 20% 品類與高風險客群的精準介入，可顯著提升平台整體 NPS 與 LTV |

### 未來延伸方向 (Next Steps)

- 納入歷史資料擴大樣本，提升統計檢定力
- 建立配送延遲預測模型，主動識別高風險訂單
- 結合地理資料分析特定州別的物流效率差距
