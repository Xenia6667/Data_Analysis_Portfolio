import pandas as pd
from sqlalchemy import create_engine
import os

engine = create_engine("postgresql+psycopg2://aditi@localhost:5432/stock_system")

# 匯出資料夾
output_dir = "tableau"
os.makedirs(output_dir, exist_ok=True)

tables = ["prices_daily", "indicators", "alerts", "holdings"]

for table in tables:
    print(f"匯出 {table}...")
    df = pd.read_sql(f"SELECT * FROM {table}", engine)
    df.to_csv(f"{output_dir}/{table}.csv", index=False)
    print(f"  → {len(df)} 筆，存到 tableau/{table}.csv")

print("全部匯出完成！")