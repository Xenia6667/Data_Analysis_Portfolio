# Mobile Game Player Segmentation & Business Strategy
### 移動遊戲玩家分群與商業策略分析

> **專案傳送門 (Project Navigation)**
>
> | | |
> |---|---|
> | **產品展示 (Product)** | [互動式儀表板 (Tableau Public)](https://public.tableau.com/views/GlobalMobileGamingMarket/2_1?:language=zh-TW&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link) |
> | **原始代碼 (Code)** | [GitHub Repository](https://github.com/Xenia6667/Data_Analysis_Portfolio/tree/main/Mobilegame_Project) |

---

## 1. 專案摘要 (Executive Summary)

| | |
|---|---|
| **背景 (Background)** | 行動遊戲公司缺乏識別高付費玩家（Whale）的有效機制，現有以人口統計為基礎的行銷策略未能有效區分付費層級。 |
| **方法 (Method)** | 使用 R（tidyverse + tidymodels）對玩家內購行為進行統計檢定與隨機森林分類，識別具有預測力的行為特徵。 |
| **成果 (Results)** | 統計檢定確認人口統計特徵對付費層級無顯著影響；隨機森林揭示 AverageSessionLength 與 DaysSinceLastPurchase 是預測高付費玩家的決定性因素。 |

---

## 2. 數據來源 (Data Source)

| | |
|---|---|
| **資料集** | Mobile Game In-App Purchases |
| **平台** | 內部資料集 |
| **內容** | 玩家 ID、年齡、性別、裝置、國家、遊戲類型、遊玩次數、平均時長、內購金額、付款方式、付費層級等 |
| **資料粒度** | 每列代表一位玩家 |
| **付費層級分布** | Minnow 84.1% / Dolphin 13.6% / Whale 2.2% |

---

## 3. 核心發現 (Key Findings)

### 人口統計特徵的獨立性

| 發現 | 方法 | p 值 |
|---|---|---|
| 性別、國籍、裝置、遊戲類型、付款方式 均與付費層級無關 | Fisher's Exact / Chi-square | 0.19–0.62，均 > 0.05 |
| iOS 與 Android 用戶在付費金額、遊玩時長、流失傾向上均無差異 | Wilcoxon Rank-Sum Test | 均 > 0.05 |
| 數值特徵之間相關性極低 | Spearman 相關矩陣 | \|r\| < 0.20 |

### 隨機森林特徵重要性

| 排名 | 特徵 | 業務含義 |
|---|---|---|
| 1 | AverageSessionLength | 內容黏性是高付費玩家的核心特徵 |
| 2 | DaysSinceLastPurchase | 流失傾向直接反映付費意願下降 |
| 3 | SessionCount | 遊玩頻率輔助補充行為輪廓 |

---

## 4. 統計檢定結果 (Statistical Testing)

| 檢定方法 | 問題 | 結論 |
|---|---|---|
| Chi-square / Fisher's Exact | 類別變數 vs 付費層級 | 所有類別特徵與付費層級統計獨立 |
| Wilcoxon Rank-Sum | iOS vs Android 核心指標差異 | 裝置平台對行為指標無顯著影響 |
| Kruskal-Wallis | 各類別群體的行為指標差異 | 所有 p 值 > 0.05，群體間無顯著差異 |
| Spearman | 數值特徵間相關性 | 特徵高度獨立，適合 Random Forest |

> **資料品質說明**：刪除 136 筆付費資訊缺失的紀錄；對剩餘 60 筆缺失使用中位數（數值）和眾數（類別）填補。

---

## 5. 機器學習模型 (Machine Learning)

### 隨機森林分類 (Random Forest Classification)

| | |
|---|---|
| **目標變數** | SpendingSegment（Minnow / Dolphin / Whale） |
| **特徵工程** | Log 轉換 InAppPurchaseAmount、Label Encoding、One-Hot Encoding、頻率編碼（Country / GameGenre） |
| **前處理** | StandardScaler 標準化所有數值特徵 |
| **訓練配置** | 500 棵樹、stratified split 80/20（確保 Whale 比例不被打亂） |
| **引擎** | ranger（R 高效 Random Forest 引擎） |

---

## 6. 技術實作與代碼 (Implementation)

### 資料夾結構 (Project Structure)

```
Mobilegame_Project/
├── data/
│   ├── raw/
│   │   ├── mobile_game_inapp_purchases.csv
│   │   └── clean_df.csv
│   └── processed/
│       └── data.csv
├── RF_Report.Rmd             ← 主分析報告（R Markdown）
├── RF_Report.html            ← 輸出報告
└── README.md
```

### 流程架構 (Workflow)

| 步驟 | 工具 | 說明 |
|---|---|---|
| **1. 探索性分析** | R / skimr / ggplot2 | 數值分布直方圖、類別頻率長條圖、缺失值視覺化 |
| **2. 資料清理** | tidyverse | 刪除 136 筆缺失、中位數/眾數填補 60 筆、日期轉換 |
| **3. 特徵工程** | tidyverse / fastDummies | Log 轉換、Label / One-Hot / 頻率編碼、StandardScaler 標準化 |
| **4. 統計檢定** | stats / dunn.test | Chi-square、Fisher's、Wilcoxon、Kruskal-Wallis、Spearman |
| **5. 隨機森林** | tidymodels / ranger | 訓練分類模型、提取特徵重要性、混淆矩陣評估 |

### 技術棧 (Tech Stack)

| 技術 | 用途 |
|---|---|
| **R / tidyverse** | 資料清理、特徵工程、視覺化 |
| **tidymodels / ranger** | 隨機森林模型訓練與評估 |
| **fastDummies** | One-Hot 編碼 |
| **corrplot** | 相關係數矩陣視覺化 |
| **R Markdown** | 分析報告輸出（HTML） |

---

## 7. 商業建議與下一步 (Recommendations & Next Steps)

| | |
|---|---|
| **行動建議 A** | 開發延長單次會話時長（AverageSessionLength）的遊戲內容，直接提升玩家終身價值（LTV） |
| **行動建議 B** | 以 DaysSinceLastPurchase 建立自動化預警機制，精準召回高流失風險玩家 |
| **行動建議 C** | 停止以人口統計（性別、國籍、裝置）作為付費行銷的主要區隔依據，將預算轉向行為標籤 |
| **預期效益** | 精準投放召回廣告至行為流失邊緣族群，可大幅提升再行銷 ROI |

### 未來延伸方向 (Next Steps)

- 加入時序特徵（付費行為隨時間的變化趨勢），建立玩家流失預測模型
- 以 SHAP 值深化隨機森林的可解釋性分析
- 結合 A/B 測試驗證「延長會話時長」策略對付費轉換率的實際影響
