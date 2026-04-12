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

df = pd.read_sql("SELECT * FROM prices_daily ORDER BY symbol, date", engine)

symbols = df['symbol'].unique()

for symbol in symbols:
    print(f"計算 {symbol} Fibonacci...")

    subset = df[df['symbol'] == symbol].copy()
    subset = subset.sort_values('date').reset_index(drop=True)

    # 用滾動視窗找波段高低點（60天）
    window = 60

    for i in range(window, len(subset)):
        chunk = subset.iloc[i-window:i]
        high = chunk['high'].max()
        low  = chunk['low'].min()
        diff = high - low

        # 回撤位
        fib_236 = high - diff * 0.236
        fib_382 = high - diff * 0.382
        fib_500 = high - diff * 0.500
        fib_618 = high - diff * 0.618
        fib_786 = high - diff * 0.786

        row = subset.iloc[i]

        cursor.execute("""
            INSERT INTO indicators (symbol, date, fib_high, fib_low, fib_236, fib_382, fib_500, fib_618, fib_786)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (symbol, date) DO UPDATE
            SET fib_high = EXCLUDED.fib_high,
                fib_low  = EXCLUDED.fib_low,
                fib_236  = EXCLUDED.fib_236,
                fib_382  = EXCLUDED.fib_382,
                fib_500  = EXCLUDED.fib_500,
                fib_618  = EXCLUDED.fib_618,
                fib_786  = EXCLUDED.fib_786
        """, (
            symbol,
            row['date'],
            float(high),
            float(low),
            float(fib_236),
            float(fib_382),
            float(fib_500),
            float(fib_618),
            float(fib_786)
        ))

conn.commit()
cursor.close()
conn.close()
print("Fibonacci 計算完成！")