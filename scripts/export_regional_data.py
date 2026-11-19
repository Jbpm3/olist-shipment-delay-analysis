# imports and libraries
import os
import pandas as pd

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

from pathlib import Path

# output configs
output_dir = Path("dashboard/data")
output_dir.mkdir(parents=True, exist_ok=True)

output_file = output_dir / "regional_delivery_metrics.csv"

load_dotenv()

# database 

database_url = URL.create(
    drivername="postgresql+psycopg",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT","5432")),
    database=os.getenv("DB_NAME")
)



engine = create_engine(database_url)

# function

def load_sql_data(sql_file,engine):
    # 1. Read the SQL file
    
    sql_query = sql_file.read_text(encoding="utf-8")
    
    # 2. Execute the SQL query using pandas
    
    df = pd.read_sql_query(sql_query,engine)
    # 3. Return the resulting DataFrame
    
    return df

sql_file = Path("sql/04_regional_analysis.sql")
df = load_sql_data(sql_file,engine)

# validate extracted data

assert len(df) == 27, "Expected 27 Brazillian states"

assert df["total_delivered_orders"].sum() == 96470,  "Expected 96,470 total delivered orders"

assert df["late_orders"].sum() == 6534,  "Expected 6534 total total late orders"

# print statements

print(f"Number of states: {len(df)}")
print(f"Sum of total delivered orders: {df['total_delivered_orders'].sum():,}")
print(f"Sum of late_orders: {df['late_orders'].sum():,}")

# output the file to csv

df.to_csv(output_file, index=False)

print(f"CSV exported successfully to: {output_file}")

# monthly trends

monthly_sql_file = Path("sql/05_monthly_trends.sql")

monthly_df = load_sql_data(monthly_sql_file,engine)

# asserting

assert(len(monthly_df)) == 23, "Expected 23 months"

assert(monthly_df["total_delivered_orders"].sum()) == 96470, "Expected 96,470 deliveries"

assert(monthly_df["late_orders"].sum()) == 6534, "Expected 6,534 late deliveries"

# printing

print(f"Number of months: {len(monthly_df)}")
print(f"Total deliveries: {monthly_df['total_delivered_orders'].sum():,}")
print(f"Total late deliveries: {monthly_df['late_orders'].sum():,}")

# outputting

monthly_output_file = output_dir / "monthly_delivery_metrics.csv"

monthly_df.to_csv(monthly_output_file,index=False)

# print success

print(f"Monthly CSV exported to: {monthly_output_file}")