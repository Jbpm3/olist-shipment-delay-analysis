WITH monthly_deliveries AS (
	SELECT order_id,
	DATE_TRUNC('month',order_purchase_timestamp)::DATE AS purchase_month,
	CASE 
		WHEN order_delivered_customer_date::DATE > order_estimated_delivery_date::DATE 
			THEN 1
			ELSE 0
	END AS is_late
	FROM orders
	WHERE order_status = 'delivered'
		AND order_delivered_customer_date IS NOT NULL
		AND order_estimated_delivery_date IS NOT NULL
)

SELECT purchase_month,
	COUNT(*) AS total_delivered_orders,
	SUM(is_late) AS late_orders,
	ROUND(SUM(is_late) * 100.0/COUNT(*),2) AS late_delivery_pct
FROM monthly_deliveries
GROUP BY purchase_month
ORDER BY late_delivery_pct DESC;