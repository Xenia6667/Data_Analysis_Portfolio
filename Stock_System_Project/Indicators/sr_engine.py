import pandas as pd
import numpy as np
from scipy.signal import find_peaks
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
    print(f"計算 {symbol} 支撐壓力...")

    subset = df[df['symbol'] == symbol].copy()
    subset = subset.sort_values('date').reset_index(drop=True)

    closes = subset['close'].values

    # 找局部高點（壓力）和低點（支撐）
    peaks, _   = find_peaks(closes, distance=10)
    troughs, _ = find_peaks(-closes, distance=10)

    for i in range(len(subset)):
        row = subset.iloc[i]

        # 找最近的壓力位（比當前價格高的最近高點）
        past_peaks = [p for p in peaks if p < i and closes[p] > closes[i]]
        resistance = float(closes[past_peaks[-1]]) if past_peaks else None

        # 找最近的支撐位（比當前價格低的最近低點）
        past_troughs = [t for t in troughs if t < i and closes[t] < closes[i]]
        support = float(closes[past_troughs[-1]]) if past_troughs else None

        cursor.execute("""
            INSERT INTO indicators (symbol, date, support, resistance)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (symbol, date) DO UPDATE
            SET support    = EXCLUDED.support,
                resistance = EXCLUDED.resistance
        """, (
            symbol,
            row['date'],
            support,
            resistance
        ))

conn.commit()
cursor.close()
conn.close()
print("支撐壓力計算完成！")