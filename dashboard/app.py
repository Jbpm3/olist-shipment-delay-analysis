import streamlit as st 
import pandas as pd
from pathlib import Path

regional_file = Path(__file__).parent / "data" / "regional_delivery_metrics.csv"

df = pd.read_csv(regional_file)

st.title("Olist Shipment Delay Analysis")

st.dataframe(df)