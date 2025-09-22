import pandas as pd
from sqlalchemy import create_engine

def load_to_sql(csv_path: str, db_path: str = "data/retail.sqlite"):
    engine = create_engine(f"sqlite:///{db_path}")

    df = pd.read_csv(csv_path)

    df.to_sql("stg_sales", engine, if_exists= "replace", index= False)
    print(f"Data is loaded to SQLite: {db_path}")

if __name__ == "__main__":
    load_to_sql("data/raw/online_retail_II.csv")