# Olist Shipment Delay Analysis — Findings

## 1. Data Validation

### Check 01: Record Count Verification

**Objective:** Verify that the customers and orders datasets were imported successfully.

**SQL File:** `sql/02_data_validation.sql`

**Results:**

| Table | Total Records |
|---|---:|
| customers | [Enter actual count] |
| orders | [Enter actual count] |

**Interpretation:**

[Explain whether the counts match the original CSV files.]

---

### Check 02: Missing Delivery Timestamps

**Objective:** Identify orders without recorded delivery dates.

**Results:**

- Total orders: [Enter count]
- Orders with delivery timestamps: [Enter count]
- Orders without delivery timestamps: [Enter count]

**Interpretation:**

[Explain what missing delivery timestamps could mean.]

---

### Check 03: Referential Integrity

**Objective:** Determine whether any orders reference nonexistent customers.

**Results:**

- Orphan orders: [Enter count]

**Interpretation:**

[Explain what the result means about the relationship between orders and customers.]

---

### Check 04: Missing Delivery Dates by Order Status

**Objective:** Investigate which order statuses have missing delivery timestamps.

**Results:**

[Insert a Markdown table with the actual order statuses and counts returned by your SQL query.]

**Interpretation:**

[Discuss whether missing timestamps are expected for canceled, shipped, or unavailable orders. Investigate any delivered orders with missing timestamps.]

---

## 2. Data Quality Observations

[Summarize important issues discovered during validation.]

## 3. Limitations

[Document any assumptions or limitations of the dataset and validation process.]