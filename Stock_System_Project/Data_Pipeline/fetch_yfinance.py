import yfinance as yf
import psycopg2
from datetime import datetime

# 資料庫連線設定
conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="stock_system",
    user="aditi",
    password=""
)
cursor = conn.cursor()

# 要抓的股票清單
symbols = ["2330.TW", "0050.TW"]

for symbol in symbols:
    print(f"正在抓取 {symbol}...")
    
    # 用 yfinance 抓近一年資料
    ticker = yf.Ticker(symbol)
    df = ticker.history(period="1y")
    
    # 清洗欄位
    df = df.reset_index()
    df.columns = [c.lower() for c in df.columns]
    df = df[["date", "open", "high", "low", "close", "volume"]]
    df["date"] = df["date"].dt.date
    df = df.dropna()

    # 寫入資料庫
    for _, row in df.iterrows():
        cursor.execute("""
            INSERT INTO prices_daily (symbol, date, open, high, low, close, volume)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (symbol, date) DO NOTHING
        """, (symbol, row["date"], row["open"], row["high"], row["low"], row["close"], row["volume"]))

conn.commit()
cursor.close()
conn.close()
print("完成！")