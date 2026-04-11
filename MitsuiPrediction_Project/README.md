# E-Commerce Performance Analytics
### Olist Brazilian E-Commerce — Customer Segmentation · Delivery Quality · Product Strategy

---

## Overview

This project performs end-to-end exploratory data analysis (EDA) on the **Olist Brazilian E-Commerce** public dataset, covering ~100,000 orders from 2016 to 2018. The analysis spans customer segmentation, delivery performance, product strategy, statistical testing, and unsupervised machine learning.

---

## Research Questions

| # | Question |
|---|----------|
| Q1 | 哪些客群貢獻最高營收？如何識別高價值與流失風險客戶？ |
| Q2 | 配送延遲如何影響顧客滿意度？延遲訂單有哪些可辨識特徵？ |
| Q3 | 哪些品類驅動主要營收（80/20）？價格與滿意度的關係為何？ |
| Q4 | 能否透過 KMeans 找出具有明確行為差異的客群側寫？ |

---

## Project Structure

```
MitsuiPrediction_Project/
├── Notebooks/
│   └── E-Commerce Performance Analytics.ipynb   # 主分析筆記本
├── Data/
│   ├── raw_data/
│   │   └── olist/                               # 原始 CSV（9 張）
│   └── Processed_Data/                          # 清理後資料
├── Reports/
├── Scripts/
├── Tableau/
└── README.md
```

---

## Dataset

