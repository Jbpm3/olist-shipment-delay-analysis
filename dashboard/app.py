import streamlit as st 
import pandas as pd
from pathlib import Path

#initialization
regional_file = Path(__file__).parent / "data" / "regional_delivery_metrics.csv"

monthly_file = Path(__file__).parent / "data" / "monthly_delivery_metrics.csv"



df = pd.read_csv(regional_file)
    
monthly_df = pd.read_csv(monthly_file)

st.title("Olist Shipment Delay Analysis")

st.caption(
    "An exploratory analysis of delivery performance "
    "across Brazillian e-commerce orders. "
)

# KPI
total_deliveries = df["total_delivered_orders"].sum()
total_late_deliveries = df["late_orders"].sum()
late_delivery_rate = (total_late_deliveries / total_deliveries) * 100


col1, col2, col3 = st.columns(3)

col1.metric(
    label="Total Deliveries",
    value=f"{total_deliveries:,}"
)

col2.metric(
    label="Total Late Deliveries",
    value=f"{total_late_deliveries:,}"
)

col3.metric(
    label="Late Delivery Rate",
    value=f"{late_delivery_rate:.2f}%"
)

st.subheader("Late Delivery Rate by State")

# slider and num imput 

if "slider_value" not in st.session_state:
    st.session_state.slider_value = 100
    
if "input_value" not in st.session_state:
    st.session_state.input_value = 100
    
# synchronization functions
def update_input():
    st.session_state.input_value = st.session_state.slider_value
    
def update_slider():
    st.session_state.slider_value = st.session_state.input_value
    
# display controls side by side
slider_col, input_col = st.columns([3,1])

with slider_col:
    st.slider(
        "Minimum number of deliveries",
        min_value=0,
        max_value=5000,
        key ="slider_value",
        on_change = update_input
    )

with input_col:
    st.number_input(
        "Minimum number of deliveries",
        min_value=0,
        max_value=5000,
        step=1,
        key = "input_value",
        on_change=update_slider
    )

minimum_deliveries = st.session_state.slider_value

filtered_df = df[df["total_delivered_orders"] >= minimum_deliveries]

st.bar_chart(
    filtered_df,
    x="customer_state",
    y="late_delivery_pct",
    horizontal=True
)


with st.expander("View Regional Data"):
    st.dataframe(df)

monthly_df["purchase_month"] = pd.to_datetime(
    monthly_df["purchase_month"]
)

monthly_df = monthly_df.sort_values(
    "purchase_month"
)

filtered_monthly_df = monthly_df[
    monthly_df["total_delivered_orders"] >= 100
]

st.subheader("Monthly Delivery Trends")

st.line_chart(
    filtered_monthly_df,
    x="purchase_month",
    y="late_delivery_pct"
)
st.caption(
    "Showing purchase months with at least 100 eligible deliveries. "
    "Months with fewer deliveries are excluded to reduce distortion "
    "from very small sample sizes."
)

with st.expander("View Regional Data"):
    st.dataframe(monthly_df)


