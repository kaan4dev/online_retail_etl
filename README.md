# Online Retail ETL & Analytics

This project builds a complete extract-transform-load (ETL) workflow for the **Online Retail II** dataset and ships with ready-to-run analytical queries, curated dimensional tables, Google BigQuery export routines, and supporting Docker / Airflow assets for orchestration experiments. It is designed to showcase how raw transactional data can be cleaned, modelled, warehoused, and queried using an approachable Python stack that scales to cloud data warehousing.

## Project Overview
- **Goal:** Convert the raw `Online Retail II` Excel workbook into a clean star schema, expose it as both a local SQLite analytics database and a cloud BigQuery dataset, and surface common business questions through SQL.
- **Dataset:** UCI Machine Learning Repository – Online Retail II (01/2009–12/2011). The workbook is stored locally as `data/raw/online_retail_II.xlsx` with an intermediary CSV copy at `data/raw/online_retail_II.csv`.
- **Deliverables:**
  - A reproducible ETL pipeline (`src/elt.py`, `src/load.py`, `src/transform.py`, `src/export_csv.py`).
  - A SQLite warehouse (`data/retail.sqlite`) with one fact table and two dimensions.
  - BigQuery loading workflow for cloud analytics (manual `bq load` or scripted extension).
  - Example analytics queries in `sql/queries.sql` and DDL in `sql/create_tables.sql`.
  - Optional Apache Airflow setup via `docker-compose.yaml` for orchestration practice.
  - Notebook scaffold (`notebooks/retail_analysis.ipynb`) for exploratory analysis and visualisation.

## Tech Stack & Features
- **Python 3.x**
  - `pandas` for ingestion, cleansing, feature engineering.
  - `sqlalchemy` for database connectivity and DDL/DML execution.
  - `openpyxl` for Excel ingestion.
  - `matplotlib` / `seaborn` (used in notebooks) for exploratory visualisations.
- **SQLite** as the embedded analytics warehouse and transformation sandbox.
- **Google Cloud Platform**
  - `gcloud` CLI for project configuration.
  - **BigQuery** for hosting the cleaned star schema in the cloud.
- **Airflow 2.9 (CeleryExecutor)** for orchestrating ETL jobs, backed by Redis and Postgres via Docker Compose.
- **Docker Compose** for containerising the orchestration stack.
- **SQL** for dimensional modelling (DDL) and analytics (DML queries in `sql/queries.sql`).
- **Data Warehousing Concepts**: star schema, dimension/fact separation, feature engineering (revenue, region mapping), analytical aggregations.

## Data Pipeline
```
Excel (.xlsx)
   └── src/elt.py → data/raw/online_retail_II.csv
         └── src/load.py → SQLite staging table (stg_sales)
               └── src/transform.py → dim_customer, dim_product, fact_sales
                     └── src/export_csv.py → data/dim_*.csv & data/fact_sales.csv
                             └── (optional) BigQuery load → Cloud dataset
```

1. **Extract (`src/elt.py`)**
   - Reads the Excel workbook with `pandas.read_excel` backed by `openpyxl`.
   - Persists a raw CSV replica (`data/raw/online_retail_II.csv`) for downstream, file-based processing or cloud uploads.

2. **Load (`src/load.py`)**
    - Creates a SQLAlchemy engine pointed at `data/retail.sqlite`.
    - Loads the CSV into a staging table `stg_sales` inside SQLite (replace mode for idempotency).

3. **Transform (`src/transform.py`)**
    - Cleans data (drops null customer IDs, removes cancelled invoices, enforces positive quantity/price values, standardises descriptions).
    - Converts invoice timestamps to ISO format, engineers `revenue`, and enriches each customer with a derived `region`.
    - Builds and loads the dimensional model:
      - `dim_customer(customer_id, country, region)`
      - `dim_product(stock_code, description)`
      - `fact_sales(invoice_no, stock_code, customer_id, invoice_date, quantity, unit_price, revenue)`

4. **Export (`src/export_csv.py`)**
    - Materialises the dimensional tables and fact table as CSVs under `data/` for sharing, BI ingestion, or BigQuery loading.

5. **Cloud Publishing (optional)**
    - Use the generated CSVs to load tables into BigQuery with `bq load` or via a custom DAG step. Suggested target schema mirrors the SQLite tables.

## Data Model
| Table        | Grain/Key                         | Purpose | Notes |
|--------------|------------------------------------|---------|-------|
| `dim_customer` | One row per `customer_id`          | Stores customer geography, including a derived continent-level `region`. | Filtered to non-null customer IDs.
| `dim_product`  | One row per `stock_code`           | Catalog of product descriptions normalised to uppercase. | Description trimmed for consistent grouping.
| `fact_sales`   | One row per invoice line (`invoice_no`, `stock_code`, `customer_id`) | Transaction fact table including quantities, pricing, and computed `revenue`. | Referenced by both dimensions; created with foreign key constraints.
| `stg_sales`    | One row per raw record (temporary) | Landing table used during transforms. | Recreated on every load.

## Repository Layout
```
├── src/
│   ├── elt.py             # Excel → CSV
│   ├── load.py            # CSV → SQLite staging
│   ├── transform.py       # Cleansing + dimensional model
│   └── export_csv.py      # SQLite tables → dimensional CSVs (→ BigQuery)
├── sql/
│   ├── create_tables.sql  # Standalone DDL to bootstrap schema
│   └── queries.sql        # Example BI queries (monthly revenue, top products, etc.)
├── data/
│   ├── raw/               # Source files (Excel + raw CSV)
│   ├── retail.sqlite      # Materialised warehouse
│   ├── dim_*.csv          # Exported dimensions (generated)
│   └── fact_sales.csv     # Exported fact table (generated)
├── docker-compose.yaml    # Airflow stack for orchestration experiments
├── notebooks/             # Exploratory analysis notebooks (visualisation-ready)
├── .env                   # Docker/Airflow environment defaults
└── README.md
```

