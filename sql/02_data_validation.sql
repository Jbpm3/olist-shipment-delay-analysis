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
GROUP BY order_status;