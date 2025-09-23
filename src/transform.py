from sqlalchemy import create_engine, text
import pandas as pd

def transform(db_path: str = "data/retail.sqlite"):
    
    engine = create_engine(f"sqlite:///{db_path}")

    df = pd.read_sql("SELECT * FROM stg_sales", engine)

    # drop the na customer id values
    df = df.dropna(subset=["Customer ID"])

    # drop the "cancelled" checks
    df = df[~df["Invoice"].astype(str).str.startswith("C")]

    # just use positive and not 0 values for the quantity and unit price variables
    df = df[(df["Quantity"] > 0) & (df["Price"] > 0)]

    # convert invoice data variable to iso format 
    df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"], errors="coerce")
    df = df.dropna(subset=["InvoiceDate"])
    df["InvoiceDate"] = df["InvoiceDate"].dt.strftime("%Y-%m-%d %H:%M:%S")

    # normalize the description variable
    df["Description"] = df["Description"].astype(str).str.strip().str.upper()

    # feature eng -> create revenue variable with the variables we already had
    df["revenue"] = df["Quantity"] * df["Price"]

    # seperate countries to the continents
    europe = ["UNITED KINGDOM", "FRANCE", "GERMANY", "SPAIN", "PORTUGAL", "NETHERLANDS", "BELGIUM", "SWITZERLAND", "AUSTRIA", "NORWAY", "SWEDEN", "FINLAND", "ITALY", "DENMARK", "IRELAND"]
    asia = ["JAPAN", "SINGAPORE", "HONG KONG", "CHINA", "KOREA", "TAIWAN"]
    america = ["USA", "CANADA", "BRAZIL"]

    def map_region(country):
        c = str(country).upper()
        if c in europe: return "Europe"
        elif c in asia: return "Asia"
        elif c in america: return "America"
        else: return "Other"

    df["region"] = df["Country"].map(map_region)

    # create dimension and fact tables
    with engine.begin() as conn:
        conn.execute(text("""
        CREATE TABLE IF NOT EXISTS dim_customer (
            customer_id TEXT PRIMARY KEY,
            country     TEXT,
            region      TEXT
        )"""))

        conn.execute(text("""
        CREATE TABLE IF NOT EXISTS dim_product (
            stock_code  TEXT PRIMARY KEY,
            description TEXT
        )"""))

        conn.execute(text("""
        CREATE TABLE IF NOT EXISTS fact_sales (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            invoice_no   TEXT,
            stock_code   TEXT,
            customer_id  TEXT,
            invoice_date TEXT,
            quantity     INTEGER,
            unit_price   REAL,
            revenue      REAL,
            FOREIGN KEY (stock_code) REFERENCES dim_product(stock_code),
            FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id)
        )"""))

    dim_customer = df[["Customer ID", "Country", "region"]].drop_duplicates()
    dim_customer.columns = ["customer_id", "country", "region"]

    dim_product = df[["StockCode", "Description"]].drop_duplicates()
    dim_product.columns = ["stock_code", "description"]

    fact_sales = df[[
        "Invoice", "StockCode", "Customer ID", "InvoiceDate",
        "Quantity", "Price", "revenue"
    ]].copy()
    fact_sales.columns = [
        "invoice_no", "stock_code", "customer_id", "invoice_date",
        "quantity", "unit_price", "revenue"
    ]
    
    dim_customer.to_sql("dim_customer", engine, if_exists="replace", index=False)
    dim_product.to_sql("dim_product", engine, if_exists="replace", index=False)
    fact_sales.to_sql("fact_sales", engine, if_exists="replace", index=False)

    print("Transform is done.")

if __name__ == "__main__":
    transform()
