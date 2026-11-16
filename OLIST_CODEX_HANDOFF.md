# Olist Shipment Delay Analysis — ChatGPT-to-Codex Handoff

**Last updated:** 2026-11-16  
**Repository:** https://github.com/Jbpm3/olist-shipment-delay-analysis  
**Purpose:** Supply development context for a *read-only audit of the user's local repository*. This document summarizes what was discussed and reported in ChatGPT; it does **not** prove that each file is present, saved, correct, or committed on disk. Inspect the actual local files before drawing conclusions.

## Project goal

Build an independently understood and reproducible data-analysis workflow investigating shipment delays in the historical Brazilian Olist e-commerce dataset. Start with PostgreSQL/SQL, extend it with Python and pandas exports, then create and deploy a Streamlit dashboard (possibly using Plotly). The dashboard has **not** been built or deployed as of this handoff.

## Working environment

- Windows, VS Code, PostgreSQL with pgAdmin.
- Local database is named `olist_analysis`.
- Database includes at least `orders` and `customers`, each previously reported to contain **99,441** rows.
- Existing SQL scripts are expected under `sql/`, findings under `docs/findings.md`, raw CSVs under `data/raw/` (ignored by Git), and Python scripts under `scripts/`.
- Python environment uses `pandas`, `sqlalchemy`, `psycopg[binary]`, and `python-dotenv` installed in a virtual environment `.venv`.
- Database settings are expected in a local `.env`: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`. **Do not read, display, quote, print, or commit credential values.** Check only whether required variables are available if needed.
- `.env`, `.venv/`, `__pycache__/`, and raw datasets should not be committed.

## Definitions / rules to preserve

Eligible delivery = `order_status = 'delivered'` AND both `order_delivered_customer_date` and `order_estimated_delivery_date` are non-NULL.

Late delivery = `order_delivered_customer_date::date > order_estimated_delivery_date::date` (compare *calendar dates*, not full timestamp instants).

Delay days = `order_delivered_customer_date::date - order_estimated_delivery_date::date`. Duration distributions include **only** delays greater than 0.

Monthly delivery performance is grouped by the **purchase month** (`DATE_TRUNC('month', order_purchase_timestamp)::date`), not delivery month. Regional performance uses **customer state** via `orders.customer_id = customers.customer_id`.

Document anomalies and analytical exclusions rather than silently deleting or 'fixing' source data. Do not claim operational causes without evidence.

## Reported completed work and verified-in-chat results

### SQL schema and data validation

- `sql/01_create_tables.sql`: `orders`, `customers`, primary/foreign key relationships.
- `sql/02_data_validation.sql`: missing timestamp and integrity checks.
- Both tables initially had **99,441** records; orphan orders: **0**.
- Missing delivery timestamps: **2,965** total; **8** orders marked delivered had NULL delivery timestamp and must be excluded from delay metrics.
- **1,359** orders had a recorded carrier handoff before order approval; average discrepancy **24.75 hours**, median **17.17 hours**, maximum ~**171 days**. Keep source records and flag for investigation.

### Analysis 01 — Overall late-delivery rate

- `sql/03_delivery_analysis.sql` (actual file may contain multiple related analyses).
- Eligible delivered orders: **96,470**.
- Late delivered orders: **6,534**.
- Late-delivery rate: **6.77%**; on-time rate **93.23%**.

### Analysis 02 — Delay duration among late orders

- Mean delay **10.62 days**; median **7 days**; min **1 day**, max **188 days**.

### Analysis 03 — Regional performance

- `sql/04_regional_analysis.sql`.
- **27** Brazilian states; totals reconcile to **96,470** eligible and **6,534** late orders.
- AL **21.41%** (85/397), MA **17.43%** (125/717), SE **15.22%** (51/335), RJ **12.11%** (1,495/12,350), SP **4.49%** (1,820/40,494). Small state samples merit caution.

### Analysis 04 — Monthly delivery trends

- Intended file `sql/05_monthly_trends.sql` (verify local existence; it may not yet be committed).
- Query uses a `monthly_deliveries` CTE, `DATE_TRUNC`, conditional lateness flag, monthly `COUNT` and `SUM`, percentages.
- **23** purchase-month rows; monthly totals reconcile to **96,470 / 6,534**.
- Notable months: November 2017 **12.40%** (904/7,288), February 2018 **14.13%** (926/6,555), March 2018 **18.96%** (1,328/7,003), June 2018 **1.16%** (71/6,096).
- September 2016 had a 100% rate on only **1** eligible order; should not be used as a representative outlier.

### Analysis 05 — Delay distribution

- Intended file `sql/06_delay_distribution.sql` (verify local existence; it may not yet be committed).
- Two CTEs: calculate `delay_days` and categorize positive delays into `1-3 days`, `4-7 days`, `8-14 days`, `15-30 days`, `31+ days`.
- Final aggregation uses `COUNT(*)` and `ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)`.
- Results:

| Delay category | Orders | % of late orders |
|---|---:|---:|
| 1–3 days | 1,870 | 28.62 |
| 4–7 days | 1,802 | 27.58 |
| 8–14 days | 1,478 | 22.62 |
| 15–30 days | 1,039 | 15.90 |
| 31+ days | 345 | 5.28 |
| **Total** | **6,534** | **100.00** |

- 56.20% of late deliveries were at most 7 days late; 21.18% were at least 15 days late.

## Python phase — current status

The user created a Python script intended as `scripts/test_connection.py` that:

1. imports `os`, `pandas as pd`, `load_dotenv`, `create_engine`, and `URL`;
2. calls `load_dotenv()`;
3. uses `URL.create(drivername='postgresql+psycopg', username=os.getenv('DB_USER'), password=os.getenv('DB_PASSWORD'), host=os.getenv('DB_HOST'), port=int(os.getenv('DB_PORT', '5432')), database=os.getenv('DB_NAME'))`;
4. creates an engine with `create_engine(database_url)`;
5. executes `SELECT COUNT(*) AS total_orders FROM orders;` using `pd.read_sql_query(sql_query, engine)`;
6. prints the DataFrame.

The user reported successful terminal output:

```text
   total_orders
