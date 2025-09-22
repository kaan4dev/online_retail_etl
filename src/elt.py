import pandas as pd


def extract(xlsx_path: str):
    df = pd.read_excel(xlsx_path)
    df.to_csv("data/raw/online_retail_II.csv", index=False)
    print(df.head())

if __name__ == "__main__":
    extract("data/raw/online_retail_II.xlsx")


