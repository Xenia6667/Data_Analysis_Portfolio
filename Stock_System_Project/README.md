# Stock System Project

A full-stack stock market data pipeline and technical analysis system built with Python and PostgreSQL.

## Project Structure

```
Stock_System_Project/
├── Data_Pipeline/
│   └── fetch_yfinance.py       # Fetch OHLCV data from Yahoo Finance
├── Database/
│   └── stock_system.pages      # PostgreSQL schema definitions
├── Documentation/              # Project notes and specs
├── Indicators/
│   ├── ma_engine.py            # Moving Average (MA) calculations
│   ├── fib_engine.py           # Fibonacci retracement levels
│   ├── sr_engine.py            # Support & Resistance detection
│   └── signal_engine.py        # Trading signal generation
├── Notebooks/
│   └── 01_data_exploration.ipynb  # Data quality checks and EDA
├── Tableau/                    # Dashboard files
├── Webhook/                    # Real-time event triggers
└── requirements.txt
```

## Tech Stack

| Layer | Tools |
|-------|-------|
| Data Source | yfinance |
| Database | PostgreSQL + psycopg2 |
| Analysis | pandas, numpy, scipy, ta |
| API | FastAPI + uvicorn |
| Real-time | websockets |
| Visualization | matplotlib, Tableau |

## Setup

**1. Install dependencies**
```bash
pip install -r requirements.txt
```

**2. Set up PostgreSQL**

Create the database:
```sql
CREATE DATABASE stock_system;
```

**3. Run the data pipeline**
```bash
python Data_Pipeline/fetch_yfinance.py
```

**4. Explore the data**

Open `Notebooks/01_data_exploration.ipynb` and run cells in order.

## Phases

- [x] Phase 1 — PostgreSQL schema design
- [x] Phase 2 — yfinance data pipeline
- [x] Phase 3 — Data exploration notebook
- [ ] Phase 4 — Technical indicator engine (MA, Fibonacci, S&R, Signals)
- [ ] Phase 5 — FastAPI webhook integration
- [ ] Phase 6 — Tableau dashboard
