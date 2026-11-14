-- ============================================
-- Olist Shipment Delay Analysis
-- Data Quality Validation
-- ============================================

-- Check 01: Verify total records in each table
-- Purpose: Confirm the number of imported records.

SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders;

-- Check 02: Identify orders with missing delivery dates
-- Purpose: Determine how many orders lack delivery timestamps.

SELECT
    COUNT(*) AS total_orders,
    COUNT(order_delivered_customer_date) AS orders_with_delivery_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS orders_without_delivery_date
FROM orders;


-- Check 03: Check for orphan orders
-- Purpose: Identify orders referencing nonexistent customers.

SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check 04: Investigate missing delivery dates by order status
-- Purpose: Determine which order statuses have missing delivery timestamps.

SELECT
    order_status,
    COUNT(*) AS missing_delivery_count
FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY missing_delivery_count DESC;

-- Check 05: Delivered Orders with Missing Delivery Timestamps

SELECT order_id, 
	order_status, 
	order_purchase_timestamp, 
	order_delivered_customer_date, 
	order_estimated_delivery_date
FROM orders
WHERE order_delivered_customer_date IS NULL
	AND order_status = 'delivered';

--- Check 06: Delivery Timestamp Chronological Validation

SELECT order_id, 
	order_status, 
	order_purchase_timestamp, 
	order_delivered_customer_date, 
	order_estimated_delivery_date
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

--- Check 07: Carrier Handoff Before Order Approval
-- Purpose: Measure the frequency and magnitude
-- of carrier-before-approval anomalies.

SELECT order_id, 
	order_status, 
	order_purchase_timestamp, 
	order_delivered_customer_date, 
	order_delivered_carrier_date,
	order_estimated_delivery_date,
	order_approved_at,
	(order_approved_at - order_delivered_carrier_date) AS approval_carrier_gap
FROM orders
WHERE order_delivered_carrier_date < order_approved_at
ORDER BY approval_carrier_gap DESC
LIMIT 5;

--- CTE
WITH anomalous_orders AS(
	SELECT 
        order_id,
	    EXTRACT(EPOCH FROM (order_approved_at - order_delivered_carrier_date)) / 3600 AS gap_hours
    FROM orders
    WHERE order_delivered_carrier_date < order_approved_at
)
SELECT COUNT(*) AS total_anomalous_orders,
	AVG(gap_hours) AS avg_gap_hrs,
	PERCENTILE_CONT(0.5) 
		WITHIN GROUP (ORDER BY gap_hours) AS median_gap_hrs,
	MIN(gap_hours) AS min_gap_hrs,
	MAX(gap_hours) AS max_gap_hrs
FROM anomalous_orders;

