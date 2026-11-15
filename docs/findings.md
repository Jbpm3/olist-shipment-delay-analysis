# Olist Shipment Delay Analysis — Findings

## 1. Data Validation

### Check 01: Record Count Verification

**Objective:** Verify that the customers and orders datasets were imported successfully.

**SQL File:** `sql/02_data_validation.sql`

**Results:**

| Table | Total Records |
|---|---:|
| customers | [99441] |
| orders | [99441] |

**Interpretation:**

[The count matches the original csv files]

---

### Check 02: Missing Delivery Timestamps

**Objective:** Identify orders without recorded delivery dates.

**Results:**

- Total orders: [99441]
- Orders with delivery timestamps: [96476]
- Orders without delivery timestamps: [2965]

**Interpretation:**

[This means that there are 2965 deliveries that were not completed]

---

### Check 03: Referential Integrity

**Objective:** Determine whether any orders reference nonexistent customers.

**Results:**

- Orphan orders: [0]

**Interpretation:**

[Nothing was found]

---

### Check 04: Missing Delivery Dates by Order Status

**Objective:** Investigate which order statuses have missing delivery timestamps.

**Results:**

"shipped"	1107
"unavailable"	609
"invoiced"	314
"created"	5
"approved"	2
"delivered"	8
"processing"	301
"canceled"	619

Results: 2,965 orders (approximately 2.98% of all orders) have missing customer delivery timestamps.

**Interpretation:**

Shipped: 1,107 orders (1.11% of all orders) have no recorded customer delivery timestamp. These orders may have been in transit when the data was captured. Further investigation is needed before classifying them as delayed or failed deliveries.

Canceled and unavailable: Missing delivery timestamps are generally consistent with these order statuses.

Delivered: Eight orders are marked as delivered despite having no recorded delivery timestamp. These are potential data-quality inconsistencies requiring further investigation.

Conclusion: Most missing delivery timestamps may be explained by order status. However, the eight delivered orders without timestamps warrant investigation, especially because delivery timestamps will be used to calculate shipment delays.

### Check 05: Delivered Orders with Missing Delivery Timestamps

**Objective:** Identify orders marked as delivered without a recorded customer delivery timestamp.

**Results:**

Eight orders have `order_status = 'delivered'` but contain NULL values in `order_delivered_customer_date`.

All eight records contain valid purchase and estimated delivery timestamps.

**Interpretation:**

These records represent potential data-quality inconsistencies because their delivery status indicates completion, but their actual delivery dates are missing.

Without actual delivery timestamps, it is impossible to determine whether these orders were delivered on time or late.

**Decision:**

Exclude these eight records from delivery-delay calculations that require an actual delivery timestamp. Preserve the original records and document their exclusion to maintain transparency and reproducibility.

---

### Check 06: Delivery Timestamp Chronological Validation

**Objective:** Identify delivered orders with actual delivery timestamps earlier than their purchase timestamps.

**Results:** Zero records met this condition.

**Interpretation:** No chronological inconsistencies were detected among orders marked as delivered that have recorded delivery timestamps.

**Limitation:** This check does not evaluate orders with other statuses or missing delivery timestamps. It also does not validate other chronological relationships, such as whether an order was approved before it was shipped.

### Check 07: Carrier Handoff Before Order Approval

**Objective:** Identify orders where the recorded carrier handoff occurred before order approval.

**Results:**

- 1,359 orders (approximately 1.37% of all orders) have carrier timestamps earlier than approval timestamps.
- The largest observed discrepancy is 171 days, 5 hours, 15 minutes, and 22 seconds.
- One record shows a carrier handoff in January 2018 despite the order being purchased in July 2018.
- Several other records show approval timestamps recorded after customer delivery.

**Interpretation:**

These records contain unexpected chronological sequences that may indicate timestamp-recording errors, delayed system updates, or other data inconsistencies. The exact causes have not been established.

**Decision:**

Retain the records in the original dataset. Flag anomalous timestamps for further investigation, and avoid relying on potentially invalid carrier or approval timestamps without additional validation.

The anomalies do not automatically invalidate delivery-delay calculations based on actual and estimated customer delivery dates.

### Check 07: Carrier Handoff Before Order Approval

**Objective:** Identify and measure chronological inconsistencies where an order's recorded carrier handoff occurred before approval.

**Results:**

| Metric | Value |
|---|---:|
| Affected orders | 1,359 |
| Percentage of all orders | 1.37% |
| Mean gap | 24.75 hours |
| Median gap | 17.17 hours |
| Minimum gap | 21 seconds |
| Maximum gap | 4,109.26 hours (171.2 days) |

**Interpretation:**

A total of 1,359 orders have carrier handoff timestamps earlier than their approval timestamps.

The mean gap of 24.75 hours exceeds the median of 17.17 hours, suggesting that larger discrepancies influence the average.

One particularly unusual record has a carrier handoff timestamp approximately 171 days before its recorded approval and purchase dates.

These inconsistencies may reflect timestamp-recording errors, delayed system updates, or other operational factors. Their underlying causes remain unverified.

**Data Handling Decision:**

Retain the original records and document these chronological anomalies.

Because the primary shipment-delay analysis uses actual and estimated customer delivery timestamps, these approval-to-carrier discrepancies do not automatically require excluding the affected orders.

**Limitation:**

The available data does not establish the causes of these inconsistencies.

## 2. Data Quality Observations

[Summarize important issues discovered during validation.]

## 3. Limitations

[Document any assumptions or limitations of the dataset and validation process.]

### Analysis 01: Late Delivery Rate

**Objective:** Determine the percentage of eligible orders delivered after their estimated delivery dates.

**Eligibility Criteria:**
- Order status must be `delivered`.
- Actual customer delivery timestamp must not be NULL.
- Estimated delivery timestamp must not be NULL.
- Compare calendar dates rather than full timestamps.

**Results:**

| Metric | Value |
|---|---:|
| Eligible delivered orders | 96,470 |
| Late deliveries | 6,534 |
| On-time deliveries | 89,936 |
| Late delivery rate | 6.77% |
| On-time delivery rate | 93.23% |

**Interpretation:**

Approximately 6.77% of eligible delivered orders arrived after their estimated delivery dates, while 93.23% arrived on or before the estimated dates.

**Limitations:**

The analysis excludes orders without sufficient delivery information and does not measure undelivered or canceled orders. It also does not establish the reasons for late deliveries.

### Analysis 02: Delivery Delay Duration

**Objective:** Measure how many calendar days late orders arrived compared with their estimated delivery dates.

**Methodology:**

- Include only orders marked as `delivered`.
- Exclude records with missing actual or estimated delivery timestamps.
- Calculate delay days by subtracting the estimated delivery calendar date from the actual delivery calendar date.
- Include only orders with positive delay days when calculating delay-duration statistics.

**Results:**

| Metric | Value |
|---|---:|
| Late orders | 6,534 |
| Average delay | 10.62 days |
| Median delay | 7 days |
| Minimum delay | 1 day |
| Maximum delay | 188 days |

**Interpretation:**

Among the 6,534 orders classified as late, the average delay was 10.62 calendar days, while the median was 7 days.

The mean exceeding the median suggests that longer delays influence the average. The maximum observed delay was 188 days.

**Limitations:**

These statistics describe only late deliveries, not all orders. The analysis measures delays against estimated delivery dates and does not establish the causes of those delays.