0         99441
```

This confirms a working local Python-to-PostgreSQL query **at the time of the test**. Codex should still verify whether `scripts/test_connection.py` exists and whether it is saved and committed.

## Planned next steps (not yet completed)

**Next focused lesson:** `scripts/export_regional_data.py`.
- Reuse the existing DB engine configuration.
- Read `sql/04_regional_analysis.sql` with `pathlib.Path.read_text(encoding='utf-8')`.
- Execute using `pd.read_sql_query()`.
- Check `df.head()` and `len(df)`; expected **27 rows**.
- Only after verification, export selected results with `df.to_csv()` for a future dashboard.

Later: reusable SQL-to-CSV export workflow, explicit validation and documentation, Streamlit dashboard, Streamlit Community Cloud deployment, and README polishing. Do not mark any of these as done without inspecting local evidence.

## User's preferred mentoring style

- The user wants to **learn independently**; give hints and focused code review before complete solutions unless explicitly requested.
- Favor **one 45–60-minute task** with an explicit stopping point rather than escalating scope.
- Avoid autonomous implementation when the user intends to practice Python/SQL. For the initial audit, **do not edit files**.
- Distinguish **reported in conversation**, **present locally**, **committed to Git**, **runs successfully**, and **not yet done**.

## Codex audit request

Read this handoff, then audit the repository **read-only**. Confirm the repository root, inspect `git status`, list tracked/untracked files relevant to Olist, review `.gitignore`, SQL scripts, findings, and Python script(s). Identify what is present, absent, modified, or uncommitted; check code for correctness and consistency with the definitions and metrics above. If safe, run non-destructive read-only checks that do not reveal secrets; ask before anything requiring credentials, destructive operations, writing files, pip installs, or commits. Report:

1. **Confirmed completed work** (cite local file paths and, where relevant, commands/results).
2. **Missing or incomplete work** compared with the handoff.
3. **Potential bugs or mismatches** and confidence level.
4. **Git status** and files that should be staged later (but do not stage them).
5. **Exactly one next 45–60-minute learning task** for the user, with hints instead of finished code.

Treat this handoff as background context, not as proof of on-disk completion.
