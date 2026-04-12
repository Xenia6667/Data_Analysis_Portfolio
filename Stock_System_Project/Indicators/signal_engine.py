import pandas as pd
from sqlalchemy import create_engine
import psycopg2

engine = create_engine("postgresql+psycopg2://aditi@localhost:5432/stock_system")

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="stock_system",
    user="aditi",
    password=""
)
cursor = conn.cursor()

# 讀取行情和指標
prices = pd.read_sql("SELECT * FROM prices_daily ORDER BY symbol, date", engine)
indicators = pd.read_sql("SELECT * FROM indicators ORDER BY symbol, date", engine)

df = pd.merge(prices, indicators, on=['symbol', 'date'], how='inner')
symbols = df['symbol'].unique()

for symbol in symbols:
    print(f"計算 {symbol} 訊號...")

    subset = df[df['symbol'] == symbol].copy()
    subset = subset.sort_values('date').reset_index(drop=True)

    for _, row in subset.iterrows():
        close = row['close']
        signal = 'watch'
        reasons = []

        # MA 均線多空判斷
        if pd.notna(row['ma20']) and pd.notna(row['ma60']):
            if row['ma20'] > row['ma60']:
                reasons.append('MA多頭')
            else:
                reasons.append('MA空頭')

        # Fibonacci 位階判斷
        if pd.notna(row['fib_618']) and pd.notna(row['fib_382']):
            if close <= row['fib_618']:
                reasons.append('Fib強支撐')
                signal = 'buy'
            elif close >= row['fib_382']:
                reasons.append('Fib壓力區')
                signal = 'sell'

        # 支撐壓力判斷
        if pd.notna(row['support']) and pd.notna(row['resistance']):
            if close <= row['support'] * 1.02:
                reasons.append('近支撐')
            elif close >= row['resistance'] * 0.98:
                reasons.append('近壓力')

        alert_type = ' | '.join(reasons) if reasons else '觀望'

        cursor.execute("""
            INSERT INTO alerts (symbol, alert_type, signal, price, source)
            VALUES (%s, %s, %s, %s, %s)
        """, (
            symbol,
            alert_type,
            signal,
            float(close),
            'signal_engine'
        ))

conn.commit()
cursor.close()
conn.close()
print("訊號計算完成！")