**Source：** [Olist Brazilian E-Commerce (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

| 檔案 | 說明 | 筆數 |
|------|------|------|
| `olist_orders_dataset.csv` | 訂單主表（狀態、時間） | 99,441 |
| `olist_customers_dataset.csv` | 客戶資訊（地區、唯一ID） | 99,441 |
| `olist_order_items_dataset.csv` | 訂單明細（產品、賣家、價格） | 112,650 |
| `olist_order_payments_dataset.csv` | 付款方式與金額 | 103,886 |
| `olist_order_reviews_dataset.csv` | 顧客評價（1–5分） | 99,224 |
| `olist_products_dataset.csv` | 產品資訊 | 32,951 |
| `product_category_name_translation.csv` | 品類英文翻譯 | 71 |
| `olist_sellers_dataset.csv` | 賣家資訊 | 3,095 |
| `olist_geolocation_dataset.csv` | 郵遞區號地理座標 | 1,000,163 |

---

## Analysis Pipeline

---

### STEP 1 │ 資料載入與概覽

- 讀取 9 張 CSV，建立 `datasets` 字典，迴圈一次輸出各表 Shape、Dtype、缺失值、重複列數

**解析**
初步概覽顯示資料集具備良好完整性：`orders` 與 `customers` 各有 99,441 筆且無重複，付款與評價表稍少（部分訂單無付款或評價記錄屬正常）。值得注意的是 `orders` 中 `order_delivered_customer_date` 有約 2,965 筆缺失，這些幾乎都來自非 delivered 狀態的訂單，在 STEP 2 過濾後會自然消失。`geolocation` 有逾 26 萬筆重複，屬於相同郵遞區號多次記錄的正常現象，本專案不使用該表故不影響分析。

---

### STEP 2 │ 資料清理與特徵工程

- 合併 8 張表（`orders` 為主表，left join）
- 過濾 `order_status == 'delivered'`（只保留已完成訂單）
- 缺失值處理：必要欄位 dropna、數值欄位中位數填補、類別欄位填 `'unknown'`
- 衍生特徵：

| 特徵 | 計算方式 | 意義 |
|------|----------|------|
| `delivery_days` | 實際到貨日 − 下單日 | 完整配送週期天數 |
| `delay_days` | 實際到貨日 − 預估到貨日 | 延遲天數（正值 = 遲到）|
| `is_late` | `delay_days > 0` → 1/0 | 是否遲到（後續分類分析目標）|

**解析**
只保留 `delivered` 狀態是因為未完成訂單缺乏實際到貨時間，無法計算配送與延遲特徵，強行保留會引入大量無意義缺失值。`delivery_days` 捕捉整體物流效率，而 `delay_days` 則衡量「承諾達成率」，這兩個角度都重要：即使送達很慢，只要在預估日期內到達，顧客的感受仍是正面的。`is_late` 作為二元標籤，為後續統計檢定與機器學習分群提供明確的切割依據。

---

### STEP 3 │ 營運脈搏 (Revenue Pulse)

- 月營收 + 訂單量雙軸趨勢折線圖
- 週 × 時段熱力圖（下單行為分析）
- AOV 分佈直方圖（Mean / Median 標線，clip 99th pct）

**解析**
月趨勢圖呈現 Olist 平台的成長軌跡，通常可以觀察到 2017 年底至 2018 年中的快速擴張期，以及特定節假日（如巴西黑色星期五）帶來的訂單高峰。熱力圖揭露消費者習慣集中於週間白天至傍晚，週末凌晨則幾乎無下單，這對備貨與客服排班具有直接的運營參考價值。AOV 分佈呈現右偏（Mean 高於 Median），反映少數高單價訂單拉高了平均值，Median 才是更具代表性的「典型消費金額」，截去 99th percentile 後的直方圖能更清晰地呈現主要消費族群的分佈形狀。

---

### STEP 4 │ 客群 RFM 分析

- 計算每位客戶 Recency / Frequency / Monetary，各自切分 1–5 分位
- 規則式貼標：Champions / Loyal / Potential Loyalists / New Customers / At Risk / Lost
- 圓餅圖：人數佔比 vs 營收貢獻佔比（雙圖對比）
- 散佈圖：Recency × Monetary，顏色 = 客群

**解析**
RFM 是經典的客戶價值評估框架，透過三個維度同時衡量「最近活躍度、消費頻率、貢獻金額」，比單純依金額排序更能識別真正有忠誠潛力的客群。Olist 以一次性消費為主（電商平台常見現象），因此 Frequency 普遍偏低，大多數客戶可能落在 New Customers 或 Lost。雙圓餅圖的關鍵洞察在於：Champions 通常僅佔人數的 5–10%，卻可能貢獻 30–40% 的營收，說明高價值客戶值得優先投入維繫資源。散佈圖中 Lost 群集中於高 Recency（久未購買）低 Monetary 區域，At Risk 則介於中間地帶，是再行銷活動最值得鎖定的對象。

---

### STEP 5 │ 產品戰略

- Pareto 圖：自動標出 80% 營收門檻對應品類數（深色 = A 類，淺色 = B/C 類）
- ABC 分類（A ≤ 70%、B ≤ 90%、C 其餘）
- 價格 × 滿意度泡泡圖（泡泡大小 = 訂單量）

**解析**
Pareto 分析驗證了電商品類典型的「長尾效應」：少數核心品類（如 bed_bath_table、health_beauty、computers_accessories）驅動大部分營收，其餘品類合計貢獻有限。ABC 分類將此轉化為可操作的庫存與行銷策略：A 類品類應確保供貨穩定並加強推廣，B 類維持現狀，C 類則評估是否值得繼續維護。泡泡圖呈現四個象限的戰略意涵：高價高評分的品類（右上）是品牌形象核心，高訂單量低評分（左下大泡泡）則是服務改善的優先目標，直接影響平台整體口碑。

---

### STEP 6 │ 服務品質 / 配送

- 配送天數 × 評分箱型圖（斷崖效果視覺化）
- 遲到率 × 評分長條圖（數字標注）
- 準時 vs 遲到配送天數密度分佈對比

**解析**
箱型圖的「斷崖」效果直觀說明：評分 5 分的訂單配送天數中位數明顯短於評分 1–2 分，且變異數也更小（箱體緊湊）。這表示配送速度不只影響滿意度，快速且穩定的配送才是高評分的共同特徵。遲到率長條圖通常呈現出 1 分訂單的遲到率遠高於 5 分，驗證了遲到與負評的強烈關聯性。準時 vs 遲到的密度分佈對比則顯示兩者的 delivery_days 分佈有明顯重疊，說明「遲到幾天」比「是否遲到」更能影響評分，極端遲到（10 天以上）對評分的傷害尤為顯著。

---

### STEP 7 │ 統計檢定


| 檢定 | 問題 |
|------|------|
| Shapiro-Wilk | AOV 是否為常態分佈？ |
| Mann-Whitney U | 準時 vs 遲到訂單的 AOV 有顯著差異？ |
| Kruskal-Wallis | 各州顧客評分是否不同？ |
| Chi² | 遲到與評分之間有無關聯？ |
| Spearman 相關矩陣 | 各指標間的相關強度（delivery_days、delay_days、AOV、review_score 等）|

**解析**
Shapiro-Wilk 預期 AOV 顯著非常態（p < 0.05），因為消費金額普遍右偏，這也是為何後續選擇無母數檢定（Mann-Whitney U、Kruskal-Wallis）而非 t-test 或 ANOVA 的原因。Mann-Whitney U 檢驗準時與遲到訂單的消費金額是否有差異，若無顯著差異則說明遲到問題不分消費層級，是系統性物流問題而非特定客群的服務短板。Kruskal-Wallis 若顯著，代表巴西各州的評分存在地理差異，可進一步挖掘特定地區的物流痛點。Chi² 檢驗遲到與評分的關聯性，補充了 STEP 6 視覺化的統計嚴謹度。Spearman 相關矩陣則提供全局視角，通常可發現 `delivery_days` 與 `review_score` 呈顯著負相關，`delay_days` 與 `is_late` 呈高度正相關。

---

### STEP 8 │ KMeans 分群

- Log 轉換 + StandardScaler 標準化 RFM 特徵
- Elbow Curve + Silhouette Score 自動選最佳 k（sample_size=5000 加速）
- PCA 二維投影可視化
- 雷達圖：各群 R / F / M 平均側寫
- Cluster × RFM Segment 交叉熱力圖

**解析**
Log 轉換的目的是壓縮 Monetary 的長尾分佈，避免高消費異常值主導分群結果，讓各群之間的距離更能反映真實的行為差異。Silhouette Score 提供比 Elbow 更客觀的最佳 k 選擇依據：Elbow 的「轉折點」往往主觀，Silhouette 則量化了群內緊密度與群間分離度的比值。PCA 投影將三維 RFM 空間壓縮至二維，若能看到清晰分離的色塊，代表分群品質良好。雷達圖讓每個群的 RFM 特徵側寫一目了然：例如某群可能是高 R 低 F 低 M（新客），另一群則是低 R 高 F 高 M（沉睡高價值客戶）。交叉熱力圖揭示資料驅動的 KMeans 分群與規則式 RFM 標籤的對應關係，驗證兩種方法的一致性，也幫助解釋每個 Cluster 的業務含義。

---

## Libraries

| 套件 | 用途 |
|------|------|
| `pandas` | 資料清理、合併、聚合 |
| `numpy` | 數值計算、log 轉換 |
| `matplotlib` | 基礎繪圖（雙軸、直方圖、雷達圖） |
| `seaborn` | 統計視覺化（熱力圖、箱型圖、散佈圖） |
| `scipy.stats` | Shapiro-Wilk、Mann-Whitney U、Kruskal-Wallis、Chi² |
| `sklearn.preprocessing` | StandardScaler |
| `sklearn.cluster` | KMeans |
| `sklearn.decomposition` | PCA |
| `sklearn.metrics` | silhouette_score |

---

## How to Run

```bash
# 1. 建立虛擬環境（已有可略過）
python3 -m venv .venv
source .venv/bin/activate

# 2. 安裝套件
pip install pandas numpy matplotlib seaborn scipy scikit-learn jupyter

# 3. 開啟 notebook
jupyter notebook "Notebooks/E-Commerce Performance Analytics.ipynb"
```

> **中文字型**：macOS 系統會自動偵測並載入 PingFang HK，無需額外安裝。



