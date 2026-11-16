WITH delivery_delays AS (
	SELECT 
		order_id,
		(order_delivered_customer_date::DATE - 
		 order_estimated_delivery_date::DATE) AS delay_days
	FROM orders
	WHERE order_status = 'delivered'
			AND order_delivered_customer_date IS NOT NULL
			AND order_estimated_delivery_date IS NOT NULL
), 
categorized_delays AS (
	SELECT order_id,
	delay_days,
		CASE
			WHEN delay_days BETWEEN 1 AND 3 THEN '1-3 days'
			WHEN delay_days BETWEEN 4 AND 7 THEN '4-7 days'
			WHEN delay_days BETWEEN 8 AND 14 THEN '8-14 days'
			WHEN delay_days BETWEEN 15 AND 30 THEN '15-30 days'
			ELSE '31+ days'
		END AS delay_category
	FROM delivery_delays
	WHERE delay_days > 0
)

SELECT delay_category,
	COUNT(*) AS order_count,
	ROUND(
		COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2)
			AS percentage_of_late_orders
FROM categorized_delays
GROUP BY delay_category
ORDER BY MIN(delay_days);
