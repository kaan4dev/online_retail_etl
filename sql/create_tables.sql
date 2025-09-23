CREATE TABLE IF NOT EXISTS dim_customer(
    customer_id INTEGER PRIMARY KEY,
    country TEXT
);

CREATE TABLE IF NOT EXISTS dim_product (
    stock_code  TEXT PRIMARY KEY,
    description TEXT
);

CREATE TABLE IF NOT EXISTS fact_sales (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_no   TEXT,
    stock_code   TEXT,
    customer_id  INTEGER,
    invoice_date TEXT,
    quantity     INTEGER,
    unit_price   REAL,
    revenue      REAL,
    FOREIGN KEY (stock_code) REFERENCES dim_product(stock_code),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id)
);