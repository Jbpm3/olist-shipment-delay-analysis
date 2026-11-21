# Codex Handoff — Olist Shipment Delay Analysis

**Updated:** 2026-11-19 (Asia/Manila)

> This document is a curated handoff of conversation context, **not** a direct export of ChatGPT's hidden memory or a verified snapshot of the user's local filesystem. Check actual repository files before making claims or modifications.

## User and collaboration preferences

- User is a BS Computer Science student at the University of San Carlos, Cebu, Philippines, expected to graduate around June 2027. They are pursuing Data Analyst / Data Engineer roles and a university OJT of 300 hours expected to begin January 2027.
- Primary career interest is Data Engineering, with Data Analytics as a near-term adjacent path; may explore AI Engineering later.
- **Learning goal:** user writes and understands their own SQL and Python, rather than delegating implementation to an AI agent. Treat Codex as a code reviewer, debugging assistant, repository inspector, or mentor unless the user explicitly authorizes implementation.
- Provide focused, incremental tasks; explain why changes matter; review the user's attempt before offering complete solutions. One task at a time; aim for manageable 45–60-minute sessions and a clear stopping point. Avoid needless complexity or unsolicited refactors.
- Keep assistance concise and practical. Do not invent execution results. Distinguish confirmed local results from code that only *appears* correct.
- GitHub account: `Jbpm3`. Project repository: https://github.com/Jbpm3/olist-shipment-delay-analysis . GitHub repository may lag behind user's working directory.
- Past team project Hubas was built with Team MangoSpace for NASA Space Apps Challenge 2026; much of the team's technical implementation was performed through autonomous Codex workflows. Do not imply NASA employment or misrepresent the user's hand-coded contributions.

## Olist project goal

Analyze shipment delays in the public Brazilian Olist e-commerce dataset, demonstrate analytical SQL, Python ETL-style processing, data-quality checks, and build a Streamlit dashboard that can eventually be deployed. The project uses local PostgreSQL, pandas, SQLAlchemy, psycopg, python-dotenv, and Streamlit. Original raw CSVs remain untracked.

## Current known structure (some files may only exist locally)

```text
olist-shipment-delay-analysis/
├── data/raw/                        # Raw input CSVs; gitignored
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_data_validation.sql
│   ├── 03_delivery_analysis.sql
│   ├── 04_regional_analysis.sql
│   ├── 05_monthly_trends.sql
│   └── 06_delay_distribution.sql
├── docs/findings.md
├── scripts/
│   ├── test_connection.py
│   └── export_regional_data.py       # Now exports regional AND monthly metrics
├── dashboard/
│   ├── app.py                        # Basic Streamlit app drafted; launch NOT yet confirmed
│   └── data/
│       ├── regional_delivery_metrics.csv
│       └── monthly_delivery_metrics.csv
├── .env                              # Local credentials; NEVER commit
├── .venv/                            # Local virtualenv; NEVER commit
├── .gitignore
├── AGENTS.md                         # May exist locally and may be gitignored
└── README.md
```

## Verified SQL/data findings from earlier work

- `orders` and `customers` tables each have **99,441** rows; no orphan orders under existing FK checks.
- Eligibility for delay analysis: status delivered AND non-null actual delivery timestamp AND non-null estimated delivery timestamp. **96,470** eligible delivered orders.
- Delay measured by `order_delivered_customer_date::DATE > order_estimated_delivery_date::DATE` (calendar dates, not raw timestamps).
- **6,534** late orders; **6.77%** late rate.
- Late-order delay days: mean **10.62**, median **7**, min **1**, max **188**.
- **2,965** orders missing actual delivery timestamp, including **8** records marked delivered.
- **1,359** orders show carrier handoff timestamp before approval timestamp; treat as data-quality anomalies, not necessarily evidence that estimated-versus-actual delivery analysis is invalid. Preserve and document source records.
- Regional aggregation: 27 Brazilian customer states; totals reconcile to 96,470 eligible and 6,534 late deliveries. Example late percentages: AL 21.41% (85/397), MA 17.43% (125/717), RJ 12.11% (1,495/12,350), SP 4.49% (1,820/40,494).
- Monthly aggregation by **purchase month**, not delivery month: **23** months, totals reconcile to 96,470 and 6,534. March 2018 18.96% (1,328/7,003), February 2018 14.13% (926/6,555), November 2017 12.40% (904/7,288). September 2016 contains only **1** eligible order, giving a misleading **100%** rate; do not generalize from tiny sample sizes.
- Delay distribution among 6,534 late orders: 1–3d = 1,870; 4–7d = 1,802; 8–14d = 1,478; 15–30d = 1,039; 31+d = 345.

## Python pipeline — completed

- Built local Python virtual environment and connected to local PostgreSQL via SQLAlchemy URL object and `postgresql+psycopg`, with credentials loaded from `.env` using `python-dotenv`.
- Reusable function in script:

```python
def load_sql_data(sql_file, engine):
    sql_query = sql_file.read_text(encoding="utf-8")
    df = pd.read_sql_query(sql_query, engine)
    return df
```

- Regional CSV export from `sql/04_regional_analysis.sql` has passed `assert len(df)==27`, `sum(total_delivered_orders)==96470`, and `sum(late_orders)==6534` and exported `dashboard/data/regional_delivery_metrics.csv`.
- Monthly CSV export from `sql/05_monthly_trends.sql` has passed `assert len(monthly_df)==23`, `sum(total_delivered_orders)==96470`, and `sum(late_orders)==6534` and exported `dashboard/data/monthly_delivery_metrics.csv`. User showed monthly CSV rows.
- SQL is authored to rank months by late percentage, so monthly CSV is **not chronological**. Sort by parsed purchase-month date before making time-series charts.
- `.env`, `.venv`, and raw data should stay out of Git. Simple `assert` checks were used for learning; later consider explicit exceptions since assertions can be disabled with Python optimized mode.

## Streamlit — current checkpoint (Session 5)

User wrote this in `dashboard/app.py`:

```python
import streamlit as st
import pandas as pd
from pathlib import Path

regional_file = Path(__file__).parent / "data" / "regional_delivery_metrics.csv"

df = pd.read_csv(regional_file)

st.title("Olist Shipment Delay Analysis")

st.dataframe(df)
```

**Most recent state:** Code reviewed as correct, but user has **not yet confirmed successfully launching** the local Streamlit app or seeing the 27-state table in browser.

**Next immediate task:** Have user run from repo root:

```powershell
python -m streamlit run dashboard/app.py
```

Confirm app at localhost:8501 and regional dataframe visible; then teach `st.metric()` for total eligible deliveries (96,470), late deliveries (6,534), and late rate (6.77%) calculated from DataFrame rather than hardcoded where feasible. Later load monthly CSV, sort by `purchase_month`, and add meaningful charts. The user should write code first with gentle hints.

## Workflow safeguards

- Treat this handoff as context, not authoritative local repository status; inspect files/git status if asked.
- Do not edit, commit, push, install dependencies, or deploy without user authorization. For learning sessions, prefer explaining an approach and reviewing user code.
- Do not commit secrets, private `.env`, raw files, or credentials. Check distribution terms for original data.
- Do not assume AWS S3 integration is built; the user is interested in learning AWS S3 for internships, but current Olist pipeline is local CSV only.

## Suggested Codex opening prompt

> Read `CODEX_OLIST_CONTEXT_HANDOFF.md` and any applicable `AGENTS.md`. Review the repository in read-only mode. Summarize my current progress and explain the next single learning task, without editing any files unless I explicitly ask. I'm learning SQL and Python myself, so coach rather than implement for me.
