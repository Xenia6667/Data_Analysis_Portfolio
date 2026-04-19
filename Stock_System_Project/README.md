# Stock Market Technical Analysis System
### 股票技術分析系統 — 數據管道 · 技術指標 · 交易訊號

> **專案傳送門 (Project Navigation)**
>
> | | |
> |---|---|
> | **原始代碼 (Code)** | [GitHub Repository](https://github.com/Xenia6667/Data_Analysis_Portfolio/tree/main/Stock_System_Project) |

---

## 1. 專案摘要 (Executive Summary)

| | |
|---|---|
| **背景 (Background)** | 個人投資者缺乏自動化工具來同步擷取股市數據、計算技術指標並即時接收交易訊號，依賴手動查詢效率低且容易錯失時機。 |
| **方法 (Method)** | 建立以 Python + PostgreSQL 為核心的全端技術分析系統，涵蓋數據管道、技術指標引擎、訊號生成，並以 FastAPI 提供 Webhook 接口。 |
| **成果 (Results)** | 完成 OHLCV 數據自動化擷取與儲存、4 套技術指標引擎（MA、Fibonacci、S&R、Signal），系統可穩定運行並輸出交易訊號。 |

---

## 2. 數據來源 (Data Source)

| | |
|---|---|
| **資料集** | Yahoo Finance OHLCV 歷史數據 |
| **平台** | yfinance Python 套件 |
| **內容** | 開盤價、最高價、最低價、收盤價、成交量（OHLCV）、調整後收盤價 |
| **資料粒度** | 日頻（Daily） |
| **涵蓋標的** | 可自訂股票代號（支援台股、美股） |

---

## 3. 核心功能 (Core Features)

### 技術指標引擎 (Indicator Engines)

| 指標 | 檔案 | 說明 |
|---|---|---|
| **Moving Average (MA)** | `ma_engine.py` | 多週期 MA 計算，支援 SMA / EMA |
| **Fibonacci Retracement** | `fib_engine.py` | 自動識別波段高低點並計算回調位（23.6%–78.6%） |
| **Support & Resistance** | `sr_engine.py` | 基於歷史價格區間的支撐與阻力位自動偵測 |
| **Signal Engine** | `signal_engine.py` | 綜合多項指標生成買賣訊號（突破、交叉、回測） |

---

## 4. 技術實作與代碼 (Implementation)

### 資料夾結構 (Project Structure)

```
Stock_System_Project/
├── Data_Pipeline/
│   └── fetch_yfinance.py       ← 自動擷取 OHLCV 數據
├── Database/
│   └── stock_system.pages      ← PostgreSQL Schema 定義
├── Indicators/
│   ├── ma_engine.py            ← 移動平均線（MA）
│   ├── fib_engine.py           ← 費波那契回調位
│   ├── sr_engine.py            ← 支撐與阻力偵測
│   └── signal_engine.py        ← 交易訊號生成
├── Notebooks/
│   └── 01_data_exploration.ipynb
├── Tableau/                    ← 儀表板（開發中）
├── Webhook/                    ← 即時事件觸發
├── Documentation/
└── requirements.txt
```

### 流程架構 (Workflow)

| 步驟 | 工具 | 說明 |
|---|---|---|
| **1. 數據擷取** | yfinance | 自動抓取指定股票代號的 OHLCV 歷史數據 |
| **2. 數據儲存** | PostgreSQL / psycopg2 | 寫入結構化資料表，支援增量更新 |
| **3. 數據探索** | pandas / Jupyter | 資料品質檢查、分布視覺化 |
| **4. 指標計算** | pandas / numpy / ta | 執行 MA、Fibonacci、S&R、Signal 四套引擎 |
| **5. 訊號推送** | FastAPI / WebSocket | 即時推送交易訊號至 Webhook 接口 |
| **6. 視覺化** | Tableau（開發中） | 互動式技術分析儀表板 |

### 技術棧 (Tech Stack)

| 技術 | 用途 |
|---|---|
| **Python / pandas / numpy** | 數據處理、指標計算 |
| **yfinance** | 股市數據擷取 |
| **PostgreSQL / psycopg2** | 數據儲存與查詢 |
| **scipy / ta** | 技術指標輔助計算 |
| **FastAPI / uvicorn** | REST API 與 Webhook 接口 |
| **websockets** | 即時數據推送 |
| **matplotlib / Tableau** | 視覺化與儀表板 |

### 快速開始 (Quick Start)

```bash
# 1. 安裝依賴
pip install -r requirements.txt

# 2. 建立資料庫
psql -c "CREATE DATABASE stock_system;"

# 3. 執行數據管道
python Data_Pipeline/fetch_yfinance.py

# 4. 開啟探索筆記本
jupyter notebook Notebooks/01_data_exploration.ipynb
```

---

## 5. 開發進度 (Development Phases)

| 階段 | 狀態 | 說明 |
|---|---|---|
| Phase 1 — PostgreSQL Schema | ✅ 完成 | 資料庫結構設計 |
| Phase 2 — yfinance 數據管道 | ✅ 完成 | 自動化數據擷取與儲存 |
| Phase 3 — 數據探索筆記本 | ✅ 完成 | EDA 與資料品質驗證 |
| Phase 4 — 技術指標引擎 | ✅ 完成 | MA、Fibonacci、S&R、Signal |
| Phase 5 — FastAPI Webhook | 🔄 進行中 | 即時訊號推送接口 |
| Phase 6 — Tableau 儀表板 | 📋 規劃中 | 互動式技術分析視覺化 |

---

## 6. 商業建議與下一步 (Recommendations & Next Steps)

| | |
|---|---|
| **近期目標** | 完成 FastAPI Webhook 整合，實現交易訊號的即時推送 |
| **中期目標** | 建立 Tableau 儀表板，視覺化多股票技術指標比較 |
| **長期目標** | 整合回測框架（Backtrader），量化各指標組合的歷史績效 |

### 未來延伸方向 (Next Steps)

- 加入情緒分析模組（新聞 + 社群數據），補充技術面指標
- 建立多股票同步監控 Dashboard，支援自訂警報
- 接入券商 API 實現半自動化交易執行
