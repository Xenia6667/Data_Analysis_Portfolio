import pandas as pd
from sqlalchemy import create_engine
import psycopg2

# 用 SQLAlchemy 連線
engine = create_engine("postgresql+psycopg2://aditi@localhost:5432/stock_system")

# 用 psycopg2 寫入
conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="stock_system",
    user="aditi",
    password=""
)
cursor = conn.cursor()

# 讀取所有股票
df = pd.read_sql("SELECT * FROM prices_daily ORDER BY symbol, date", engine)
print(f"讀到 {len(df)} 筆資料")

symbols = df['symbol'].unique()

for symbol in symbols:
    print(f"計算 {symbol} 均線...")
    
    subset = df[df['symbol'] == symbol].copy()
    subset = subset.sort_values('date').reset_index(drop=True)
    
    subset['ma20']  = subset['close'].rolling(window=20).mean()
    subset['ma60']  = subset['close'].rolling(window=60).mean()
    subset['ma240'] = subset['close'].rolling(window=240).mean()
    
    for _, row in subset.iterrows():
        cursor.execute("""
            INSERT INTO indicators (symbol, date, ma20, ma60, ma240)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (symbol, date) DO UPDATE
            SET ma20 = EXCLUDED.ma20,
                ma60 = EXCLUDED.ma60,
                ma240 = EXCLUDED.ma240
        """, (
            symbol,
            row['date'],
            None if pd.isna(row['ma20'])  else float(row['ma20']),
            None if pd.isna(row['ma60'])  else float(row['ma60']),
            None if pd.isna(row['ma240']) else float(row['ma240'])
        ))

conn.commit()
cursor.close()
conn.close()
print("MA 均線計算完成！")