import os
import pandas as pd

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

load_dotenv()

database_url = URL.create(
    drivername="postgresql+psycopg",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT","5432")),
    database=os.getenv("DB_NAME")
)

engine = create_engine(database_url)

sql_query = """
    SELECT COUNT(*) AS total_orders
    FROM orders;
"""

result = pd.read_sql_query(sql_query, engine)

print(result)