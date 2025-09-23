import pandas as pd
from sqlalchemy import create_engine

DB_PATH = "data/retail.sqlite"

def export_tables():
    engine = create_engine(f"sqlite:///{DB_PATH}")

    tables = ["dim_customer", "dim_product", "fact_sales"]

    for table in tables:
        df = pd.read_sql(f"SELECT * FROM {table}", engine)
        csv_path = f"data/{table}.csv"
        df.to_csv(csv_path, index=False)
        print(f"{table} is saved as .csv: {csv_path}")

if __name__ == "__main__":
    export_tables()
